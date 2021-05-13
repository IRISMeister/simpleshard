#!/bin/bash

./resources.sh

microk8s kubectl apply -f simple.yml
echo "microk8s kubectl get pod -l app=iris"
echo "microk8s kubectl get statefulset -o wide"

echo "waiting until all replicas of IRIS statefulset are Ready"
# any smarter way?
count=0
while [ "$count" != "3/3" ]
do
sleep 1
count=$(microk8s kubectl get statefulset | grep data | awk '{print $2}')
done

echo "setting up a shard cluster"
microk8s kubectl exec -i data-0 -- iris session iris -U %SYS < ../misc/initialize.cos
microk8s kubectl exec -i data-1 -- iris session iris -U %SYS < ../misc/join.cos
microk8s kubectl exec -i data-2 -- iris session iris -U %SYS < ../misc/join.cos
microk8s kubectl exec -i data-0 -- iris session iris -U %SYS < ../misc/verify.cos

echo "importing routines and DMLs"
microk8s kubectl cp ../src data-0:/home/irisowner/src
microk8s kubectl cp ../misc data-0:/home/irisowner/misc
microk8s kubectl exec -i data-0 -- iris session iris -U IRISDM < ../misc/import.cos

echo "starting java based csv loader"
microk8s kubectl apply -f loader.yml
sleep 5
microk8s kubectl exec -it loader -- /app/loader/shell/sales.sh
