#!/bin/bash

subcmd=$1
etcd_prefix="k8s.com/network/"
value='{"Network":"172.11.0.0/16","SubnetLen":26,"Backend":{"Type":"vxlan","VNI":2}}'
case $subcmd in
init )
    pid=`pidof etcd`
    if [ -z $pid ]; then
        echo "etcd not started"
        exit
    fi
    etcdctl set ${etcd_prefix}"/config" $value
    ;;
start )
    yum install -y flannel > /dev/null
    /usr/bin/flanneld --ip-masq --etcd-endpoints="http://127.0.0.1:2379" --etcd-prefix=$etcd_prefix --iface="enp0s8" 2>&1 > /var/log/flannel.log &
    ;;
stop )
    pkill flanneld
    ;;
esac
