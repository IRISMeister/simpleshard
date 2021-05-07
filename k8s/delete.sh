#!/bin/bash
microk8s kubectl delete -f simple.yml
microk8s kubectl delete pvc --all
