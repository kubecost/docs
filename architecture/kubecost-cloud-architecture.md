# Kubecost Cloud Architecture Overview

Kubecost Cloud uses an agent to gather metrics and send them to the our SaaS platform.

The agent requires two pods and an optional daemonSet:

1. **Kubecost Agent Pod**
   1. Cost-model: Provides cost allocation calculations and metrics, reads from and scraped by Prometheus server.
2. **Prometheus Server Pod**
   1. Prometheus server: Short-term time-series data store (14 days or less)
   2. ConfigMap-Reload: Updates Prometheus when changes are made. Learn more [here](https://github.com/jimmidyson/configmap-reload).
3. **Network costs Daemonset**
   1. (Optional) Used to allocate costs to the workload responsible for egress costs. Learn more [here](../network-allocation.md#network-costs-daemonset).

## Architecture Overview

![Architecture Diagram](https://raw.githubusercontent.com/kubecost/docs/main/images/cloudarchitecture.png)
