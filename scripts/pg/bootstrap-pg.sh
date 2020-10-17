#!/bin/bash
set -euxo pipefail

MNT_DIR=/mnt/disks/pgdata
DISK_ID=/dev/disk/by-id/google-data

#If $MNT_DIR already exists, we assume its already bootstrapped
if [[ -d "$MNT_DIR" ]]; then
        echo "Disk mounted, continuing setup"
else 
        sudo mkfs.ext4 -m 0 -F -E lazy_itable_init=0,lazy_journal_init=0,discard $DISK_ID; \
        sudo mkdir -p $MNT_DIR
        sudo mount -o discard,defaults $DISK_ID $MNT_DIR
	sudo chown postgres:postgres /mnt/disks/pgdata

        # Add fstab entry
        echo UUID=`sudo blkid -s UUID -o value $DISK_ID` $MNT_DIR ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
fi

if (systemctl -q is-active patroni.service); then
        echo "Patroni setup, exiting"
else
	#Initialize the Patroni config
        HOSTNAME=$(hostname)
        HOST_IP=$(curl -s http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip -H "Metadata-Flavor: Google")
        ETCD_ILB_FQDN=$(curl -s http://metadata/computeMetadata/v1/instance/attributes/ETCD_ILB_FQDN -H "Metadata-Flavor: Google")
        CLUSTER_NAME=$(curl -s http://metadata/computeMetadata/v1/instance/attributes/CLUSTER_NAME -H "Metadata-Flavor: Google")
        REPLICATION_HOSTS_CIDR=$(curl -s http://metadata/computeMetadata/v1/instance/attributes/REPLICATION_HOSTS_CIDR -H "Metadata-Flavor: Google")
        PGVERSION=$(ls /usr/lib/postgresql/ | head -n1)
	cp /etc/patroni/patroni.yml.tmpl /etc/patroni/patroni.yml

        sed -i "s/\$HOST_IP/$HOST_IP/g" /etc/patroni/patroni.yml
        sed -i "s/\$HOSTNAME/$HOSTNAME/g" /etc/patroni/patroni.yml
        sed -i "s/\$ETCD_ILB_FQDN/$ETCD_ILB_FQDN/g" /etc/patroni/patroni.yml
        sed -i "s/\$CLUSTER_NAME/$CLUSTER_NAME/g" /etc/patroni/patroni.yml
        sed -i "s|\$REPLICATION_HOSTS_CIDR|$REPLICATION_HOSTS_CIDR|g" /etc/patroni/patroni.yml #use a different delimeter as / is in the var
        sed -i "s/\$PGVERSION/$PGVERSION/g" /etc/patroni/patroni.yml

	systemctl daemon-reload
	systemctl enable patroni
	systemctl start patroni
fi

