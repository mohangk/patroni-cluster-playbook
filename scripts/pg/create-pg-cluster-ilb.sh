#!/bin/bash

##Cluster level setup

# Dependency - create-pg-healthcheck.sh should of already been run as the health checks are required to setup the backend services 

CLUSTER_NAME=$1
REGION=${2:-us-central1}
ROLES="primary replica"

for ROLE in $ROLES; do
	BE_SVC="$CLUSTER_NAME-$ROLE-backend"
	FWD_RULE="$CLUSTER_NAME-$ROLE-fwding-rule"

	# 1. Create backend-service
	gcloud compute backend-services create $BE_SVC \
		--load-balancing-scheme=INTERNAL \
		--protocol=TCP \
		--region=$REGION \
		--health-checks-region=$REGION \
		--health-checks=patroni-pg-primary-hc

	#2. Create forwarding rules for backend-service
	gcloud compute forwarding-rules create $FWD_RULE\
	  --load-balancing-scheme=INTERNAL \
	  --network=default \
	  --ports=5432 \
	  --region=$REGION \
	  --backend-service=$BE_SVC \
	  --backend-service-region=$REGION
done
