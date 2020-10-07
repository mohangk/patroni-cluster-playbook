#!/bin/bash

PG_IMAGE=pg12-202009270822
ZONE=${2:-us-central1-a}
NAME=${1:-pg-primary}
gcloud compute  instances create $NAME \
	--no-address \
	--zone=$ZONE \
	--machine-type=n2-standard-4 \
	--image=$PG_IMAGE \
	--boot-disk-size=10GB \
	--boot-disk-type=pd-standard \
	--boot-disk-device-name=$NAME-os \
	--no-boot-disk-auto-delete \
	--create-disk=auto-delete=false,mode=rw,size=50,type=projects/gcplabtest-286209/zones/us-central1-a/diskTypes/pd-ssd,name=$NAME-data,device-name=data \
	--tags=pg12, \
	--scopes=https://www.googleapis.com/auth/compute.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/trace.append,https://www.googleapis.com/auth/devstorage.read_write \
	--metadata-from-file startup-script=bootstrap-pg.sh
