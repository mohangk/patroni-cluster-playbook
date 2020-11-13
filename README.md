## Introduction

Scripts, Ansible playbooks and steps to setup a HA PG on Google Cloud


### Dependencies
1. Create project with auto mode network (TODO move to custom mode network and more explicit subnet setup)

2. Start a Debian instance to serve as a bastion that allows you to directly ssh to VMs in your VPC (TODO - Look into the possibility of using Cloud Shell. Off the bat doesn't work because any ssh between CloudShell and VM still needs to go through IAP tunneling)

3. Install Ansible, git on the bastion 

```bash
sudo apt-get update
sudo apt-get install pip3-python git
pip3 install ansible
```

4. Add  ~/.local/bin to PATH 

```bash
echo "export PATH=$PATH:~/.local/bin" >> ~/.bashrc
source ~/.bashrc
```

5. Clone project to instances

```bash
git clone https://github.com/mohangk/patroni-cluster-playbook
cd patroni-cluster-playbook
```

6. Install Ansible role dependencies

```bash
ansible-galaxy install -r requirements.yml
```


### Process

#### A. General setup (will be moved to TF)

1. Setup proxy only subnet 
`./scripts/create-proxy-only-subnet.sh`

#### B. Setup the etcd instances + ILB

Note: For the etcd cluster these steps currently create VMs, install and configure etcd without baking any images. Might change this to be similar to the PG steps below

1. Create 2 etcd instances (TODO: make it 3) - etcd1, etcd2
`./scripts/etcd/create-etcd-instances.sh`

2. Update `inventory` file with the right IPs of those instances (internal FQDNs should work as well)

3. Configure the instances using Ansible playbook

```bash
ansible-playbook bootstrap-python.yml
ansible-playbook etcd-playbook.yml
```
4. Test the etcd setup
```bash
sudo apt-get install etcd-client
ETCDCTL_API=2 etcdctl --endpoints=http://10.128.0.23:2379,http://10.128.0.24:2379 cluster-health
member 24f8852431eab991 is healthy: got healthy result from http://10.128.0.24:2379
member f50f5176eb86d3e3 is healthy: got healthy result from http://10.128.0.23:2379
cluster is healthy
```
5. Setup the http ILB for the etcd cluster (TODO move to TF)
```bash
./scripts/etcd/create-etcd-lb.sh
```

6. Get the IP of the etcd ILB
```bash 
gcloud compute forwarding-rules list --filter=name:patroni-etcd*
```

#### C. Create PostgreSQL image

1. Create an instance to use for image setup
```bash
cd ./scripts/pg
./create-pg-img-instance.sh
```
2. Update the Ansible `inventory` file and ensure that the newly created pg-img IP or resolvable hostname is in the `[pg-img]` section
```bash
cd ../../
vim inventory
```
3. Run playbooks to install and configure PostgreSQL and Patroni on the `base-image`. Version of PostgreSQL can be customised by updated the `pgversion` variable in `pg-playbook.yml` file.
```bash
ansible-playbook bootstrap-python.yml
ansible-playbook pg-playbook.yml
ansible-playbook patroni-playbook.yml
ansible-playbook pgbouncer-playbook.yml
```
4. Create the pg-img base image
```bash
./scripts/create-image.sh pg-img pg12
```
#### D. Create Patroni-Pg cluster members
1. Set the PG_IMAGE variable to match the base pg-image name just created, or edit the default value in `create-pg-instance.sh` script.

2. Spin up 3 instances in 3 different zones using the `create-pg-instance.sh` script. Takes the following arguments <hostname> <region> <cluster-name> <etcd-ilb-fqdn>. This will spin up the pg instances, and add them to unmanaged instance groups that will stil behind the ILB created in "E"
```bash
cd ./scripts/pg
PG_IMAGE=pg12-202010100000 ./create-pg-instance.sh pg-patroni-1 us-central1-a pg-patroni 10.128.0.25:80
PG_IMAGE=pg12-202010100000 ./create-pg-instance.sh pg-patroni-2 us-central1-b pg-patroni 10.128.0.25:80
PG_IMAGE=pg12-202010100000 ./create-pg-instance.sh pg-patroni-3 us-central1-c pg-patroni 10.128.0.25:80
```

3. Once up you can access and instance by ssh-ing to it and viewing the state of your cluster by running the following on the instances
```bash
patronictl -c /etc/patroni/patroni.yml list
```
#### E. Create  Patroni-Pg ILB 

1. Run `scripts/pg/create-pg-ilb-hc.sh` to create the health checks that will be used for the patroni pg cluster. 
```bash
./scripts/pg/create-pg-ilb-hc.sh pg-patroni
```

2. Run `scripts/pg/create-pg-cluster-ilb.sh` to create the backend services and forwarding rule that will be use by this specific Patroni-Pg cluster. Takes the following arguments <cluster-name> <region>. This will only need to be run once per cluster. 

```bash
./scripts/pg/create-pg-cluster-ilb.sh pg-patroni us-central1
```

### Test your cluster

#### Identifying your cluster primary and replica endpoints

1. You can access your pg cluster by connection your client to the IPs of the primary and replica ILBs. List the IPs by doing the following
```bash
gcloud compute forwarding-fules list --filter=name:pg-patroni*
```

2. Connect via psql as per usual

#### Simple pgbench testing

1. Init the database 
```bash
./simple_pgbensh.sh <primary IP> init
```
2.Run the read-write test

```bash
./simple_pgbench.sh <primary IP> run
```

3. Run the read only test

```bash
./simple_pgbench.sh <replica IP> rorun
```




### Deleting your cluster

1. Delete the forwarding-rules, backends, instance-groups by running the following
```bash
./scripts/pg/delete-pg-cluster-ilb.sh pg-patroni us-central1
```

2. Remove your cluster from the DCS via patronictl. SSH into one of the instances and execute the following
```bash
patronictl -c /etc/patroni/patroni.yml pause
patrinictl -c /etc/patroni/patroni.yml remove <cluster>
```

3. Remove the PG-patroni instances by using the helper script
```bash
./scripts/pg/delete-pg-instances.sh [iinstance name] [zone]
```
