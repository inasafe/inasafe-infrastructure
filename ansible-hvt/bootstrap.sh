#!/bin/bash

#HV: This file is used for initial setup testing
export ANSIBLE_HOST_KEY_CHECKING=False

echo "Let's first check that we can connect okay with the VMs:"

ansible -i bootstrap.ini -m ping vms --ask-pass -vvvv || exit 255

ansible-playbook -i bootstrap.ini --ask-pass -vv -b  -l vms bootstrap.yml --ask-become-pass 
ansible -i inventory.ini -v  vms -m shell -a "/sbin/reboot" -e ansible_ssh_port=22 -b

echo "Let's wait a tad:"
for i in 10 9 8 7 6 5 4 3 2 1; do sleep 1;echo $i;done
ansible -i inventory.ini -v  vms -m ping
