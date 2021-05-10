#!/bin/bash
microk8s kubectl delete -f simple.yml
microk8s kubectl delete pvc --all
microk8s kubectl delete secret dockerhub-secret
microk8s kubectl delete secret iris-key-secret
