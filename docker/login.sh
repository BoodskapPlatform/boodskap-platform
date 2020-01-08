#!/bin/bash

#
# Convenient script to login to a running container
# Usage ./login.sh (boodskap | gateway | cassandra | elastic | kibana | emqx)
#

docker exec -it $1 bash
