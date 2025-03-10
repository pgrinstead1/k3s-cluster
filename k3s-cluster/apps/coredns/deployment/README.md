# CoreDNS Configuration for Kubernetes

This directory contains all the necessary Kubernetes manifests to deploy CoreDNS as the cluster DNS provider.

## Files included

1. `01-configmap.yaml` - Contains the CoreDNS configuration (Corefile) and NodeHosts.
2. `02-deployment.yaml` - Defines the CoreDNS deployment with appropriate resources and configuration.
3. `03-service.yaml` - Defines the kube-dns service that exposes CoreDNS to the cluster.
4. `04-serviceaccount.yaml` - Creates the ServiceAccount used by CoreDNS.
5. `05-clusterrole.yaml` - Defines the permissions required by CoreDNS.
6. `06-clusterrolebinding.yaml` - Binds the ClusterRole to the ServiceAccount.

## Installation

To apply all configurations at once:

```bash
kubectl apply -f ./coredns/
```

## Customization

### DNS Forwarding

To change the DNS forwarders, edit the `forward` directive in the `01-configmap.yaml` file:

```
forward . 1.1.1.1 8.8.8.8
```

### Node Hosts

To add custom host entries, edit the `NodeHosts` section in the `01-configmap.yaml` file:

```
NodeHosts: |
  192.168.1.10 worker-node1
  192.168.1.11 worker-node2
```

### Service IP

If your cluster uses a different service CIDR, adjust the `clusterIP` field in the `03-service.yaml` file:

```yaml
spec:
  clusterIP: 10.43.0.10  # Change to match your cluster's service CIDR
```

## Troubleshooting

To check CoreDNS pod status:

```bash
kubectl get pods -n kube-system -l k8s-app=kube-dns
```

To view CoreDNS logs:

```bash
kubectl logs -n kube-system -l k8s-app=kube-dns
```

To test DNS resolution from within a pod:

```bash
kubectl run -it --rm debug --image=alpine -- sh
# Inside the container
apk add --no-cache bind-tools
nslookup kubernetes.default.svc.cluster.local
```
