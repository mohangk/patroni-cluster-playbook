#!/bin/bash

# $1 - name of the instance to create image from
# $2 - base name of the image

if [[ $# -ne 2 ]]; then
    echo "$0 [instance] [image family]"
    exit 2
fi

printf -v date '%(%Y%m%d%H%M)T\n' -1
ZONE=$(gcloud compute instances list --filter="labels.pgimage:true" --format="text" | grep zone: | cut -f9 -d\/ | xargs)
if [ -z $ZONE ]; then
    echo "couldn't fine image"
else
    gcloud compute instances stop $1 --zone $ZONE
    gcloud compute images create $2-$date --source-disk=$1 --family=$2-image --source-disk-zone=$ZONE
fi