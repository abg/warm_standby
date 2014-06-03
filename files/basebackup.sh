#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Usage: $0 <primary ip>"
    exit 1
fi

host=$1
pgdata=/var/lib/pgsql/8.4/data/

ssh -o "StrictHostKeyChecking no" ${host} -- psql <<< "SELECT pg_start_backup('warm_standby')"
if [[ $? -ne 0 ]]; then
    echo "pg_start_backup() failed."
    exit 1
fi

set -x
rsync --archive \
      --verbose \
      --compress \
      --compress-level=1 \
      --delete \
      --rsh=ssh \
      --exclude="recovery.conf" \
      ${host}:${pgdata} \
      ${pgdata}
ret=$?
set +x
# either success (0) or "file disappeared" 24 are okay here
# we might expect some files to disappear (WAL, etc.) during
# an initial base backup
if [[ $ret -ne 0 && $ret -ne 24 ]]; then
    echo "rsync from ${host} (primary) to $(hostname) failed."
    exit 1
fi

ssh -o "StrictHostKeyChecking no" ${host} -- psql <<< "SELECT pg_stop_backup()"
if [[ $? -ne 0 ]]; then
    echo "pg_stop_backup() failed"
    exit 1
fi
