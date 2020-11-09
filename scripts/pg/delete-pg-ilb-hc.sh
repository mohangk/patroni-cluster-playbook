#! /bin/bash
CLUSTER=$1

if [[ $# -ne 1 ]]; then
    echo "$0 [cluster name]"
    exit 2
fi

gcloud compute health-checks delete http $CLUSTER-primary-hc 
gcloud compute health-checks delete http $CLUSTER-replica-hc 
