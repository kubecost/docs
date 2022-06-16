Installing Agent for Hosted Kubecost (Alpha)
============================================

The ___kubecost-agent___ is a lightweight Kubecost exporter that sends metrics to hosted kubecost. In order to install the ___kubecost-agent___, you will need a specific key provided by the kubecost team.

The name of the storage key file provided by the kubecost team will have the name `kubecost-agent.key`

## Installation Using Helm

> Note: integration with CI/CD tools is certainly possible, but we recommend following this guide as closely as possible to ensure a successful deployment.

1. Add the kubecost helm repository:

```bash
helm repo add kubecost https://kubecost.github.io/cost-analyzer/
```

2. The following will install the kubecost agent and required components using the provided `kubecost-agent.key` (ensure the key file is in the current file directory):

```bash
helm upgrade --install kubecost kubecost/cost-analyzer \
  --namespace kubecost-agent --create-namespace\
  --values=https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-agent.yaml \
  --set prometheus.server.global.external_labels.cluster_id=<CLUSTER_NAME> \
  --set kubecostProductConfigs.clusterName=<CLUSTER_NAME> \
  --set prometheus.nodeExporter.enabled=true \
  --set prometheus.serviceAccounts.nodeExporter.create=true \
  --set networkCosts.enabled=true \
  --set-file agentKey="kubecost-agent.key"
```

This step will install:
* kubecost-agent deployment and service
* prometheus-server deployment and service
* node-exporter daemonSet (set to false if you already have node-exporter running)
* network-costs daemonSet (optional, collects additional metrics used for egress cost visibility) [learn more](https://guide.kubecost.com/hc/en-us/articles/4407595973527)

## Additional Clusters

For multi-cluster setups, all additional cluster installs would use the following install command.

Please ensure CLUSTER_NAME is unique per cluster.

```bash
helm upgrade --install kubecost kubecost/cost-analyzer \
  --namespace kubecost-agent --create-namespace\
  --values=https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-agent.yaml \
  --set prometheus.server.global.external_labels.cluster_id=<CLUSTER_NAME> \
  --set kubecostProductConfigs.clusterName=<CLUSTER_NAME> \
  --set kubecostMetrics.exporter.exportClusterInfo=false \
  --set kubecostMetrics.exporter.exportClusterCache=false \
  --set prometheus.nodeExporter.enabled=true \
  --set prometheus.serviceAccounts.nodeExporter.create=true \
  --set networkCosts.enabled=true \
  --set-file agentKey="kubecost-agent.key"
```

## Accessing the Kubecost UI

Confirm with Kubecost team on successful deployment, which will then provide access to the hosted UI: `https://<your-organization>.kubecost.io` which can be used to access all exported data.

> Note: Metrics are shipped every 2 hours, a delay is expected when viewing on the UI.


## Troubleshooting Agent Deployments

Check to see all pods are ready:

```bash
kubectl get pods -n kubecost-agent
NAME                                          READY   STATUS    RESTARTS   AGE
kubecost-agent-7665c6fc47-dmrhj               1/1     Running   0          25h
kubecost-network-costs-hln2w                  1/1     Running   0          25h
kubecost-prometheus-server-596b9bb9bb-pr4vz   3/3     Running   0          25h
```

Check the container logs- it is common to have prometheus errors when the kubecost-agent pod starts. They should not continue after the kubecost-prometheus-server pod is ready.

For further troubleshooting, the Kubecost team may ask for the container logs.

`kubecost-agent-logs.sh`
```sh
echo "-----------------kubecost-agent logs-----------------" >./kubecost_agent_logs.log
kubectl logs --namespace kubecost-agent -l app=kubecost-agent --prefix=true --all-containers --tail=-1 >>./kubecost_agent_logs.log
echo "-----------------kubecost-prometheus logs-----------------" >>./kubecost_agent_logs.log
kubectl logs --namespace kubecost-agent -l app=prometheus --prefix=true --all-containers --tail=-1 >>./kubecost_agent_logs.log

# Not generally needed: kubectl logs --namespace kubecost-agent -l app=kubecost-network-costs --prefix=true --all-containers --tail=-1 >>./kubecost_agent_logs.log
# logs are typically small, can just send plain text. otherwise: tar -czvf kubecost_agent_logs.tgz ./kubecost_agent_logs.log && rm ./kubecost_agent_logs.log
```

---
<!--- {"article":"4425132038167","section":"1500002777682","permissiongroup":"1500001277122"} --->