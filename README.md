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

#### C. Create Postgresql-12 image

1. Create an instance to use for image setup
```bash
cd ./scripts/pg
./create-pg-img-instance.sh
```
2. Update the Ansible `inventory` file and ensure that the newly created pg12-img IP or resolvable hostname is in the `[pg-img]` section
```bash
cd ../../
vim inventory
```
3. Run playbooks to install and configure PostgreSQL-12 and Patroni on the pg12-img
```bash
ansible-playbook bootstrap-python.yml
ansible-playbook pg-playbook.yml
ansible-playbook patroni-playbook.yml
```
4. Create the pg12-img base image
```bash
./scripts/create-image.sh pg12-img pg12
```
#### D. Create 3 Pg instances

1. Edit `scripts/pg/create-pg-instance.sh` and set the PG_IMG variable to match the base pg-image just created

2. Spin up 3 instances in 3 different zones
```bash
cd ./scripts/pg
./create-pg-instance.sh pg-patroni-1 us-central1-a
./create-pg-instance.sh pg-patroni-2 us-central1-b
./create-pg-instance.sh pg-patroni-3 us-central1-c
```


