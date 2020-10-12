#!/bin/bash

# $1 - name of the instance to create image from
# $2 - base name of the image
printf -v date '%(%Y%m%d%H%M)T\n' -1
gcloud compute instances stop $1 --zone us-central1-a
gcloud compute images create $2-$date --source-disk=$1 #--zone=us-central1-a
