Installing Agent for Hosted Kubecost (Alpha)
======

The `kubecost-agent` is a version of the kubecost metric exporter that runs as a primary transport of data into hosted kubecost. In order to install the `kubecost-agent`, you will need a specific storage key provided by the kubecost team.

The name of the storage key file provided by the kubecost team will have the name `kubecost-agent.key`

## Installation From Helm
1. Add the kubecost helm repository: 
```bash
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
```

2. The following will install the kubecost agent and required components using the provided `kubecost-agent.key` (ensure the key file is in the current file directory):
```bash
helm install kubecost kubecost/cost-analyzer \
  --namespace kubecost \
  --values=https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-agent.yaml \
  --set kubecostToken="bWJvbHQzNUBnbWFpbC5jb20=xm343yadf98" \
  --set prometheus.server.global.external_labels.cluster_id=<unique cluster identifier> \
  --set kubecostProductConfigs.clusterName=<custom cluster name> \
  --set-file agentKey="kubecost-agent.key"
```
This step will install:
* kubecost-agent Deployment and service
* prometheus-server Deployment and service 
* node-exporter DaemonSet

Optionally, the `--set networkCosts.enabled=true` can be used during the helm install to include the `kubecost-network-costs` DaemonSet. [Learn more](https://docs.kubecost.com/network-allocation.html)

For multicluster setups, all additional cluster installs would use the following install command:
```bash
helm install kubecost kubecost/cost-analyzer \
  --namespace kubecost \
  --values=https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-agent.yaml \
  --set kubecostToken="bWJvbHQzNUBnbWFpbC5jb20=xm343yadf98" \
  --set prometheus.server.global.external_labels.cluster_id=<unique cluster identifier> \
  --set kubecostProductConfigs.clusterName=<custom cluster name> \
  --set kubecostMetrics.exporter.exportClusterInfo=false \
  --set kubecostMetrics.exporter.exportClusterCache=false \
  --set-file agentKey="kubecost-agent.key"
```

3. Confirm with Kubecost team on successful deployment, which will then provide an endpoint `http://<your-organization>.kubecost.io` which can be used to access all exported data. 
