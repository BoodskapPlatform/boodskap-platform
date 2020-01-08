#!/bin/bash

#
# Script to start boodskap containers
#

docker start gateway
docker start cassandra
docker start elastic
docker start emqx
docker start kibana
docker start boodskap

