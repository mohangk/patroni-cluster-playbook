#!/bin/bash

set -e

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root" >&2
	exit 1
fi

# Only support single disk setup for now. Should be sufficient on the cloud,
# as we can easily add new datacenter with larger disks.
disk="/dev/disk/by-id/google-data"
mountpoint="/data/mongodb"

echo "[init] Initializing mongodb..."

echo "[init] Getting metadata..."
result=$(curl -w "\n%{http_code}" -H "Metadata-Flavor: Google" "http://metadata.google.internal/computeMetadata/v1/instance/attributes/?recursive=true")
http_code=$(echo "${result}" | tail -n1)
metadata=$(echo "${result}" | head -n-1)

if [[ "${http_code}" != "200" ]]; then
	echo "[init] Failed to get metadata, response ${http_code}"
	exit 1
fi

# setup data dir
if [[ ! -d ${moutpoint} ]] ; then
	mkdir -p ${mountpoint}
fi

if grep -q ${mountpoint} /proc/mounts; then
	echo "[init] ${mountpoint} already mounted"
else
	# Hardcoded to use xfs for now.
	echo "[init] Using filesystem: xfs"

	if find ${mountpoint} -mindepth 1 -print -quit | grep -q .; then
		echo "[init] ${mountpoint} is not mounted but not empty" >&2
		exit 1
	fi
	mkfs.xfs ${disk} || echo "[init] Attempt to mount anyway"

	mount -o discard,noatime ${disk} ${mountpoint}
	echo "${disk} ${mountpoint} xfs discard,noatime 0 0" >> /etc/fstab

	chown mongodb:mongodb ${mountpoint}
fi

echo "[init] Starting mongodb..."
service mongod start
