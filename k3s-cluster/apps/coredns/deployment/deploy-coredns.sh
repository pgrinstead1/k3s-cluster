#!/bin/bash

# Deploy CoreDNS to a Kubernetes cluster
# This script applies all the CoreDNS YAML files in the correct order

set -e  # Exit on any error

echo "Creating CoreDNS resources in the Kubernetes cluster..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "Error: kubectl command not found. Please install kubectl first."
    exit 1
fi

# Check if we can connect to the Kubernetes cluster
if ! kubectl cluster-info &> /dev/null; then
    echo "Error: Cannot connect to Kubernetes cluster. Please check your kubeconfig."
    exit 1
fi

# Create resources in the correct order
echo "1. Creating ServiceAccount..."
kubectl apply -f 04-serviceaccount.yaml

echo "2. Creating ClusterRole..."
kubectl apply -f 05-clusterrole.yaml

echo "3. Creating ClusterRoleBinding..."
kubectl apply -f 06-clusterrolebinding.yaml

echo "4. Creating ConfigMap..."
kubectl apply -f 01-configmap.yaml

echo "5. Creating custom ConfigMap (optional)..."
kubectl apply -f 07-configmap-custom.yaml || echo "  - Custom ConfigMap skipped. Apply manually if needed."

echo "6. Creating Service..."
kubectl apply -f 03-service.yaml

echo "7. Creating Deployment..."
kubectl apply -f 02-deployment.yaml

echo "Waiting for CoreDNS pods to start..."
kubectl -n kube-system rollout status deployment/coredns

echo "CoreDNS deployment complete!"
echo "Verify CoreDNS is running with: kubectl get pods -n kube-system -l k8s-app=kube-dns"

# Get the status of the CoreDNS pods
echo -e "\nCurrent CoreDNS pod status:"
kubectl get pods -n kube-system -l k8s-app=kube-dns

exit 0
