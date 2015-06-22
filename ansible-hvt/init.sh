#!/bin/bash

#HV: This file is used for initial setup testing
export ANSIBLE_HOST_KEY_CHECKING=False
ansible -i init_inventory.ini -m ping vms --ask-pass --ask-sudo-pass -vv
#ansible-playbook -i init_inventory.ini --ask-pass -vv -s  -l vms users.yml --ask-sudo
ansible-playbook -i init_inventory.ini --ask-pass -vv -s  -l vms init.yml --ask-sudo
