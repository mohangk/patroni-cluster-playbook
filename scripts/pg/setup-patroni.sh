sudo apt-get install python3-pip python3-psycopg2
sudo pip3 install patroni[etcd]

cp patroni.service to /etc/systemd/system/patroni.service

mkdir /etc/patroni
cp pg-patroni-1.yml to /etc/patroni/patroni.yml
chown -R postgres:postgres /etc/patroni

#In psql
CREATE USER replicator WITH REPLICATION ENCRYPTED PASSWORD 'password'
ALTER USER postgres WITH ENCRYPTED PASSWORD 'password'


Questions:

1. What is the point of the user section of bootstrap? Should it just be create postgres user?


