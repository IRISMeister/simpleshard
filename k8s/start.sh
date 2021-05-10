#!/bin/bash

./resources.sh

microk8s kubectl apply -f simple.yml
#echo "microk8s kubectl get pod -l app=iris"
#echo "microk8s kubectl get statefulset -o wide"
#echo "microk8s kubectl describe pod -l app=iris"
#echo "microk8s kubectl logs data-0"

echo "creating shard cluster"
# may need a pause here
microk8s kubectl wait pod/data-0 --for condition=Ready --timeout=30s
microk8s kubectl wait pod/data-1 --for condition=Ready --timeout=30s
microk8s kubectl wait pod/data-2 --for condition=Ready --timeout=30s
sleep 5
./create-shard-cluster.sh

microk8s kubectl apply -f loader.yml
sleep 5
microk8s kubectl exec -it loader -- /app/loader/shell/sales.sh
