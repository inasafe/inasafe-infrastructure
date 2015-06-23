#!/bin/bash

cat << EOF

====================
all the "usual" configs for InaSafe VMs
--------------------

EOF


ansible-playbook -v -i InaSafe.ini InaSafe.yml

