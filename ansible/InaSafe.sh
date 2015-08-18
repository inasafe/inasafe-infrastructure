#!/bin/bash

cat << EOF

====================
all the "usual" configs for InaSAFE VMs
--------------------

EOF


ansible-playbook -v -i InaSAFE.ini InaSAFE.yml

