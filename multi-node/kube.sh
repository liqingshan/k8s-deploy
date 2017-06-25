#!/bin/bash

master_ip="10.15.140.176"
host_ip=`ifconfig enp0s3 | grep inet | grep netmask | cut -d ' ' -f10`

function start_apiserver()
{
    /usr/bin/kube-apiserver --insecure-bind-address=0.0.0.0 \
        --insecure-port=8080 \
        --service-cluster-ip-range='10.254.0.0/16' \
        --log_dir="/usr/local/kubernete_test/logs/kube" \
        --v=0 \
        --logtostderr=true \
        --etcd_servers="http://127.0.0.1:2379" \
        --allow_privileged=false \
        --admission-control="NamespaceLifecycle,NamespaceExists,LimitRanger,SecurityContextDeny,ResourceQuota" &

}

function start_scheduler_manager()
{
    /usr/bin/kube-controller-manager \
        --v=0 \
        --logtostderr=true \
        --log_dir=/data/kubernets/logs/kube-controller-manager/ \
        --master=http://$master_ip:8080 &
}

function start_scheduler()
{

    /usr/bin/kube-scheduler \
        --master='127.0.0.1:8080' \
        --v=0 \
        --logtostderr=true \
        --log_dir=/data/kubernets/logs/kube-scheduler &
}
case $1 in
start-apiserver )
    start_apiserver
    ;;
start-manager )
    start_scheduler_manager
    ;;
start-scheduler )
    start_scheduler
    ;;
install-kube )
    yum remove kubernetes-client -y
    yum remove kubernetes-master -y
    yum install kubernetes -y
    ;;
start-master )
#    if [ -d /etc/kubernetes ]; then
#        rm -rf /etc/kubernetes
#    fi

    start_apiserver
    start_scheduler_manager
    start_scheduler

    ;;
start-node )
    /usr/bin/kubelet \
        --logtostderr=true \
        --v=0 \
        --api-servers=http://${master_ip}:8080 \
        --address=${host_ip} \
        --port=10250 \
        --hostname-override=${host_ip} \
        --allow_privileged=true \
        --pod-infra-container-image=10.213.42.254:10500/pause:3.0 \
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
