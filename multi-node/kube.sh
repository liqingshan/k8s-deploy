#!/bin/bash

master_ip="192.168.99.101"
host_ip=`ifconfig enp0s8 | grep inet | grep netmask | cut -d ' ' -f10`

case $1 in
start-master )
    if [ -d /etc/kubernetes ]; then
        rm -rf /etc/kubernetes
    fi
#    yum remove kubernetes-client -y
#    yum remove kubernetes-master -y
#    yum install kubernetes -y

    /usr/bin/kube-apiserver --insecure-bind-address=0.0.0.0 \
        --insecure-port=8080 \
        --service-cluster-ip-range='192.168.99.0/24' \
        --log_dir="/usr/local/kubernete_test/logs/kube" \
        --v=0 \
        --logtostderr=true \
        --etcd_servers="http://127.0.0.1:2379" \
        --allow_privileged=false &
#        --admission-control="NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ResourceQuota" &

    /usr/bin/kube-controller-manager \
        --v=0 \
        --logtostderr=true \
        --log_dir=/data/kubernets/logs/kube-controller-manager/ \
        --master=http://127.0.0.1:8080 &

    /usr/bin/kube-scheduler \
        --master='127.0.0.1:8080' \
        --v=0 \
        --logtostderr=true \
        --log_dir=/data/kubernets/logs/kube-scheduler &

    ;;
start-node )
    /usr/bin/kubelet \
        --logtostderr=true \
        --v=0 \
        --api-servers=http://${master_ip}:8080 \
        --address=${host_ip} \
        --port=10250 \
        --hostname-override=${host_ip} \
        --allow_privileged=false \
        --pod-infra-container-image=registry.access.redhat.com/rhel7/pod-infrastructure:latest \
        $KUBELET_ARGS &
    /usr/bin/kube-proxy \
        --logtostderr=true \
        --v=0 \
        --master=http://${master_ip}:8080 \
        $KUBE_PROXY_ARGS &
    ;;
stop-master )
    pkill kube-apiserver
    kill -9 `pidof kube-controller-manager`
    pkill kube-scheduler
    ;;
stop-node )
    pkill kubelet
    pkill kube-proxy
    ;;
esac
