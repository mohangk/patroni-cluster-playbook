#!/bin/sh

apt-get update && apt-get install -y nginx-light

cat << EOF > /etc/nginx/sites-available/default
server {
        listen 8008 default_server;
        access_log  off;
        location / {
                return 200;
        }
}

server {
        listen 8009 default_server;
        access_log  off;
        location / {
                return 200;
        }
}
EOF
systemctl restart nginx.service

# Reject traffic to postgres or pgpouncer to reset the connection
iptables -A INPUT -p tcp -m tcp --dport 5432 -j LOG
iptables -A INPUT -p tcp -m tcp --dport 5432 -j REJECT --reject-with icmp-port-unreachable
iptables -A INPUT -p tcp -m tcp --dport 6432 -j LOG
iptables -A INPUT -p tcp -m tcp --dport 6432 -j REJECT --reject-with icmp-port-unreachable