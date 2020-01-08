# Boodskap IoT Platform

## Install as Docker Container

+ Install the recent docker software in your host machine
+ Clone this repository
    + $ git clone https://github.com/BoodskapPlatform/boodskap-platform.git
+ $ cd boodskap-platform/docker
+ Create the containers
    + $ ./create.sh
+ Start the containers
    + $ ./startup.sh
+ Activate the platform (one time)
    + $ ./login.sh boodskap
    + $ /root/bin/cluster.sh --activate
+ In about 5-6 minutes (depends on your machine) the platform should be accessed at the below url in your browser
    + http://boodskap.xyz
    + **Until the platform initializes, you will be getting invalid password if you try to login**
+ The default user name and password are **admin / admin**

## Download and Install (Single Machine)

## Download and Install (Cluster)

