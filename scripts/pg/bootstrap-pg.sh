#!/bin/bash
set -euxo pipefail

MNT_DIR=/mnt/disks/pgdata
DISK_ID=/dev/disk/by-id/google-data

#If $MNT_DIR already exists, we assume its already bootstrapped
if [[ -d "$MNT_DIR" ]]; then
        exit
else 
        sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard $DISK_ID; \
        sudo mkdir -p $MNT_DIR
        sudo mount -o discard,defaults $DISK_ID $MNT_DIR
	sudo chown postgres:postgres /mnt/disks/pgdata

        # Add fstab entry
        echo UUID=`sudo blkid -s UUID -o value $DISK_ID` $MNT_DIR ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
	
	#Initialize the Patroni config
        HOST_IP=$(curl -s http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip -H "Metadata-Flavor: Google")
        HOSTNAME=$(hostname)
        ETCD_ILB_IP=10.128.0.25
        CLUSTER_NAME='pg-patroni2'
        sed -i "s/\$CLUSTER_NAME/$CLUSTER_NAME/g" /etc/systemd/system/patroni.service
        sed -i "s/\$HOSTNAME/$HOSTNAME/g" /etc/systemd/system/patroni.service
        sed -i "s/\$ETCD_ILB_IP/$ETCD_ILB_IP/g" /etc/systemd/system/patroni.service
        sed -i "s/\$HOST_IP/$HOST_IP/g" /etc/systemd/system/patroni.service

	systemctl daemon-reload
	systemctl enable patroni
	systemctl start patroni

fi
