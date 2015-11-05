#!/bin/bash

CLUSTER="--cluster=$1"
[ $# -eq 0 ] && { echo "Usage: $0 cluster_name. (eg. $0 aws)"; exit 1; }

echo "Build the container"
./dockerfiles/_build_launch_container.sh

echo "=== Delete old services hooked in Kubernetes"
kubectl delete --namespace=kube-vision -f ltuengine-76-controller.yaml $CLUSTER

echo "=== Create the controller"
kubectl create -f ltuengine-76-controller.yaml $CLUSTER
echo ""

echo "=== Create the service"
kubectl create -f ltuengine-76-service.yaml $CLUSTER
echo ""

echo "==== Get Nodes available"
kubectl get nodes $CLUSTER
echo ""

echo "==== Get Pods available"
kubectl get pods $CLUSTER
echo ""

echo "==== Get Services available"
kubectl get services $CLUSTER
echo ""

echo "==== Get ReplicationsServices available"
kubectl get rc $CLUSTER
echo ""

echo "==== Get Pods for the Kube System "
kubectl get pods --namespace=kube-system $CLUSTER
echo ""

echo "==== Get the replica Controller for the Kube System "
kubectl get rc --namespace=kube-system $CLUSTER
echo ""

echo "==== Get list of Services for the Kube System "
kubectl get services --namespace=kube-system $CLUSTER
echo ""

echo "### Get external links to the global dashboard"
kubectl cluster-info $CLUSTER
