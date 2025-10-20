# Installing Kubecost on GKE Autopilot Clusters

## Installing Kubecost for GKE Autopilot via Helm

Installing Kubecost on a GKE Autopilot cluster is similar to other cloud providers with Helm v3.1+, with a few changes. Autopilot restricts privileged containers by default so the kubecost-network-costs container needs to be disabled.


```bash
helm upgrade --install kubecost --repo https://kubecost.github.io/kubecost/ kubecost --namespace kubecost --create-namespace --values values.yaml
```

Your _values.yaml_ files must contain the below parameters.

```yaml
global:
  clusterId: "clusterName" # used for display in Kubecost UI
networkCosts:
  enabled: false
```

