# For etcd
1. Setup etcd instances behind a global ILB
  - create a client instance
  - test accessing the etcd instances from the client
  - ensure global access

2. Add relevant outputs from the etcd.tf
  a. Instance IPs
  b. Forwarding rules

3. Create the setup script for the etcd cluster and add a README

# For PG
1. (done) pg-patroni-tf 
  - boot-disk-size=10GB \
  - add the second disk
  - add tags
  - add labels
  - add metadata 
  - add startup script
2. Cleanup the todos in  the file
3. (done) Add the LBs
4. End to end test
  - test failover
  - test removing an instance when passing replica lag threshold
5. Figure out how best to define multiple clusters?
  - make it into a module?
6. Test running TF scripts from a cloud shell instance
7. Add relevant outputs from the pg-patroni.tf
  a. Instance IPs
  b. Forwarding rules

# General
1. Rewrite the readme, move out the ansible playbooks 

