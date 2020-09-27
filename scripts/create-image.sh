#!/bin/bash

#
# Before creating the image make sure that
# a. The /mnt/disks/pgdata is removed (the bootstrap scripts uses this to determin if needs to run)
# b. Remove the data disk entry from fstab (the bootstrap script should be the one that generates this)

# sudo systemctl stop postgresql
# sudo umount /mnt/disks/pgdata
# sudo rm -r /mnt/disks/pgdata
# sudo vim /etc/fstab
  
printf -v date '%(%Y%m%d%H%M)T\n' -1
gcloud compute instances stop $1 --zone us-central1-a
gcloud compute images create pg12-$date --source-disk=$1 --zone us-central1-a
