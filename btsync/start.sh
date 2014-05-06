#!/bin/bash

#HOSTNAME=`hostname -f`

# upate the config with injected secret
#sed -i 's/"device_name" : ""/"device_name" : "Sync container '$HOSTNAME'"/' /etc/btsync.conf
sed -i 's/"secret" : ""/"secret" : "'$SECRET'"/' /btsync/btsync.conf 

# start the daemon with our config file
exec /usr/bin/btsync --nodaemon --config /btsync/btsync.conf
