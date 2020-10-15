## project wide setup
#Add firewall rule for the hc - allowing access to all targets to KISS
gcloud compute firewall-rules create fw-allow-health-check \
    --network=default \
    --action=allow \
    --direction=ingress \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --rules=tcp

#Add the primary hc
gcloud compute health-checks create http patroni-pg-primary-hc \
	--port=8008 \
	--request-path=/master \
	--region=us-central1
      
#Add the replica hc
gcloud compute health-checks create http patroni-pg-replica-hc \
	--port=8008 \
	--request-path=/replica \
	--region=us-central1
