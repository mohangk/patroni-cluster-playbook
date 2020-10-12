#!/bin/bash

# Instance used to create a pg12 images

NAME=${1:-pg12-img}
gcloud compute  instances create $NAME \
	--no-address \
	--zone=us-central1-a \
	--machine-type=n2-standard-4 \
	--image-family=debian-10 \
	--image-project=debian-cloud \
	--boot-disk-size=10GB \
	--boot-disk-type=pd-standard \
	--boot-disk-device-name=pg12-img \
	--no-boot-disk-auto-delete \
	--tags=pg12,image \
	--scopes=https://www.googleapis.com/auth/compute.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/trace.append,https://www.googleapis.com/auth/devstorage.read_write \

echo "$NAME"
