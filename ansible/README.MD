Clean (absolutely clean) Slate First Steps:

1) Create Ubuntu VMs with user: ubuntu -> add password (and rememebr it for later use)
2) Check bootstrap.ini -> still need to find a way to do this else where
3) run bootstrap.sh entering the ubuntu user's password
 a) it'll first ping and check it can ssh in with the password
 b) then it'll ask again for password (typically just enter for the sudo password)
 c) bootstrap playbook will then
   i) install the Gavin & Hvisage users
   ii) install the sudo and sshguard/fail2ban packages
   iii).. set the sudoers file
   iv)..... sshd config
 d) issue a reboot as the "normal" user (in my case that was/is hvisage with it's ssh keys already loaded and using sudo without password)
 e) lastly, doing a ping to check it worked

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


