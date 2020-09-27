#!/bin/bash

# Instance used to create a pg12 images

gcloud compute  instances create pg12-img \
	--no-address \
	--zone=us-central1-a \ 
	--machine-type=n2-standard-4 \
	--image-family=debian-10 \
	--image-project=debian-cloud \
	--boot-disk-size=10GB \
	--boot-disk-type=pd-standard \
	--boot-disk-device-name=pg12-img \ 
	--no-boot-disk-auto-delete \
	--create-disk=auto-delete=false,mode=rw,size=50,type=projects/gcplabtest-286209/zones/us-central1-a/diskTypes/pd-ssd,name=pg12-img-data,device-name=data \
	--tags=pg12,image \
	--scopes=https://www.googleapis.com/auth/compute.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/trace.append,https://www.googleapis.com/auth/devstorage.read_write \
	--metadata-from-file startup-script=bootstrap.sh
