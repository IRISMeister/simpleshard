#!/bin/bash

source ./envs.sh

#Docker repository credential
microk8s kubectl create secret docker-registry dockerhub-secret \
--docker-server=https://containers.intersystems.com \
--docker-username=$isccrusername \
--docker-password=$isccrpassword

# IRIS license key
microk8s kubectl create secret generic iris-key-secret --from-file=../license/iris.key
