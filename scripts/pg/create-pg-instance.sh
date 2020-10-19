#!/bin/bash

PG_IMAGE=${PG_IMAGE:-pg13-image}
NAME=${1:-pg-primary}
ZONE=${2:-us-central1-a}
CLUSTER_NAME=$3
ETCD_ILB_FQDN=$4

if [[ $# -ne 4 ]]; then
    echo "$0 [instance name] [zone] [cluster name] [etcd endpoint ilb]"
    exit 2
fi


SUBNET=default  #TODO - hardcoded for now because still using auto-network
REGION=$(gcloud compute zones describe $ZONE --format="value(region)")
REPLICATION_HOSTS_CIDR=$(gcloud compute networks subnets describe $SUBNET --region=$REGION --format="value(ipCidrRange)")

gcloud compute  instances create $NAME \
	--no-address \
	--zone=$ZONE \
	--machine-type=n2-standard-4 \
	--image-family=$PG_IMAGE \
	--boot-disk-size=10GB \
	--boot-disk-type=pd-standard \
	--boot-disk-device-name=$NAME-os \
	--no-boot-disk-auto-delete \
	--create-disk=auto-delete=false,mode=rw,size=50,type=pd-ssd,name=$NAME-data,device-name=data \
	--tags=pg-patroni, \
	--labels=cluster=$CLUSTER_NAME \
	--scopes=https://www.googleapis.com/auth/compute.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/trace.append,https://www.googleapis.com/auth/devstorage.read_write \
	--metadata-from-file startup-script=bootstrap-pg.sh \
	--metadata=CLUSTER_NAME=$CLUSTER_NAME,ETCD_ILB_FQDN=$ETCD_ILB_FQDN,REPLICATION_HOSTS_CIDR=$REPLICATION_HOSTS_CIDR

# Create an unmanaged instance group for the pg instances
# this is expected to fail if you are ading an instance to an existing zone
IG_NAME="$CLUSTER_NAME-$ZONE-ig"
gcloud compute instance-groups unmanaged create $IG_NAME --zone=$ZONE

## Add instances to instance group for zone 
gcloud compute instance-groups unmanaged add-instances $IG_NAME --instances=$NAME --zone=$ZONE
