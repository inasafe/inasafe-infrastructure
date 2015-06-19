#!/bin/bash

# Determine avengers root directory
DIR=$(cd `dirname $0` && pwd)

# Invoke ansible
ansible-playbook -i "${DIR}/production.ini" "${DIR}/site.yml" $*
