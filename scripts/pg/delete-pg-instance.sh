if [[ $# -ne 2 ]]; then
    echo "$0 [instance name] [zone]"
    exit 2
fi

INSTANCE=$1
ZONE=$2

ssh $1 sudo systemctl stop patroni
gcloud compute instances delete $1 --zone $2 --quiet
gcloud compute disks delete $1 --zone $2 --quiet
gcloud compute disks delete $1-data --zone $2 --quiet
