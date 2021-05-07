#!/bin/bash

source ./envs.sh

microk8s kubectl delete secret dockerhub-secret
microk8s kubectl create secret docker-registry dockerhub-secret \
--docker-server=https://containers.intersystems.com \
--docker-username=$isccrusername \
--docker-password=$isccrpassword

microk8s kubectl apply -f simple.yml
microk8s kubectl get pod -l app=iris
microk8s kubectl get statefulset -o wide
microk8s kubectl logs iris-ss-0
