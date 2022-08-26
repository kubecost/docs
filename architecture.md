Kubecost Core Architecture Overview
===================================

Below are the major components deployed with the [Kubecost helm chart](http://docs.kubecost.com/install), excluding certain Enterprise components such as durable storage:

1. **Kubecost Cost-Analyzer Pod**  
    a. Frontend -- runs Nginx and handles routing to Kubecost backend + Prometheus/Grafana  
    b. Cost-model -- provides cost allocation calculations and metrics, both reads and writes to Prometheus  
2. **Prometheus**  
    a. Prometheus server -- time-series data store for cost & health metrics  
    b. Kube-state-metrics -- provides Kubernetes API metrics, e.g. resource requests [Optional]  
    c. Node-exporter -- provides metrics for some health alerts [Optional]  
    d. Pushgateway -- provides the ability for users to push new metrics to Prometheus [Optional]  
    e. Alertmanager -- used for custom alerts  [Optional]
3. **Network costs** -- used for determining network egress costs [Optional] - [Learn more](https://github.com/kubecost/docs/blob/main/network-allocation.md)
4. **Grafana** -- provides supporting dashboards for Kubecost product [Optional]

Today, the core Kubecost product can be run with just components 1 and 2a.

See an overview of core components in this diagram:

![Architecture Overview](https://raw.githubusercontent.com/kubecost/docs/main/images/arch.png)

## Provider Pricing Architecture Overview

Kubecost interacts with provider pricing in a few different ways.

- onDemand Rates (AWS, Azure, GCP, and Custom Pricing CSV)
- Negotiated Rates (Azure, GCP, and Custom Pricing CSV)
- Spot Data Feed (AWS)
- [Cloud Provider Billing for Reconciliation and Out-of-Cluster Spend](https://github.com/kubecost/docs/blob/main/cloud-integration.md)
  - [AWS Cost and Usage Report](https://github.com/kubecost/docs/blob/main/aws-cloud-integrations.md)
  - [Azure Cost Export](https://github.com/kubecost/docs/blob/main/azure-out-of-cluster.md)
  - [Google BigQuery Export](https://github.com/kubecost/docs/blob/main/gcp-out-of-cluster.md)

In a Enterprise federated setup, only the Primary Kubecost Cluster needs access to the Cloud Provider Billing.

![Provider Pricing Overview](https://raw.githubusercontent.com/kubecost/docs/main/images/cloud-bill-diagram.png)

## Enterprise Architecture Overview

The most common implementation of durable storage in the Kubecost application is with [Thanos](https://thanos.io/). Below is a high-level reference for the required components. More information on each Thanos component can be found [here](https://thanos.io/tip/components/).

![Thanos Overview](https://raw.githubusercontent.com/kubecost/docs/main/images/thanos-architecture.png)

Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/architecture.md)

<!--- {"article":"4407595922711","section":"4402829033367","permissiongroup":"1500001277122"} --->
