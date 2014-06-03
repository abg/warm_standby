Description
===========

This is an ansible template to setup a Postgres 8.4 primary instance
and one or more standby instances running on RHEL/CentOS 6 using the
pgdg repo.

This assumes there is some remote user with sudo access on the remote systems.

This is intended for very old 8.4 deployments to support minimal redundancy by
leveraging log shipping.  For modern deployments, you probably want to look at
Postgres 9 streaming replication which is not support by this playbook.

Usage
=====

Update hosts in the hosts file.

```
# ansible-playbook --sudo --ask-pass --ask-sudo-pass --user=myuser -i hosts warm_standby.yml 
```

After this playbook runs you have a minimal Postgres setup with:

- A primary server archiving WAL to the standbys
- One or more standbys in recovery mode

The standby's recovery.conf is configured to use pg_standby and a trigger file in
/var/lib/pgsql/8.4/promote_standby.
