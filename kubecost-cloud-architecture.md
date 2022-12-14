Kubecost Cloud Architecture Overview
===================================

Below are the major components deployed with the [Kubecost Helm chart](http://docs.kubecost.com/install) for Kubecost Cloud, excluding certain Enterprise components such as durable storage:

1. **Kubecost Agent Pod Pod**  
    a. Cost-model: provides cost allocation calculations and metrics, both reads and writes to Prometheus
2. **Prometheus**  
    a. Prometheus server: time-series data store for cost and health metrics  
    b. Thanos sidecar: ships metrics to Kubecost Cloud S3 bucket every 3 hours
3. **Network costs**: (optional) used for determining network egress costs. Learn more [here](https://github.com/kubecost/docs/blob/main/network-allocation.md)

Kubecost Cloud can be run with just components 1 and 2a.

See an overview of core components in this diagram:

![Core Components Diagram](https://raw.githubusercontent.com/kubecost/docs/main/images/kubepromchart.PNG)

## Architecture Overview

![Architecture Diagram](https://raw.githubusercontent.com/kubecost/docs/main/images/cloudarchitecture.png)
