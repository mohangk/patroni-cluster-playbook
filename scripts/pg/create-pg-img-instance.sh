#!/bin/bash

# Instance used to create a pg images

NAME=${1:-pg-img}
REGION=${2:-us-central1}

gcloud compute  instances create $NAME \
	--no-address \
	--zone=$REGION-a \
	--machine-type=n2-standard-2 \
	--image-family=debian-10 \
	--image-project=debian-cloud \
	--boot-disk-size=10GB \
	--boot-disk-type=pd-standard \
	--boot-disk-device-name=$NAME \
	--no-boot-disk-auto-delete \
	--tags=$NAME,image \
	--labels=pgimage=true \
	--scopes=https://www.googleapis.com/auth/compute.readonly,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring.write,https://www.googleapis.com/auth/trace.append,https://www.googleapis.com/auth/devstorage.read_write \

echo "$NAME"
