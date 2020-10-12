## Immediate 


### pg-playbook

1. Create image as part of the pg-playbook
2. Tuning for Pg / OS
    - max_connections
    - shared_buffer
    - checkpoint_timeout
3. No pg logs in the directory anymore - is it going to syslog?
4. Verify the postgresql.base.conf defaults

### patroni setup

2. Why are stderr from patroni starting up postgres not visible in the patroni logs
3. Necessary setup for
  - bootstrapping a brand new cluster
    - tweak the bootstrap config - needs to create relevant users (replicator, postgres user with password?)
  - bootstrapping an existing Pg instance as the master
4. patroni.service file
  - Dynamically update the IP based on a ExecStartPre ?
    - https://superuser.com/questions/968561/how-to-get-the-machine-ip-address-in-a-systemd-service-file


### ansible setup

1. Get ansible to use dynamic inventory
2. Get host_key_checking to work
3. Group vars names using illegal char '-'

## Longer term

1. Further tuning for Pg instnace
  - os optimizations
  - network optimizations
  - pd-ssh / fs optimizations 

2. Logging 
  - get patroni, etcd and postgresql logs streaming to cloudlogging
  - Using stackdriver logging for logs

3. Monitoring
   - 3rd party tool?
   - what should be monitored - rep lag, disk, io

4. backups 
  - wall-g, pg_backrest
  - simplify the bootstrap

5. connection pooling
  - pgbouncer/pg-pool?
  - run on dedicated IG 
  - allow the use of only 1 ILB

6. security
  - ssl connections
  - user lockdown


Steps to handle the following operational tasks:
1. Upgrading disk size
2. Updating os disk (same major version)
3. Updating new major version

