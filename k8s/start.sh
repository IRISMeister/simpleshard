#!/bin/bash

./resources.sh

microk8s kubectl apply -f simple.yml
#echo "microk8s kubectl get pod -l app=iris"
#echo "microk8s kubectl get statefulset -o wide"
#echo "microk8s kubectl describe pod -l app=iris"
#echo "microk8s kubectl logs data-0"

echo "waiting until all pods are running"
# may need a more robust way
count=0
while [ "$count" -lt "3" ]
do
sleep 1
# note Pod 'Running' is not equal to IRIS 'Running'
count=$(microk8s kubectl get pod -l app=iris --field-selector=status.phase=Running | wc | awk '{print $1}')
done

echo "creating shard cluster"
./create-shard-cluster.sh

# start java based csv loader
microk8s kubectl apply -f loader.yml
sleep 5
microk8s kubectl exec -it loader -- /app/loader/shell/sales.sh
