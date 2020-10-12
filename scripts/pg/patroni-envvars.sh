export PATRONI_SCOPE= pg-patroni #TODO move to metadata
export PATRONI_NAME=`hostname` #name
IP=$(curl -s http://metadata/computeMetadata/v1/instance/network-interfaces/0/ip -H "Metadata-Flavor: Google")
export PATRONI_ETCD_HOST=10.128.0.25:80 #TODO - move to metadata
export PATRONI_RESTAPI_CONNECT_ADDRESS=$IP:8008
export PATRONI_POSTGRESQL_CONNECT_ADDRESS=$IP:5432


