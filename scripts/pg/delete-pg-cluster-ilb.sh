#!/bin/bash

##Cluster level setup
CLUSTER_NAME=$1
REGION=${2:-us-central1}
ROLES="primary replica"

if [[ $# -lt 1 ]]; then
    echo "$0 [cluster name] [region]"
    exit 2
fi


#2 Delete the fwding rule, backend services
for ROLE in $ROLES; do
	BE_SVC="$CLUSTER_NAME-$ROLE-be"
	FWD_RULE="$CLUSTER_NAME-$ROLE-fw"

	#1. Delete forwarding rules for backend-service
	gcloud compute forwarding-rules delete $FWD_RULE\
	  --region=$REGION --quiet
	#2. Delete backend-service
	gcloud compute backend-services delete $BE_SVC \
		--region=$REGION --quiet
done

#3. Delete the instance-groups
ZONES=$(gcloud compute instances list --filter="labels.cluster:$CLUSTER_NAME" --format="value[terminator=' '](zone)")
for ZONE in $ZONES; do
	IG_NAME="$CLUSTER_NAME-$ZONE-ig"
	gcloud compute instance-groups unmanaged delete $IG_NAME --zone=$ZONE --quiet
done


#1. Delete failover instance group to fail closed, in case all instance in a pool fail
FAILOVER=$CLUSTER_NAME-failover
gcloud compute instance-groups managed delete $FAILOVER --region=us-central1 --quiet
gcloud compute instance-templates delete $FAILOVER-template --quiet
