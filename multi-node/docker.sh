#!/bin/bash

case $1 in
install )
    yum remove docker-engine docker-engine-selinux -y
    yum install docker -y
    ;;
start )

    if [ -f /etc/docker/daemon.json ]; then
        mv /etc/docker/daemon.json /etc/docker/daemon.json.bck
    fi
    if [ -d /var/lib/docker/ ]; then
        rm -rf /var/lib/docker
    fi

    FLANNEL_SUBNET=`cat /run/flannel/subnet.env | grep FLANNEL_SUBNET | cut -d '=' -f2`

    /usr/bin/docker-current daemon \
          --exec-opt native.cgroupdriver=systemd \
          --selinux-enabled=false --log-driver=journald \
          --insecure-registry=10.213.42.254:10500 \
          --log-level=warn \
          $DOCKER_STORAGE_OPTIONS \
          $DOCKER_NETWORK_OPTIONS \
          $ADD_REGISTRY \
          $BLOCK_REGISTRY \
          $INSECURE_REGISTRY \
          --bip=${FLANNEL_SUBNET} &
    ;;
recover )
    ;;
stop )
    pkill docker
    ;;
esac
