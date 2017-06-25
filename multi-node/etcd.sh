#!/bin/bash

hostname=`hostname`
hostip=`ifconfig enp0s3 | grep inet | grep netmask | cut -d ' ' -f10`
hostip="http://${hostip}"

subcmd=$1

case $subcmd in
start )
    # clear old etcd config
    data_dir="/var/lib/etcd/default.etcd"
    if [ -d $data_dir ]; then
        rm -rf $data_dir
    fi
    
    pkill etcd
    
    yum install -y etcd
    
    /usr/bin/etcd --name=$hostname \
    --data-dir="/var/lib/etcd/default.etcd" \
    --listen-peer-urls=$hostip":2380" \
    --advertise-client-urls=$hostip":2379" \
    --initial-cluster="vm-dev-1=http://10.15.140.176:2380,vm-dev-2=http://10.15.140.150:2380,vm-dev-3=http://10.15.140.105:2380" \
    --initial-cluster-state="new" \
    --listen-client-urls="http://0.0.0.0:2379" \
    --initial-cluster-token="etcd-cluster" \
    --initial-advertise-peer-urls="${hostip}:2380" 2>&1 &
    
    res=`pidof etcd`
    if [ $res ]; then
        echo "etcd started OK"
    else
        echo "etcd not started"
    fi
    ;;
recover )
    /usr/bin/etcd --name=$hostname \
    --data-dir="/var/lib/etcd/default.etcd" \
    --listen-peer-urls=$hostip":2380" \
    --advertise-client-urls=$hostip":2379" \
    --initial-cluster="vm-dev-1=http://10.15.140.176:2380,vm-dev-2=http://10.15.140.150:2380,vm-dev-3=http://10.15.140.105:2380" \
    --initial-cluster-state="existing" \
    --listen-client-urls="http://0.0.0.0:2379" \
    --initial-cluster-token="etcd-cluster" \
    --initial-advertise-peer-urls="${hostip}:2380" 2>&1 &
    ;;
stop )
    pkill etcd
    ;;
esac
