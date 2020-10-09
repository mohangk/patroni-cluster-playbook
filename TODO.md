## Immediate 

### postgresql role

1. Allow for the the data_dir to be overidden (this has been done in my role)
2. Why do we have the data dir defined in 2 places ?
  postgresql_data_dir: "/mnt/disks/pgdata/12/main"
  postgresql_global_config_options:
3. While creating the pg-instance, disable default createcluster
        path: /etc/postgresql-common/createcluster.conf
        replace: create_main_cluster = false      
        regexp: ^#?create_main_cluster.*$         
4. Create a fork and use fork as part of playbook requirements

### pg-playbook

1. Ensure that the postgres service is disabled on bootup
2. Move bootstrap.sh steps into the pg12-playbook
3. Add the cleanup steps before image creation to the pg-playbook
4. Create image as part of the pg-playbook
5. Disable the setting up of clusters during the pg playbook
6. Tuning for Pg / OS
    - max_connections
    - shared_buffer
    - checkpoint_timeout

### patroni setup

1. Update the unix_socket_directories setting to the default
2. Why are stderr from patroni starting up postgres not visible in the patroni logs
3. Necessary setup for
  - bootstrapping a brand new cluster
    - tweak the bootstrap config - needs to create relevant users (replicator, postgres user with password?)
  - bootstrapping an existing Pg instance as the master

### ansible setup

1. Get ansible to use dynamic inventory

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

