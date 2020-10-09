#!/bin/bash

  
printf -v date '%(%Y%m%d%H%M)T\n' -1
gcloud compute instances stop $1 --zone us-central1-a
gcloud compute images create pg12-$date --source-disk=$1 --zone us-central1-a
