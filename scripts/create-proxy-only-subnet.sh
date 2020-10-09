# Create proxy only subnet and the firewall rule to allow those proxies to access backends
gcloud compute networks subnets create proxy-only-subnet \
	--purpose=INTERNAL_HTTPS_LOAD_BALANCER \
	--role=ACTIVE \
	--region=us-central1 \
	--network=default \
	--range=10.127.0.0/20

# Leaving it quite open to keep things simple
gcloud compute firewall-rules create fw-allow-proxies \
  --network=default \
  --action=allow \
  --direction=ingress \
  --source-ranges=10.127.0.0/20 \
  --rules=tcp


