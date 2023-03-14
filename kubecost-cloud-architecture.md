# Kubecost Cloud Architecture Overview

Kubecost Cloud uses an [agent](agent.md) to gather metrics and send them to an S3 bucket.

The agent requires two pods and an optional daemonSet:

1. **Kubecost Agent Pod**
   1. Cost-model: Provides cost allocation calculations and metrics, reads from and scraped by Prometheus server
2. **Prometheus Server Pod**
   1. Prometheus server: Short-term time-series data store (14 days or less)
   2. Thanos sidecar: Ships metrics to Kubecost Cloud S3 bucket every 3 hours
   3. ConfigMap-Reload: Updates prometheus when changes are made. Learn more [here](https://github.com/jimmidyson/configmap-reload).
3. **Network costs Daemonset**
   1. (Optional) Used to allocate costs to the workload responsible for egress costs. Learn more [here](/network-allocation.md#network-costs-daemonset).

## Architecture Overview

![Architecture Diagram](https://raw.githubusercontent.com/kubecost/docs/main/images/cloudarchitecture.png)
