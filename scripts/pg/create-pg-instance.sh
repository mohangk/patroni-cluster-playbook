#!/bin/bash


#if PG_IMAGE is set, use that otherwise use PG_IMG_FAMILY
if [ -n "$PG_IMG" ]; then 
	IMAGE=$PG_IMG
	IMAGE_TYPE=""
elif [ -n "$PG_IMG_FAMILY" ]; then
	IMAGE=$PG_IMG_FAMILY
	IMAGE_TYPE="-family"
else
    echo "Err: Env var PG_IMG or PG_IMG_FAMILY must be set"
    exit 2
fi

NAME=${1:-pg-primary}
ZONE=${2:-us-central1-a}
CLUSTER_NAME=$3
ETCD_ILB_FQDN=$4
MACHINE_TYPE=${5:-n2-standard-4}
SIZE=${6:-50}

if [[ $# -lt 4 ]]; then
    echo "$0 [instance name] [zone] [cluster name] [etcd endpoint ilb] opt[machine-type] opt[size]"
    exit 2
fi


SUBNET=default  #TODO - hardcoded for now because still using auto-network
REGION=$(gcloud compute zones describe $ZONE --format="value(region)")
REPLICATION_HOSTS_CIDR=$(gcloud compute networks subnets describe $SUBNET --region=$REGION --format="value(ipCidrRange)")
gcloud compute  instances create $NAME \
	--no-address \
	--zone=$ZONE \
	--machine-type=$MACHINE_TYPE \
	--image$IMAGE_TYPE=$IMAGE \
	--boot-disk-size=10GB \
	--boot-disk-type=pd-standard \
	--boot-disk-device-name=$NAME-os \
	--no-boot-disk-auto-delete \
	--create-disk=auto-delete=false,mode=rw,size=$SIZE,type=pd-ssd,name=$NAME-data,device-name=data \
	--tags=pg-patroni, \
	--labels=cluster=$CLUSTER_NAME \
	--scopes=https://www.googleapis.com/auth/compute.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/trace.append,https://www.googleapis.com/auth/devstorage.read_write \
	--metadata-from-file startup-script=bootstrap-pg.sh \
	--metadata=CLUSTER_NAME=$CLUSTER_NAME,ETCD_ILB_FQDN=$ETCD_ILB_FQDN,REPLICATION_HOSTS_CIDR=$REPLICATION_HOSTS_CIDR

# Create a zonal unmanaged instance group for the pg instances
# this is expected to fail if you are ading an instance to an existing zone
IG_NAME="$CLUSTER_NAME-$ZONE-ig"
gcloud compute instance-groups unmanaged create $IG_NAME --zone=$ZONE

## Add instances to instance group for zone 
gcloud compute instance-groups unmanaged add-instances $IG_NAME --instances=$NAME --zone=$ZONE
