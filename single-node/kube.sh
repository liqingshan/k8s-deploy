#!/bin/bash

case $1 in
start-apiserver )
    sed -i 's/ServiceAccount,//' /etc/kubernetes/apiserver
    service kube-apiserver start
    ;;
start-manager )
    service kube-controller-manager start
    ;;
start-scheduler )
    service kube-scheduler start
    ;;
install-kube )
    if [ -d /etc/kubernetes ]; then
        rm -rf /etc/kubernetes
    fi
    yum remove kubernetes-client kubernetes-master kubernetes-node -y
    yum install kubernetes -y
    ;;
start-master )

    sed -i 's/ServiceAccount,//' /etc/kubernetes/apiserver
    service kube-apiserver start
    service kube-controller-manager start
    service kube-scheduler start

    ;;
start-node )
    service kubelet start
    service kube-proxy start
    ;;
stop-master )
    service kube-apiserver stop
    service kube-controller-manager stop
    service kube-scheduler stop
    service kubelet stop
    service kube-proxy stop
    ;;
esac
