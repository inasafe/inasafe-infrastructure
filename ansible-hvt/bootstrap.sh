#!/bin/bash

#HV: This file is used for initial setup testing
export ANSIBLE_HOST_KEY_CHECKING=False

echo "Let's first check that we can connect okay with the VMs:"

#ansible -i bootstrap.ini -m ping vms --ask-pass -vvvv || exit 255
ansible -i bootstrap.ini -m shell -a "pvs;lvs"  vms -b --ask-become-pass --ask-pass -vvvv || exit 255

ansible-playbook -i bootstrap.ini --ask-pass -vv -b  -l vms bootstrap.yml --ask-become-pass 

#At this point, we swap to the standard inventory :)

ansible -i InaSafe.ini -v  all -m shell -a "/sbin/reboot" -e ansible_ssh_port=22 -b  || exit 127

echo "Let's wait a tad:"
for i in 10 9 8 7 6 5 4 3 2 1; do sleep 1;echo $i;done
ansible -i InaSafe.ini -v  all -m ping  || exit 63
