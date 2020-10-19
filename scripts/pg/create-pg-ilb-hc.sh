## project wide setup

CLUSTER=$1

if [[ $# -ne 1 ]]; then
    echo "$0 [cluster name]"
    exit 2
fi

#Add firewall rule for the hc - allowing access to all targets to KISS
gcloud compute firewall-rules create fw-allow-health-check \
    --network=default \
    --action=allow \
    --direction=ingress \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --rules=tcp

#Add the primary hc
gcloud compute health-checks create http $CLUSTER-primary-hc \
	--port=8008 \
	--request-path=/primary \
	--check-interval="2s" \
	--timeout="2s" \
	--global
      
#Add the replica hc, the lag value is customisable as required
#The port is different as nginx needs to rewrite to query string
gcloud compute health-checks create http $CLUSTER-replica-hc \
	--port=8009 \
	--request-path=/replica/lag/100MB \
	--check-interval="2s" \
	--timeout="2s" \
	--global
