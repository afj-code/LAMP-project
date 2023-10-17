#!/bin/bash

#Create and move to directory to run vagrant from
mkdir /altschool_project/
cd /altschool_project/

#To begin, set vagrant var
vagrant_config="Vagrantfile"

#check if a previous Vagrant file exists
if [[ -f "$vagrant_config" ]]
then
        echo "Deleting previous vagrant configuration and writing new"
        rm Vagrantfile
else
        echo "No previous file found, writing vagrant configuration..."
        exit 1
fi

#Write vagrant config into new vagrant file
cat <<EOL> $vagrant_config
Vagrant.configure("2") do |config|
config.vm.box = "generic/ubuntu2204"

 #master VM config
 config.vm.define "master" do |master|
  master.vm.network "private_network", type: "dhcp"
  master.vm.hostname = "master"
 end

 #slave VM config
 config.vm.define "slave" do |slave|
  slave.vm.network "private_network", type: "dhcp"
  slave.vm.hostname = "slave"
 end
end
EOL

#deploy vagrant
vagrant up

#Create altschool user in sudo and root group on master node
vagrant ssh master -c "sudo useradd -m -G sudo,root altschool"

#remove password dependency for sudo command
vagrant ssh master -c "echo 'altschool ALL=(ALL) NOPASSWD: ALL' | sudo tee /etc/sudoers.d/altschool"

#Add password to altschool user
vagrant ssh master -c "echo -e 'altmaster\naltmaster' | sudo passwd altschool"
echo "Created password to altschool user is 'altmaster'"

#Install SSH client
vagrant ssh master -c "echo 'y' | sudo apt install openssh-client"

#Generate SSH keygen
vagrant ssh master -c "echo '' | sudo -u altschool ssh-keygen -N """

#assign slave ip addr
slave_ip=$(vagrant ssh slave -c "ip a show enp0s8 | grep -oP '(?<=inet\s)\d+(\.\d+){3}'" | tr -d '\r')

#Copy the public key to slave's authorized keys
vagrant ssh master -c "sudo -u altschool cat /home/altschool/.ssh/id_rsa.pub" | vagrant ssh slave -c "cat >> ~/.ssh/authorized_keys"

#Create content dir in master
vagrant ssh master -c "sudo -u altschool sudo mkdir -p /mnt/altschool"

#Create destination dir in slave
vagrant ssh slave -c "sudo mkdir -m 777 -p /mnt/altschool/slave"

#Copy contents
vagrant ssh master -c "sudo -u altschool scp -q -r /mnt/altschool vagrant@$slave_ip:/mnt/altschool/slave"

#Process monitoring
process_no=$(vagrant ssh master -c "ps | wc -l")
vagrant ssh master -c "echo "There's currently $process_no process(es) running on master, below is the top 10"; ps | head"


#LAMP stack deployment
cat <<EOL > installer.sh
#!/bin/bash
#update packagge list
sudo apt-get update

#install apache server
sudo apt-get install apache2 -y

#enable apache to start on boot
sudo systemctl enable apache2

#start apache
sudo systemctl start apache2

#install mysql server
sudo apt-get install mysql-server -y

#secure mysql installation
sudo mysql_secure_installation <<EOF

n
y
y
y
y
EOF

sudo mysql -u root -p "root" <<MYSQL_SCRIPT
CREATE DATABASE newdb;
CREATE USER 'dee'@'localhost' IDENTIFIED BY 'ade';
GRANT ALL PRIVILEGES ON newdb.* TO 'dee'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

#install php
sudo apt-get install php libapache2-mod-php php-mysql -y

#create a test php file
echo "<?php phpinfo(); ?>" | sudo tee /var/www/html/info.php

#restart apache to apply changes
sudo systemctl restart apache2
EOL

#give altschool dir all access
vagrant ssh master -c "sudo chmod ugo+w /home/altschool"

#run script on master and slave node
cat installer.sh | vagrant ssh master -c 'sudo -u altschool sudo cat > /home/altschool/installer.sh && sudo -u altschool sudo chmod 777 /home/altschool/installer.sh'
vagrant ssh master -c 'sudo -u altschool scp /home/altschool/installer.sh slave:~/'

vagrant ssh slave -c "sudo chmod 777 ~/installer.sh"

#remove access
vagrant ssh master -c "sudo chmod go-w /home/altschool"

#remove file
rm -rf installer.sh

vagrant ssh master -c "sudo -u altschool /home/altschool/installer.sh"

vagrant ssh slave -c "~/installer.sh"