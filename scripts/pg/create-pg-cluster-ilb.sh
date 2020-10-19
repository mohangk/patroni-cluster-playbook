#!/bin/bash

##Cluster level setup

# Dependency - create-pg-healthcheck.sh should of already been run as the health checks are required to setup the backend services 

CLUSTER_NAME=$1
REGION=${2:-us-central1}
ROLES="primary replica"

if [[ $# -lt 1 ]]; then
    echo "$0 [cluster name] [region]"
    exit 2
fi

for ROLE in $ROLES; do
	BE_SVC="$CLUSTER_NAME-$ROLE"
	FWD_RULE="$CLUSTER_NAME-$ROLE"

	# 1. Create backend-service
	gcloud compute backend-services create $BE_SVC \
		--load-balancing-scheme=INTERNAL \
		--protocol=TCP \
		--region=$REGION \
		--global-health-checks \
		--health-checks=$CLUSTER_NAME-$ROLE-hc

	#2. Create forwarding rules for backend-service
	gcloud compute forwarding-rules create $FWD_RULE\
	  --load-balancing-scheme=INTERNAL \
	  --network=default \
	  --ports=5432,6432 \
	  --region=$REGION \
	  --backend-service=$BE_SVC \
	  --backend-service-region=$REGION
done

#3. List the cluster members based on the cluster label to determine which region and zone they are deployed in
ZONES=$(gcloud compute instances list --filter="labels.cluster:$CLUSTER_NAME" --format="text" | grep zone: | cut -f9 -d\/ | xargs)
for ROLE in $ROLES; do
	BE_SVC="$CLUSTER_NAME-$ROLE"
	for ZONE in $ZONES; do
		IG_NAME="$CLUSTER_NAME-$ZONE-ig"
		gcloud compute backend-services add-backend $BE_SVC \
		--region=$REGION \
		--instance-group=$IG_NAME \
		--instance-group-zone=$ZONE
	done
done

#4. Create a failover instance group to fail closed, in case all instance in a pool fail
FAILOVER=$CLUSTER_NAME-failover
gcloud compute instance-templates create $FAILOVER-template \
--machine-type=e2-small \
--network=default --no-address \
--metadata-from-file startup-script=failover-pg.sh \
--no-service-account --no-scopes \
--tags=$CLUSTER_NAME \
--image-family=debian-10 \
--image-project=debian-cloud \
--boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=$CLUSTER_NAME-template \
--labels=cluster=$CLUSTER_NAME

gcloud compute instance-groups managed create $FAILOVER \
--base-instance-name=$FAILOVER \
--template=$FAILOVER-template \
--size=1 \
--region=$REGION \
--health-check=$CLUSTER_NAME-primary-hc \
--initial-delay 60 \
--instance-redistribution-type=PROACTIVE

#5. Attach failover group to ILB
for ROLE in $ROLES; do
	BE_SVC="$CLUSTER_NAME-$ROLE-backend"
	gcloud compute backend-services add-backend $BE_SVC \
		--region=$REGION \
		--instance-group-region=$REGION \
		--instance-group=$FAILOVER \
		--failover
done
