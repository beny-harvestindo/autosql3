#!/usr/bin/env bash
set -Eeuo pipefail

# first arg is `-f` or `--some-option`
# or there are no args

CONTAINER_ALREADY_STARTED="CONTAINER_ALREADY_STARTED_PLACEHOLDER"
if [ ! -e $CONTAINER_ALREADY_STARTED ]; then
    touch $CONTAINER_ALREADY_STARTED
    echo "-- First container startup --"
    rm -f /etc/automysqlbackup/automysqlbackup.conf
    bash -C '/usr/local/bin/install.sh'
else
    echo "-- Not first container startup --"
    rm -f /etc/automysqlbackup/automysqlbackup.conf
    bash -C '/usr/local/bin/install.sh'
fi

if [ "$#" -eq 0 ] || [ "${1#-}" != "$1" ]; then
    # docker run bash -c 'echo hi'
    exec bash "$@"
fi

exec "$@"

