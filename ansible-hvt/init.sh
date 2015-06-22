#!/bin/bash

#HV: This file is used for initial setup testing

ansible -i init_inventory.ini -m ping vms --ask-pass --ask-sudo-pass -vv
