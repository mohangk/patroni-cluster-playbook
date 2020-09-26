#!/bin/bash
set -euxo pipefail

MNT_DIR=/mnt/disks/pgdata
DISK_ID=/dev/disk/by-id/google-data

if [[ -d "$MNT_DIR" ]]; then
        exit
else 
        sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard $DISK_ID; \
        sudo mkdir -p $MNT_DIR
        sudo mount -o discard,defaults $DISK_ID $MNT_DIR

        # Add fstab entry
        echo UUID=`sudo blkid -s UUID -o value $DISK_ID` $MNT_DIR ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
fi
