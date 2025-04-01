# Homebridge on K3s

This repository contains Kubernetes manifests for deploying Homebridge on a K3s cluster with persistent storage.

## Contents

- `namespace.yaml`: Creates a dedicated namespace for Homebridge
- `pvc.yaml`: Persistent Volume Claim for Homebridge data
- `deployment.yaml`: Homebridge container deployment
- `service.yaml`: Service to expose Homebridge (port 80 for web UI, port 51827 for HomeKit)
- `ssd-storageclass.yaml`: Optional StorageClass for using SSD storage

## Prerequisites

- K3s cluster up and running
- kubectl configured to access your cluster

## Quick Start (Default Storage)

1. Apply all manifests:
   ```bash
   kubectl apply -f namespace.yaml
   kubectl apply -f pvc.yaml
   kubectl apply -f deployment.yaml
   kubectl apply -f service.yaml
   ```

2. Check the deployment status:
   ```bash
   kubectl get pods -n homebridge
   ```

3. Get the external IP to access Homebridge:
   ```bash
   kubectl get svc -n homebridge
   ```

4. Access Homebridge UI at http://EXTERNAL_IP

## Using SSD Storage (Optional)

If you want to use SSDs mounted at `/mnt/ssd` on worker nodes:

1. Update the local-path storage provisioner config:
   ```bash
   kubectl apply -f ssd-storage-config.yaml
   ```

2. Use the SSD storage class:
   ```bash
   kubectl apply -f namespace.yaml
   kubectl apply -f ssd-pvc.yaml  # This uses the SSD StorageClass
   kubectl apply -f deployment.yaml
   kubectl apply -f service.yaml
   ```

## Configuration

The default configuration includes:
- 1Gi of persistent storage
- Homebridge running on port 80 (web UI) and port 51827 (HomeKit)
- Exposed via LoadBalancer service type

## Maintenance

### Updating Homebridge

The deployment uses the latest Homebridge image. To update:

```bash
kubectl rollout restart deployment -n homebridge homebridge
```

### Backing up Homebridge data

The Homebridge data is stored in the persistent volume. To back it up, you can:

1. Find the node where the PV is located:
   ```bash
   kubectl get pod -n homebridge -o wide
   ```

2. Find the PV path:
   ```bash
   kubectl get pv $(kubectl get pvc -n homebridge -o jsonpath='{.items[0].spec.volumeName}') -o yaml
   ```

3. SSH into the node and backup the directory shown in the PV's "path" field.

## Troubleshooting

### Check logs

```bash
kubectl logs -n homebridge -l app=homebridge
```

### Check PVC status

```bash
kubectl get pvc -n homebridge
```
