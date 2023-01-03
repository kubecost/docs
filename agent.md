# Installing Agent for Kubecost Cloud (limited availability)

The _kubecost-agent_ is a lightweight Kubecost exporter that sends metrics to Kubecost Cloud. In order to install the _kubecost-agent_, you will need a specific key provided by Kubecost.

The Kubecost Cloud architecture is [here](kubecost-cloud-architecture.md)

The name of the storage key file provided by the Kubecost team will have the name `kubecost-agent.key`

> **Note**: Kubecost Cloud is currently in limited availability. You can learn about more about it and request an invitation [here](https://www.kubecost.com/kubecost-cloud-limited-availability/).

## Installation using Helm

> **Note**: Integration with CI/CD tools is possible, but it is recommended to follow this guide as closely as possible to ensure a successful deployment.


The following will install the Kubecost agent and required components using the provided `kubecost-agent.key` (ensure the key file is in the current file directory):

```bash
helm install kubecost-agent \
  --repo https://kubecost.github.io/cost-analyzer cost-analyzer \
  --namespace kubecost-agent --create-namespace \
  --values https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-agent.yaml \
  --set prometheus.server.global.external_labels.cluster_id=CLUSTER_NAME \
  --set kubecostProductConfigs.clusterName=CLUSTER_NAME \
  --set prometheus.nodeExporter.enabled=false \
  --set-file agentKey=kubecost-agent.key \
  --set agentKeySecretName=kubecost-agent-object-store
```

Optionally, add the Network Costs Daemonset:
* All Providers: `--set networkCosts.enabled=true`
And one of the following (if applicable):
* AWS `--set networkCosts.config.services.amazon-web-services=true`
* Azure `--set networkCosts.config.services.azure-cloud-services=true`
* GCP `--set networkCosts.config.services.google-cloud-services=true`

This will install:

* `kubecost-agent` deployment and service
* `prometheus-server` deployment and service
* network-costs daemonSet (optional, collects additional metrics used for egress cost visibility) [learn more](network-allocation.md)

## Additional clusters

For multi-cluster setups, install the agent with the following command:

> **Note**: Please ensure CLUSTER\_NAME is unique per cluster.

```bash
helm install kubecost-agent \
  --repo https://kubecost.github.io/cost-analyzer cost-analyzer \
  --namespace kubecost-agent --create-namespace \
  --values https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-agent.yaml \
  --set prometheus.server.global.external_labels.cluster_id=CLUSTER_NAME \
  --set kubecostProductConfigs.clusterName=CLUSTER_NAME \
  --set prometheus.nodeExporter.enabled=false \
  --set-file agentKey=kubecost-agent.key \
  --set agentKeySecretName=kubecost-agent-object-store \
  --set kubecostMetrics.exporter.exportClusterInfo=false \
  --set kubecostMetrics.exporter.exportClusterCache=false
```

## Accessing the Kubecost UI

Confirm with Kubecost team on successful deployment, which will then provide access to the hosted UI: `https://<your-organization>.kubecost.cloud` which can be used to access all exported data.

> **Note**: Metrics are shipped every two hours. A delay is expected when viewing on the UI.

## Troubleshooting agent deployments

Check to see all pods are ready:

```bash
kubectl get pods -n kubecost-agent
NAME                                          READY   STATUS    RESTARTS   AGE
kubecost-agent-7665c6fc47-dmrhj               1/1     Running   0          25h
kubecost-network-costs-hln2w                  1/1     Running   0          25h
kubecost-prometheus-server-596b9bb9bb-pr4vz   3/3     Running   0          25h
```

Check the container logs. It is common to have Prometheus errors when the `kubecost-agent` pod starts. They should not continue after the `kubecost-prometheus-server` pod is ready. For further troubleshooting, the Kubecost team may ask for the container logs. Script for collecting all the logs:

`kubecost-agent-logs.sh`

```
echo "-----------------kubecost-agent logs-----------------" >./kubecost_agent_logs.log
kubectl logs --namespace kubecost-agent -l app=kubecost-agent --prefix=true --all-containers --tail=-1 >>./kubecost_agent_logs.log
echo "-----------------kubecost-prometheus logs-----------------" >>./kubecost_agent_logs.log
kubectl logs --namespace kubecost-agent -l app=prometheus --prefix=true --all-containers --tail=-1 >>./kubecost_agent_logs.log

# Not generally needed: kubectl logs --namespace kubecost-agent -l app=kubecost-network-costs --prefix=true --all-containers --tail=-1 >>./kubecost_agent_logs.log
# logs are typically small, can just send plain text. otherwise: tar -czvf kubecost_agent_logs.tgz ./kubecost_agent_logs.log && rm ./kubecost_agent_logs.log
```

***
