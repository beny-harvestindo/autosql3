#!/bin/bash

CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED
    echo "-- First container startup --"
    rm -f /etc/automysqlbackup/automysqlbackup.conf
    bash -C '/usr/local/bin/install.sh'
else
    echo "-- Not first container startup --"
fi

exec "$@"
