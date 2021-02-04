
## Create the PostgreSQL image
1. Copy over the required files to the image instance
```bash
gcloud compute scp patroni.yml.tmpl pg-img:~
gcloud compute scp patroni.service pg-img:~
```

## Following is executed on the instance
### Installing postgresql

# Add system properties for "add-apt-repository" tool
```bash
sudo apt-get install -yq software-properties-common
```

# Add PostgreSQL repo key
curl -q https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

# Add the Postgresql repo
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

# Update the package list
sudo apt-get update

#Install the debian postgresql-common package that handles the initialisation scripts
sudo apt-get install postgresql-common

#Disable the creation of clusters on install of the pg packages
sudo sed -i 's/#create_main_cluster = true/create_main_cluster = false/g' /etc/postgresql-common/createcluster.conf

#Install postgresql 13 packages
sudo apt-get install postgresql-13
sudo apt-get install postgresql-client-13
sudo apt-get install postgresql-contrib-13

### Installing patroni
# Add python dependencies
sudo apt-get install -yq python3-pip
sudo apt-get install -yq python3-psycopg2

#install patroni
sudo pip3 install patroni[etcd]==2.0.1

#scp the patroni systemd service file
sudo cp ~/patroni.service /etc/systemd/system/patroni.service

#setup the patroni config file
sudo mkdir /etc/patroni
sudo cp ~/patroni.yml.tmpl /etc/patroni/patroni.yml.tmpl
sudo chmod 644  /etc/patroni/patroni.yml.tmpl
sudo chown postgres.postgres -R /etc/patroni

## Create an image from the pg-img vm
./create-image.sh pg-img pg13

## Create an instance from the pg-img image
PG_IMAGE=pg12-202010100000 ./create-pg-instance.sh pg-patroni-1 us-central1-a pg-patroni 10.128.0.25:80

- use the new etcd cluster
- allow subnet to be passed in (use the custom network)


