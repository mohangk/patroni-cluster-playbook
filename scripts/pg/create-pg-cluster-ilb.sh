#!/bin/bash

##Cluster level setup

# Dependency - create-pg-healthcheck.sh should of already been run as the health checks are required to setup the backend services 

CLUSTER_NAME=$1
REGION=${2:-us-central1}
ROLES="primary replica"

if [[ $# -ne 2 ]]; then
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
		--health-checks-region=$REGION \
		--health-checks=patroni-pg-$ROLE-hc

	#2. Create forwarding rules for backend-service
	gcloud compute forwarding-rules create $FWD_RULE\
	  --load-balancing-scheme=INTERNAL \
	  --network=default \
	  --ports=5432 \
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
