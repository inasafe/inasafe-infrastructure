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
	* The needed extra storage have been assigned as separate virtual disks (using the `virtio` driver)

2. Check `bootstrap.ini` -> still need to find a way to do this elsewhere, as there are method, but the time was not there yet to research this process.
3. run `bootstrap.sh` entering the ubuntu user's password from above. The bootstrap script will then:

 * first ping and check it can ssh in with the password *(Still need to add a check to exit if this step fails)*
 * The script will ask ***again***  for the ubuntu user password. This is the login password. Also enter the password for the user a ***third time*** for the SUDO command used inside the VMs. The bootstrap playbook will then run, refer below for actions.
4. issue a reboot as your own user (in my case that was/is `hvisage` with it's ssh keys already loaded and using sudo without password) 
5. lastly, doing a ping to check it worked


#### bootstrap playbook actions

The bootstrap playbook does the following:

* Setup the LVM storage volumes for the respective VMs (Refer to [volman.yml](volman.yml) )
* configure sudo
* install the needed packages for bootstrap (refer to [packages.yml](roles/bootstrap/tasks/packages.yml) )
* setup the hostname and /etc/hosts file
* Insert the system users and
	 their SSH public keys (refer to [users.yml] (users.yml) )
* change the SSH port to 8697


## InaSAFE configurations

Once the `bootstrap.sh` had run *succesfully*, you can then run the `InaSAFE.sh` which does the InaSAFE playbook.


### InaSAFE playbook

The InaSAFE playbook does the following

* run the common role
	* Instalaltion of all (known) needed packages
	* setup SSH (based on the common role's template)
	* setup hostname & /etc/hosts & mailer name
	* remove the default debian & ubuntu users 
	* set some diverse files for fsck, environment and sudoers file
* run the ansible-locale role and setup the locale for the environment
* run the included `users.yml` playbook for the users and their public keys
* run the `backups.yml` playbook 	



### `geonode.yml` playbook



This playbook is for setting up the geonode instances, with the geonode role.

* `ppa:geonode/testing` apt source
* install the `geonode` application package
* set geonode IP
* set geonode superuser

***Note:*** *this still needs to be integrated with the main playbook*

### `backups.yml` playbook

This will setup the `duplicity` application for backups. Refer to the  [Backup-strategy](../Backup-strategy/README.md) for the documentation of what is outstanding on this.

The `cron.d` and `/usr/local/bin/` scripts are in the [files](files) directory
 
### `users.yml` playbook

This is the playbook, using the systemusers role to create system users.
* add the user's public keys to the pub_keys directory, contain the public keys, even multiples, as would be for an `authorized_keys` file.

 Manually installing geonode
 ===========================

First fix the issue with unset locales (this must be fixed in Ansible in base install)

sudo su -
echo 'LANGUAGE="en_US.UTF-8"' >> /etc/default/locale
echo 'LC_ALL="en_US.UTF-8"' >> /etc/default/locale
exit

sudo service postgresql stop
sudo apt-get -y purge postgresql postgis postgresql-9.3-postgis-2.1
sudo apt-get -y --purge remove postgresql\*
sudo rm -r /etc/postgresql/
sudo rm -r /etc/postgresql-common/
sudo rm -r /var/lib/postgresql/
sudo userdel -r postgres
sudo groupdel postgres
sudo apt-get install postgresql postgis postgresql-9.3-postgis-2.1
sudo apt-get install geonode #this should normally also install postgis dependencies
geonode createsuperuser
sudo geonode-updateip 5.9.160.105 #for production; 106 for staging
Then add the alternative IP addresses and domains (or just '*') to ALLOWED_HOSTS in /etc/geonode/local_settings.py

ALLOWED_HOSTS= [  'localhost', '5.9.160.106', '*',  'staging.geonode.inasafe.org',  ]

and SITE_URL must be the domain name, not the IP address:

SITEURL = 'http://geonode.inasafe.org/'

add full domain name to /etc/hosts so that local requests resolve properly, e.g.

10.10.10.12 geonode-stage staging.geonode.inasafe.org

Set the Geoserver proxy base url either through the web interface under Global or e.g.
http://staging.geonode.inasafe.org/geoserver/

scp kartoza4:/home/timlinux/backups/geonode-styling-backups.17-August-2015.tar.gz .; scp ./geonode-styling-backups.17-August-2015.tar.gz geonode-stage.inasafe.org:/home/gavin

tar xzvf geonode-styling-backups.17-August-2015.tar.gz
sudo mv /usr/local/lib/python2.7/dist-packages/geonode/templates /usr/local/lib/python2.7/dist-packages/geonode/templates_
sudo mv usr/local/lib/python2.7/dist-packages/geonode/templates/ /usr/local/lib/python2.7/dist-packages/geonode/
sudo mv /var/www/geonode /var/www/geonode_
sudo mv var/www/geonode /var/www/
sudo service apache2 reload

sudo cp /var/www/geonode_/uploaded/thumbs/* /var/www/geonode/uploaded/thumbs/
