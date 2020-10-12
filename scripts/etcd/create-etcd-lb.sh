# Create unmanaged instances groups for the etcd instances 
 gcloud compute instance-groups unmanaged create patroni-etcd-a --description="Zone A etcd IG that will be used by patroni" --zone=us-central1-a
 gcloud compute instance-groups unmanaged create patroni-etcd-b --description="etcd instace group that will be used by patroni" --zone=us-central1-b
gcloud compute instance-groups unmanaged add-instances patroni-etcd-a --instances=etcd1 --zone=us-central1-a



 gcloud compute instance-groups unmanaged add-instances patroni-etcd-b --instances=etcd2 --zone=us-central1-b
 gcloud compute instance-groups unmanaged set-named-ports patroni-etcd-a --named-ports=etcd:2379 --zone=us-central1-a
 gcloud compute instance-groups unmanaged set-named-ports patroni-etcd-b --named-ports=etcd:2379 --zone=us-central1-b

#Add firewall rule for the hc - allowing access to all targets to KISS
gcloud compute firewall-rules create fw-allow-health-check \
    --network=default \
    --action=allow \
    --direction=ingress \
    --source-ranges=130.211.0.0/22,35.191.0.0/16 \
    --rules=tcp


#Add the hc
gcloud compute health-checks create http patroni-etcd-hc \
	--port=2379 \
	--request-path=/health \
	--region=us-central1
       
#Add the etcd instance groups to a backend service       
gcloud compute backend-services create patroni-etcd-backend \
	--load-balancing-scheme=INTERNAL_MANAGED \
	--port-name=etcd \
	--protocol=HTTP \
	--region=us-central1 \
	--health-checks-region=us-central1 \
	--health-checks=patroni-etcd-hc

gcloud compute backend-services add-backend patroni-etcd-backend \
	--instance-group=patroni-etcd-a \
	--instance-group-zone=us-central1-a \
	--region=us-central1

gcloud compute backend-services add-backend patroni-etcd-backend \
	--instance-group=patroni-etcd-b \
	--instance-group-zone=us-central1-b \
	--region=us-central1

#Create the URL map, target-http-proxy and forwarding-rule for the regional internal HTTP LB
gcloud compute url-maps create patroni-etcd-map \
  --default-service=patroni-etcd-backend \
  --region=us-central1

gcloud compute target-http-proxies create patroni-etcd-proxy \
  --url-map=patroni-etcd-map \
  --url-map-region=us-central1 \
  --region=us-central1


# Will auto-generate the lb IP
# --subnet=backend-subnet -- required when using a custom mode network
gcloud compute forwarding-rules create patroni-etcd-fwding-rule \
  --load-balancing-scheme=INTERNAL_MANAGED \
  --network=default \
  --ports=80 \
  --region=us-central1 \
  --target-http-proxy=patroni-etcd-proxy \
  --target-http-proxy-region=us-central1



	

