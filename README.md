<<<<<<< HEAD
# k3s-cluster
k3s-cluster
=======
# Kubernetes Cluster Configuration

This repository contains Kubernetes manifests for deploying and managing applications in a k3s cluster.

## Directory Structure

```
k3s-cluster/
├── apps/         # Application deployments
│   ├── coredns/  # CoreDNS configurations
│   ├── cups/     # CUPS printing server
│   ├── homebridge/ # Homebridge IoT bridge
│   ├── metallb/  # MetalLB load balancer
│   └── pihole/   # Pi-hole DNS server
├── dns/
│   └── external-dns/ # External DNS configuration
└── manifests/
    └── test/     # Test manifests
```

## CI/CD Integration

This repository is designed to work with CI/CD pipelines for automated deployments to the k3s cluster.

### Setup with GitLab CI/CD

1. Add a `.gitlab-ci.yml` file to the root of this repository.
2. Configure the necessary CI/CD variables in your GitLab project settings.
3. Set up a Kubernetes agent or runner with access to your cluster.

### Setup with GitHub Actions

1. Add workflow files to `.github/workflows/` directory.
2. Configure GitHub Secrets for secure access to your cluster.
3. Use actions like `kubectl-action` to deploy to the cluster.

## Deployment Process

The recommended deployment process is:

1. Make changes to the manifests
2. Commit and push to the repository
3. CI/CD automatically validates the manifests
4. Upon successful validation, changes are applied to the cluster

>>>>>>> bdcf2a1 (Initial setup for k3s cluster configuration with CI/CD)
