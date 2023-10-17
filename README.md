# LAMP-project Altschool Project Bash Script Documentation

## Introduction

This documentation provides an overview of a Bash script designed for setting up a virtualized environment using Vagrant and deploying a LAMP (Linux, Apache, MySQL, PHP) stack on a master and slave node. The script automates the following tasks:

1. Creation of a directory to run Vagrant from.
2. Writing a Vagrant configuration file.
3. Deploying Vagrant.
4. Creating a user with sudo privileges on the master node.
5. Setting up passwordless sudo for the user.
6. Installing an SSH client and generating SSH keys.
7. Configuring the master node to copy its public SSH key to the slave node.
8. Creating and copying contents between nodes.
9. Monitoring processes on the master node.
10. Deploying a LAMP stack on both nodes.

## Usage

To use this script, follow these steps:

1. Make the script executable: `chmod +x altschool_setup.sh`.
2. Execute the script: `./altschool_setup.sh`.

Ensure you have Vagrant and VirtualBox installed on your system to run this script. Additionally, review the script to make any necessary adjustments to match your specific requirements and system setup.

## Script Structure

The script is structured as follows:

1. **Directory Creation**: A directory `/altschool_project/` is created, and the script changes the current working directory to this location.

2. **Vagrant Configuration**:
   - A Vagrant configuration file named `Vagrantfile` is created or overwritten if it already exists.
   - The Vagrant configuration specifies two virtual machines (master and slave) based on the `generic/ubuntu2204` box.

3. **Vagrant Deployment**: Vagrant is used to start the virtual machines defined in the configuration.

4. **User Setup**:
   - A user named `altschool` is created on the master node with sudo privileges.
   - Passwordless sudo access is configured for the `altschool` user.
   - A password is set for the `altschool` user.

5. **SSH Client and Keygen**: SSH client is installed, and SSH keys are generated for the `altschool` user on the master node.

6. **SSH Key Copy**: The public SSH key from the master is copied to the `authorized_keys` file on the slave node.

7. **Content Directory Setup**: Directories for content storage are created on both nodes.

8. **Content Copy**: Contents from the master node are copied to the slave node.

9. **Process Monitoring**: The script displays the number of processes running on the master node and lists the top 10 processes.

10. **LAMP Stack Deployment**: A script (`installer.sh`) for setting up the LAMP stack is created and executed on both nodes.

11. **Cleanup**: Access permissions are adjusted, and the `installer.sh` script is removed from the master node.

## Note

Before running the script, ensure that you have the necessary boxes for Vagrant available and that you have set up Vagrant networking configurations appropriately.

## Security

This script includes certain security-sensitive operations, such as password configuration and SSH key management. Exercise caution and ensure that you are using it in a secure environment. Additionally, customize the security measures to meet your organization's requirements.

## Conclusion

The script automates the setup and deployment of a virtual environment for the Altschool project. Please review and modify the script as needed for your specific use case, and consider security best practices for your deployment.
