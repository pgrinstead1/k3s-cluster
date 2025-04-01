#!/bin/bash

# Script to deploy Homebridge on k3s
# Usage: ./deploy.sh [ssd]
# If 'ssd' is specified, uses SSD storage

set -e

echo "Creating homebridge namespace..."
kubectl apply -f namespace.yaml

if [ "$1" == "ssd" ]; then
  echo "Configuring SSD storage..."
  kubectl apply -f ssd-storage-config.yaml
  
  echo "Creating PVC with SSD storage..."
  kubectl apply -f ssd-pvc.yaml
else
  echo "Creating PVC with default storage..."
  kubectl apply -f pvc.yaml
fi

echo "Deploying Homebridge..."
kubectl apply -f deployment.yaml
kubectl apply -f service.yaml

echo "Waiting for pods to start..."
kubectl -n homebridge wait --for=condition=ready pod --selector=app=homebridge --timeout=120s

echo "Homebridge deployment complete!"
echo "Service details:"
kubectl get svc -n homebridge

echo ""
echo "Access Homebridge UI at http://<EXTERNAL-IP>"
