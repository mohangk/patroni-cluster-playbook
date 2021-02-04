# For etcd
1. Setup etcd instances behind a global ILB
  - create a client instance
  - test accessing the etcd instances from the client
  - ensure global access

2. Add relevant outputs from the etcd.tf
  a. Instance IPs
  b. Forwarding rule

3. Create the setup script for the etcd cluster and add a README

# For PG
1. pg-patroni-tf
  - boot-disk-size=10GB \
  - add the second disk
  - add tags
  - add labels
  - add metadata 
  - add startup script
3. Cleanup the todos in  the file
4. Add the LBs 
5. End to end test
6. Figure out how best to define multiple clusters?
  - make it into a module?
7. Test running TF scripts from a cloud shell instance

# General

1. Rewrite the readme, move out the ansible playbooks 

