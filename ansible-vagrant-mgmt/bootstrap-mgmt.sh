#!/usr/bin/env bash

# install ansible (http://docs.ansible.com/intro_installation.html)
apt-get -y install software-properties-common
apt-add-repository -y ppa:ansible/ansible
apt-get update
apt-get -y install ansible git passlib

# copy examples into /home/vagrant (from inside the mgmt node)
#cp -a /vagrant/examples/* /home/vagrant
chown -R vagrant:vagrant /home/vagrant

# configure hosts file for our internal network defined by Vagrantfile
cat >> /etc/hosts <<EOL

# vagrant environment nodes
10.100.100.10  geonode
10.100.100.20  geonode-stage
10.100.100.30  docker
EOL
