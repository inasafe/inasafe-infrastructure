# Setup and Ansible instructions

## Basic principles

The basis for these Ansible scripts, is already setup hosts (either a virtual or a bare metal instance), with the following attributes to be able to bootstrap them:

* SSH on port 22
* user with a password
* user can SU to root, with a password.

With that, the `bootstrap.ini` file can be edited with the correct information and the `bootstrap.sh` run to be able to bootstrap the instances.

Once the instances have been bootstrapped, you can then update the `InaSAFE.ini` and run the `InaSAFE.sh` to configure the hosts accordingly.

***Note:*** *The dockers aren't yet integrated though they should be*
***Note:*** *The Proxmox/Hypervisor setup is handled elsewhere and that setup is not yet integrated with the Ansible, though it should be considered.*

## Clean (absolutely clean) Slate First Steps:

1. Clone Ubuntu VMs created from Proxmox Installation instructions. The assumption is:

	* User: ubuntu
	* Password: Remembered and used below
	* SSH port 22 for this ubuntu user

2. Check `bootstrap.ini` -> still need to find a way to do this elsewhere, as there are method, but the time was not there yet to research this process.
3. run `bootstrap.sh` entering the ubuntu user's password from above. The bootstrap script will then:

 * first ping and check it can ssh in with the password *(Still need to add a check to exit if this step fails)*
 * The script will ask ***again***  for the ubuntu user password. This is the login password. Also enter the password for the user a ***third time*** for the SUDO command used inside the VMs. The bootstrap playbook will then
		* install the `gavin` & `hvisage` users ***Note:*** *If you aren't `hvisage` nor `gavin`, then you will need to modify the bootstrap roles to include your username and publickeys*
   		* install the `sudo` and `sshguard/fail2ban` packages
   		* set the `sudoers` file
   		* sshd config
4. issue a reboot as your own user (in my case that was/is `hvisage` with it's ssh keys already loaded and using sudo without password) ***Note:*** *If you aren't `hvisage` nor `gavin`, then you will need to modify the bootstrap roles to include your username and publickeys for this step and the next to work*
5. lastly, doing a ping to check it worked


## InaSAFE configurations

