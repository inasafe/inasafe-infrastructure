#!/bin/bash

DOCKERNAME="inasafe/btsync"
DATADIR="/var/docker/volumes/btsync"
SEC="BSU2UCAVRV7P4CHRYOZGIRQ2VN6CH4JP3"

if [[ ! -e $DATADIR ]]; then
    sudo mkdir -p $DATADIR/{data,.sync}
elif [[ ! -d $DATADIR ]]; then
    echo "$DATADIR already exists but is not a directory" 1>&2
fi

if [[ -d $DATADIR ]]; then
  sudo cp ./btsync.conf $DATADIR/
  sudo cp -r resource $DATADIR/data/
fi

docker build -t $DOCKERNAME .

if [ -z "$1" ]; then
  echo "Use the script with an added SECRET for BTSync"
  echo "Example: ./rundocker.sh THISISMYSECRET"
  echo "We default to the READ ONLY SECRET for InaSAFE"
  docker run -d -p 55555:55555 -v $DATADIR/:/btsync/ -e SECRET=$SEC --name="InaSAFE_Data" $DOCKERNAME
 else
  docker run -d -p 55555:55555 -v $DATADIR/:/btsync/ -e SECRET=$1 --name="InaSAFE_Data" $DOCKERNAME
fi
