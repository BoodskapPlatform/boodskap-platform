# Boodskap IoT Platform

This documentation covers setting up the platform in Ubuntu server 64Bit, 16.04 and 18.04 LTS Editions.
To run a clustered platform, you need 4 machines with the following configuration. 

* 3 Machines with 8GB RAM, 8GB SWAP, 32GB HDD (SSD preferred)
    * This machine will host the Platform and other services like MQTT, Cassandra, Elasticsearch, etc..
* 1 Machine with 4GB RAM, 4GB SWAP, 16GB HDD (SSD preferred)
    * This machine will have Nginx, NFS & HAProxy servers configured

## Installation Instructions

From now on, we shall call the 3 machines as nodes, and the 4th machine as gateway. Make sure all the machines stays in the same local network. The IP address used here are for reference only, you could replace them with your network configuration

* gateway (192.168.1.5)
* node1 (192.168.1.7)
* node2 (192.168.1.8)
* node3 (192.168.1.9)

You need to have 3 public DNS records pointing to the **gateway** machine's public IP address. We use the below DNS names as a reference

* platform.boodskap.io
* gw.boodskap.io
* api.boodskap.io

On **all** machines, create the below users

````console
sudo apt-get update
sudo apt-get upgrade
sudo adduser --disabled-password --gecos ""  boodskap
sudo apt-get -y install unzip python build-essential libgtk2.0-dev imagemagick
````

Install JDK 8 On **all** machines
We prefer Oracle JDK (**not JRE**). At the time of writing Oracle 8 JDK's can be found here 

[Oracle JDKs](http://www.oracle.com/technetwork/java/javase/downloads/jdk8-downloads-2133151.html)

###### On Ubutu machines (tested on 18.04)
````console
sudo add-apt-repository ppa:webupd8team/java
sudo apt-get update
sudo apt-get -y install oracle-java8-installer
sudo npm -g install pm2
````

Edit /etc/profile

````console
sudo nano /etc/profile
````

Add the below statements and save

````
BOODSKAP_HOME=/home/boodskap
````

On **nodes 1-3** machines, create the below users

````console
sudo adduser --disabled-password --gecos ""  elastic
sudo adduser --disabled-password --gecos ""  cassandra
sudo adduser --disabled-password --gecos ""  kibana 
sudo adduser --disabled-password --gecos ""  emqtt
````

On **gateway** machine, create the below user and perform the tasks

````console
sudo su - boodskap
mkdir -p $HOME/data/share/platform
````

### NFS Server/Client Setup
In the **gateway** machine, perform the below operations.

````console
sudo apt-get -y install nfs-kernel-server
````

Edit the exports file

````console
sudo nano /etc/exports 
````

Insert the below at the end of file and save

````
/home/boodskap/data/share       192.168.1.0/24(rw,sync,no_root_squash,no_subtree_check)
````

Restart NFS server

````console
sudo service nfs-server restart
````

On **nodes 1-3** machines, perform the below operations.

````console
sudo apt-get -y install nfs-common
````

Edit the /etc/fstab file

````console
sudo nano /etc/fstab
````

All the below content and save

````
192.168.1.5:/home/boodskap/data/share /home/boodskap/data/share nfs auto,nofail,noatime,nolock,intr,tcp,actimeo=1800 0 0
````

Mount the drive

````console
sudo mount -a
````

### Cassandra Server Setup

On **nodes 1-3** machines, perform the below operations.
	
Download cassandara and configure

````console
sudo su - cassandra
wget https://archive.apache.org/dist/cassandra/3.11.0/apache-cassandra-3.11.0-bin.tar.gz
tar -xzf apache-cassandra-3.11.0-bin.tar.gz
mv apache-cassandra-3.11.0/* .
rm -rf apache-cassandra-3.11.0
````

Edit configuration and change the below parameters

````
nano $HOME/conf/cassandra.yaml 
cluster_name: 'BSKP DB CLUSTER'
- seeds: "192.168.1.7,192.168.1.8,192.168.1.9"
listen_address: 192.168.1.[7|8|9]
rpc_address: 192.168.1.[7|8|9]
endpoint_snitch: GossipingPropertyFileSnitch
auto_bootstrap: false
````

Save the file

###### Start Cassandra
````console
$HOME/bin/cassandra
````

### ElasticSearch Server Setup

On **nodes 1-3** machines, perform the below operations.

Download ElasticSearch and configure

````console
sudo su - elastic
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.5.0.tar.gz
tar -xzf elasticsearch-5.5.0.tar.gz
mv elasticsearch-5.5.0/* .
rm -rf elasticsearch-5.5.0
````

Edit configuration and change the below parameters

````console
nanoe $HOME/config/elastic.yml
````

````
cluster.name: bskp-es-cluster
node.name: node-[1 | 2 | 3]
network.host: 192.168.1.[7 | 8 | 9]
discovery.zen.ping.unicast.hosts: ["192.168.1.7", "192.168.1.8", "192.168.9"]
````

** To further tune the ElasticSearch, please refer to **
[ElasticSearch Tuning](https://documentation.wazuh.com/3.x/installation-guide/optional-configurations/elastic-tuning.html)
    
Save the file

###### Start Elastic Search
````console
$HOME/bin/elasticsearch &
````

### Kibana Server Setup (optional)

On **nodes 1-3** machines, perform the below operations.

Download and configure

````console
sudo su - kibana
wget https://artifacts.elastic.co/downloads/kibana/kibana-5.5.0-linux-x86_64.tar.gz
tar -xzf kibana-5.5.0-linux-x86_64.tar.gz
mv kibana-5.5.0-linux-x86_64/* .
rm -rf kibana-5.5.0-linux-x86_64
````

Edit the config file and change

````console
nano config/kibana.yml
````

````
server.host: "0.0.0.0"
elasticsearch.url: http://192.168.1.[7|8|9]:9200"
````
Save the ile

###### Start Kibana
````console
$HOME/bin/kibana &
````

### MQTT Server Setup

Download and configure

````console
sudo su - emqtt
wget --no-check-certificate  https://www.emqx.io/static/brokers/emqttd-ubuntu16.04-v2.3.9.zip
unzip emqttd-ubuntu16.04-v2.3.9.zip
mv emqttd/* .
rm -rf emqttd
````

Edit config file and change the below parameters

````console
nano $HOME/etc/emq.conf
````

````
cluster.name = bskp-emqcl
cluster.discovery = static
cluster.static.seeds = emq@192.168.1.7,emq@192.168.1.8,emq@192.168.1.9
node.name = emq@192.168.1.[7 | 8 | 9]
node.process_limit = 2097152
node.max_ports = 1048576
log.console = file
log.console.level = info
log.console.file = log/emqtt.log
mqtt.allow_anonymous = false
mqtt.acl_nomatch = deny
listener.tcp.external = 0.0.0.0:1883
listener.tcp.external.acceptors = 64
listener.tcp.external.max_clients = 1000000
listener.tcp.external.access.1 = allow 192.168.1.0/24
listener.tcp.internal = 127.0.0.1:11883
listener.tcp.internal.acceptors = 32
listener.ws.external = 8080
listener.ws.external.acceptors = 64
listener.ws.external.max_clients = 1000000
listener.ws.external.access.1 = allow 192.168.1.0/24
listener.api.mgmt = 127.0.0.1:9090
listener.api.mgmt.access.1 = allow 192.168.1.0/24
````

Edit the pluggable auth configuration and change the below parameters

````console
nano $HOME/etc/plugins/emq_auth_http.conf
````

````
auth.http.auth_req = https://api.boodskap.io/emqtt/get/auth
auth.http.auth_req.method = get
auth.http.auth_req.params = clientid=%c,username=%u,password=%P,ipaddr=a%

auth.http.super_req = https://api.boodskap.io/emqtt/get/superuser
auth.http.super_req.method = get
auth.http.super_req.params = clientid=%c,username=%u,ipaddr=%a

auth.http.acl_req = https://api.boodskap.io/emqtt/acl
auth.http.acl_req.method = get
auth.http.acl_req.params = access=%A,username=%u,clientid=%c,ipaddr=%a,topic=%t
````

** To run a very high scalable MQTT, please refer to **
[EMQTT Tuning](http://emqtt.io/docs/v2/tune.html)

###### /etc/sysctl.conf

````console
fs.file-max=2097152
fs.nr_open=2097152
net.core.somaxconn=32768
net.ipv4.tcp_max_syn_backlog=16384
net.core.netdev_max_backlog=16384
net.ipv4.ip_local_port_range=1024 65535
net.core.rmem_default=262144
net.core.wmem_default=262144
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.core.optmem_max=16777216

net.ipv4.tcp_mem=16777216 16777216 16777216
# net.ipv4.tcp_rmem=1024 4096 16777216
# net.ipv4.tcp_wmem=1024 4096 16777216
net.nf_conntrack_max=1000000
net.netfilter.nf_conntrack_max=1000000
net.netfilter.nf_conntrack_tcp_timeout_time_wait=30
net.ipv4.tcp_max_tw_buckets=1048576

# Enable fast recycling of TIME_WAIT sockets.  Enabling this
# option is not recommended for devices communicating with the
# general Internet or using NAT (Network Address Translation).
# Since some NAT gateways pass through IP timestamp values, one
# IP can appear to have non-increasing timestamps.
# net.ipv4.tcp_tw_recycle = 1
# net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_fin_timeout = 15

vm.max_map_count = 262144
````

###### load module ip_conntrack

````console
echo "ip_conntrack" | sudo tee -a /etc/modules
````

###### /etc/security/limits.conf
````
*      soft   nofile      1048576
*      hard   nofile      1048576
````

###### Load the changes and start MQTT

````console
sudo modprobe ip_conntrack
sudo sysctl -p
$HOME/bin/emqttd start
$HOME/bin/emqttd_ctl plugins load emq_auth_http
````

### Nginx Server Setup

In the **gateway** machine, perform the below operations.

````console
sudo apt-get install nginx
cd /etc/nginx/sites-enabled
rm default
````

Copy paste the below configuration under 

###### File: /etc/nginx/sites-enabled/common.boodskap.io 
````
proxy_cache_path /tmp/NGINX_cache/ keys_zone=backcache:10m;

map $http_upgrade $connection_upgrade {
    default upgrade;
    ''      close;
}
````

###### File: /etc/nginx/sites-enabled/api.boodskap.io 

````
upstream api_cluster {
    # Use IP Hash for session persistence
    #ip_hash;
    least_conn;

    # List of boodskap servers
    server 192.168.1.7:18080;
    server 192.168.1.8:18080;
    server 192.168.1.9:18080;
}

upstream micro_service_cluster {
    # Use IP Hash for session persistence
    #ip_hash;
    least_conn;

    server 192.168.1.7:19090;
    server 192.168.1.8:19090;
    server 192.168.1.9:19090;
}


server {
    listen 80;
    server_name api.boodskap.io;

    client_max_body_size 32M;

    location /spec/ {
        root /usr/share/nginx/api/;
        autoindex on;
    }

    location /mservice/ {
    
        proxy_pass http://micro_service_cluster;
        proxy_redirect  off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-NginX-Proxy true;
        proxy_ssl_session_reuse off;
        proxy_cache backcache;
    }

    # Load balance requests for /api/ across Boodskap servers
    location / {

     if ($request_method = 'OPTIONS') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, DELETE, PUT, OPTIONS';
        #
        # Custom headers and headers various browsers *should* be OK with but aren't
        #
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
        #
        # Tell client that this pre-flight info is valid for 20 days
        #
        add_header 'Access-Control-Max-Age' 1728000;
        add_header 'Content-Type' 'text/plain; charset=utf-8';
        add_header 'Content-Length' 0;
        return 200;
     }

     if ($request_method = 'POST') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
     }

     if ($request_method = 'GET') {
        add_header 'Access-Control-Allow-Origin' '*';
        add_header 'Access-Control-Allow-Methods' 'GET, POST, OPTIONS';
        add_header 'Access-Control-Allow-Headers' 'DNT,User-Agent,X-Requested-With,If-Modified-Since,Cache-Control,Content-Type,Range';
        add_header 'Access-Control-Expose-Headers' 'Content-Length,Content-Range';
     }

        proxy_pass http://api_cluster;
        proxy_redirect  off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-NginX-Proxy true;
        proxy_ssl_session_reuse off;
        proxy_cache backcache;
    }

}
````

###### File: /etc/nginx/sites-enabled/gw.boodskap.io 

````
upstream mqttws_cluster {
    # Use IP Hash for session persistence
    #ip_hash;
    least_conn;

    # List of emqtt servers
    server 192.168.1.7:8083;
    server 192.168.1.8:8083;
    server 192.168.1.9:8083;
}


server {
    listen 80;
    server_name gw.boodskap.io;

    # Load balance requests for /voice-api/ across Boodskap servers
    location / {

        proxy_pass http://api_cluster;
        proxy_redirect  off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-NginX-Proxy true;
        proxy_ssl_session_reuse off;
        proxy_cache backcache;
    }

}

server {
    listen 8083;
    server_name gw.boodskap.io;

    location / {

        proxy_pass http://mqttws_cluster;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_redirect  off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-NginX-Proxy true;
        proxy_ssl_session_reuse off;
        proxy_cache backcache;
    }

}
````

###### File: /etc/nginx/sites-enabled/platform.boodskap.io 

````
upstream dashboard_cluster {
    # Use IP Hash for session persistence
    #ip_hash;
    least_conn;

    # List of nodejs application servers
    server 192.168.1.5:4201;
}

server {
    listen 80;
    server_name platform.boodskap.io;

    # Load balance requests for /dashboard/ across NodeJS application servers
    location / {

        proxy_pass http://dashboard_cluster;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-NginX-Proxy true;
        proxy_ssl_session_reuse off;
        proxy_cache backcache;
    }
}
````
###### File: /etc/nginx/sites-enabled/kibana.boodskap.io 

````
upstream kibana_cluster {
    # Use IP Hash for session persistence
    #ip_hash;
    least_conn;

    # List of boodskap servers
    server 192.168.1.7:5601;
    server 192.168.1.8:5601;
    server 192.168.1.9:5601;
}


server {
    listen 80;
    server_name kibana.boodskap.io;

    location / {

        #auth_basic           "Administrator’s Area";
        #auth_basic_user_file /etc/nginx/.htpasswd;

        proxy_pass http://kibana_cluster;
        proxy_redirect  off;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-NginX-Proxy true;
        proxy_ssl_session_reuse off;
        proxy_cache backcache;
    }

}
````

### HAProxy Server Setup

In the **gateway** machine, perform the below operations.

````console
sudo apt-get install haproxy
````

Edit /etc/haproxy/haproxy.cfg and make sure the following settings are changed/created

````
global
  ulimit-n 8000016
  maxconn 2000000
  maxpipes 2000000
  tune.maxaccept 500
        
listen mqtt
  bind *:1883
  mode tcp
  option clitcpka # For TCP keep-alive
  timeout client 3h #By default TCP keep-alive interval is 2hours in OS kern$
  timeout server 3h #By default TCP keep-alive interval is 2hours in OS kern$
  option tcplog
  balance roundrobin
  server node1 192.168.1.7:1883 check
  server node2 192.168.1.8:1883 check
  server node3 192.168.1.9:1883 check
````

### Boodskap IoT Platform Setup
