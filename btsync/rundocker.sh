#!/bin/bash

DATADIR="/var/docker/volumes/btsync"

./docker-build.sh

if [[ ! -e $DATADIR ]]; then
    sudo mkdir -p $DATADIR/{data,.sync}
elif [[ ! -d $DATADIR ]]; then
    echo "$DATADIR already exists but is not a directory" 1>&2
fi
if [[ -d $DATADIR ]]; then
sudo cp ./btsync.conf /var/docker/volumes/btsync/
sudo cp -r resource /var/docker/volumes/btsync/data/
fi

./docker-run.sh
