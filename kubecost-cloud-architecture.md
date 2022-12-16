Kubecost Cloud Architecture Overview
===================================

Kubecost Cloud uses an agent to gather metrics and send them to an S3 bucket.

The agent requires 2 pods and an optional daemonSet:

1. **Kubecost Agent Pod**
    a. Cost-model: provides cost allocation calculations and metrics, reads from and scraped by Prometheus server
2. **Prometheus Server Pod**
    a. Prometheus server: short-term time-series data store (14 days or less)
    b. Thanos sidecar: ships metrics to Kubecost Cloud S3 bucket every 3 hours
3. **Network costs**: (optional) used for determining network egress costs. Learn more [here](/network-allocation.md)

## Architecture Overview

![Architecture Diagram](https://raw.githubusercontent.com/kubecost/docs/main/images/cloudarchitecture.png)
