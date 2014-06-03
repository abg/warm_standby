#!/bin/bash

primary="{{ hostvars.primary['ansible_' + iface].ipv4.address }}"

echo "Stopping Postgres instance, if running..."
service postgresql-8.4 status > /dev/null 2>&1
ret=$?
if [[ $ret -eq 0 ]]; then
        service postgresql-8.4 stop
    if [[ $? -ne 0 ]]; then
        echo "Failed to stop Postgres"
        exit 1
    fi
elif [[ $ret -gt 3 ]]; then
    echo "Unknown state of Postgres service. Aborting."
    exit 3
else
    echo "Postgres is already stopped."
fi

echo "Copying data from primary (${primary})"
su - postgres -c "/var/lib/pgsql/bin/basebackup.sh '${primary}'"
if [[ $? -ne 0 ]]; then
    echo "basebackup failed"
    exit 1
fi

echo "Starting warm standby..."
service postgresql-8.4 start
if [[ $? -ne 0 ]]; then
    echo "Failed to start postgres"
    exit 1
fi
