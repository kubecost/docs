Kubecost Cloud Architecture Overview
===================================

Kubecost Cloud uses an [agent](agent.md) to gather metrics and send them to an S3 bucket.

The agent requires 2 pods and an optional daemonSet:

1. **Kubecost Agent Pod**
    1. Cost-model: provides cost allocation calculations and metrics, reads from and scraped by Prometheus server
2. **Prometheus Server Pod**
    1. Prometheus server: short-term time-series data store (14 days or less)
    1. Thanos sidecar: ships metrics to Kubecost Cloud S3 bucket every 3 hours
    1. ConfigMap-Reload: updates prometheus when changes are made. Learn more [here](https://github.com/jimmidyson/configmap-reload)
3. **Network costs Daemonset**
   1. (optional) used to allocate costs to the workload responsible for egress costs. Learn more [here](network-allocation.md)

## Architecture Overview

![Architecture Diagram](https://raw.githubusercontent.com/kubecost/docs/main/images/cloudarchitecture.png)
