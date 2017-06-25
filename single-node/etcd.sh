#!/bin/bash

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
   
    service etcd start
 
    res=`pidof etcd`
    if [ $res ]; then
        echo "etcd started OK"
    else
        echo "etcd not started"
    fi
    ;;
recover )
    service etcd restart
    ;;
stop )
    service etcd stop
    ;;
esac
