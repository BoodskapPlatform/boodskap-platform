#!/bin/bash

#
# Remove and cleanup boodskap container
# *** WARNING (all container data will be lost)  ***
#

#
# *** Location to store all dynamic container data  ***
#
VOL_DIR=$HOME/docker/boodskap/volumes

./shutdown.sh

echo "Removing containers..."
docker rm gateway
docker rm cassandra
docker rm elastic
docker rm emqx
docker rm kibana
docker rm boodskap
docker network rm platformnet

echo "Removing volumes"
rm -rf $VOL_DIR
