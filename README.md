# Kubernetes Cluster Configuration

This repository contains the configuration files for a Kubernetes (k3s) cluster. It's organized by application type and configured for CI/CD deployment.

## Directory Structure

- `k3s-cluster/`: Main directory for all Kubernetes configurations
  - `apps/`: Application-specific configurations
    - `coredns/`: CoreDNS DNS server configurations
    - `cups/`: CUPS printing server configurations
    - `homebridge/`: Homebridge smart home configurations
    - `pihole/`: Pi-hole DNS configurations
    - `rancher/`: Rancher management configurations
  - `dns/`: DNS-related configurations
    - `external-dns/`: External DNS integration configurations
  - `tests/`: Test configurations for validating deployments

## CI/CD Integration

This repository is set up with GitHub Actions for automated deployment to a Kubernetes cluster. The workflow validates configurations and applies them to the target cluster when changes are pushed.

## Prerequisites

- A running Kubernetes (k3s) cluster
- kubectl configured to access the cluster
- Access credentials configured as GitHub secrets (for CI/CD)

## Usage

1. Clone this repository
2. Make changes to the configuration files as needed
3. Push changes to GitHub to trigger automatic deployment
4. Monitor the GitHub Actions workflow for deployment status

## Manual Deployment

To manually apply the configurations:

```bash
kubectl apply -f k3s-cluster/apps/coredns/
kubectl apply -f k3s-cluster/apps/cups/
# Repeat for other application directories
```
