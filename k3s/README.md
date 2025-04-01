# Kubernetes GitOps Repository

This repository contains Kubernetes manifests organized in a GitOps-compatible structure for deploying and managing applications.

## Structure

- **apps/**: Application workloads
  - **base/**: Base configurations for applications
  - **overlays/**: Environment-specific overlays (dev, staging, prod)

- **infrastructure/**: Infrastructure components
  - **base/**: Base configurations for infrastructure
    - **cert-manager/**: Certificate management
    - **metallb-system/**: Load balancing
  - **overlays/**: Environment-specific overlays

- **namespaces/**: Namespace definitions

- **system/**: System-level components
  - **base/**: Base configurations for system components
    - **kube-system/**: Core Kubernetes components
  - **overlays/**: Environment-specific overlays

## Usage

To apply these resources to your Kubernetes cluster:

```bash
# Apply everything
kubectl apply -k ./

# Apply specific components
kubectl apply -k apps/base/monitoring/
kubectl apply -k infrastructure/base/cert-manager/
```

For GitOps with tools like FluxCD or ArgoCD, you can point your GitOps controller to this repository.
