#!/bin/bash

sudo apt-get update
sudo apt-get upgrade -y
sudo apt-get install -y --fix-missing nfs-kernel-server python unzip nginx software-properties-common wget sudo nano net-tools telnet netcat git curl psmisc build-essential libgtk2.0-dev imagemagick
sudo adduser --disabled-password --gecos ""  boodskap
sudo adduser --disabled-password --gecos ""  elastic
sudo adduser --disabled-password --gecos ""  cassandra
sudo adduser --disabled-password --gecos ""  kibana 
sudo adduser --disabled-password --gecos ""  emqtt
sudo adduser --disabled-password --gecos ""  boodskapui

sudo echo "boodskap ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/boodskap
sudo echo "cassandra ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/cassandra
sudo echo "elastic ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/elastic
sudo echo "kibana ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/kibana
sudo echo "emqtt ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/emqtt
sudo echo "boodskapui ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/boodskapui

sudo add-apt-repository -y ppa:openjdk-r/ppa
sudo apt-get update -y
sudo apt-get install -y openjdk-8-jdk
sudo update-alternatives --config java

sudo echo CASSANDRA_HOME=/home/cassandra >> /etc/profile
sudo echo ELASTIC_HOME=/home/cassandra >> /etc/profile
sudo echo KIBANA_HOME=/home/kibana >> /etc/profile
sudo echo EMQTTD_HOME=/home/emqtt >> /etc/profile
sudo echo IGNITE_HOME=/home/boodskap >> /etc/profile
sudo echo BOODSKAP_HOME=/home/boodskap >> /etc/profile
sudo echo UI_HOME=/home/boodskapui >> /etc/profile

#Setup Cassandra
sudo su - cassandra
wget --quiet https://archive.apache.org/dist/cassandra/3.11.0/apache-cassandra-3.11.0-bin.tar.gz
tar -xzf apache-cassandra-3.11.0-bin.tar.gz
mv apache-cassandra-3.11.0/* .
rm -rf apache-cassandra-3.11.0
rm apache-cassandra-3.11.0-bin.tar.gz
exit

#Setup Elasticsearch
sudo su - elastic
wget --quiet https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-5.5.0.tar.gz
tar -xzf elasticsearch-5.5.0.tar.gz
mv elasticsearch-5.5.0/* .
rm -rf elasticsearch-5.5.0
rm elasticsearch-5.5.0.tar.gz
exit

#Setup Kibana
sudo su - kibana
wget --quiet https://artifacts.elastic.co/downloads/kibana/kibana-5.5.0-linux-x86_64.tar.gz
tar -xzf kibana-5.5.0-linux-x86_64.tar.gz
mv kibana-5.5.0-linux-x86_64/* .
rm -rf kibana-5.5.0-linux-x86_64
rm kibana-5.5.0-linux-x86_64.tar.gz
exit

#Setup Emqttd
sudo su - emqtt
wget --quiet --no-check-certificate  https://www.emqx.io/static/brokers/emqttd-ubuntu16.04-v2.3.9.zip
unzip -q emqttd-ubuntu16.04-v2.3.9.zip
mv emqttd/* .
rm -rf emqttd
rm emqttd-ubuntu16.04-v2.3.9.zip
exit
