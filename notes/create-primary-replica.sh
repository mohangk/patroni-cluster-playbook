#!/bin/bash

PG_IMAGE=pg12-202009270822
#gcloud compute  instances create pg-primary \
#	--no-address \
#	--zone=us-central1-a \
#	--machine-type=n2-standard-4 \
#	--image=$PG_IMAGE \
#	--boot-disk-size=10GB \
#	--boot-disk-type=pd-standard \
#	--boot-disk-device-name=pg12-osdisk \
#	--no-boot-disk-auto-delete \
#	--create-disk=auto-delete=false,mode=rw,size=50,type=projects/gcplabtest-286209/zones/us-central1-a/diskTypes/pd-ssd,name=pg-primary-data,device-name=data \
#	--tags=pg12,primary \
#	--scopes=https://www.googleapis.com/auth/compute.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/trace.append,https://www.googleapis.com/auth/devstorage.read_write \
#	--metadata-from-file startup-script=bootstrap-pg.sh

gcloud compute  instances create pg-replica \
	--no-address \
	--zone=us-central1-a \
	--machine-type=n2-standard-4 \
	--image=$PG_IMAGE \
	--boot-disk-size=10GB \
	--boot-disk-type=pd-standard \
	--boot-disk-device-name=pg12-osdisk \
	--no-boot-disk-auto-delete \
	--create-disk=auto-delete=false,mode=rw,size=50,type=projects/gcplabtest-286209/zones/us-central1-a/diskTypes/pd-ssd,name=pg-replica-data,device-name=data \
	--tags=pg12,replica \
	--scopes=https://www.googleapis.com/auth/compute.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/trace.append,https://www.googleapis.com/auth/devstorage.read_write \
	--metadata-from-file startup-script=bootstrap-pg.sh
