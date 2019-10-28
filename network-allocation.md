# Network Cost Allocation

This document summarizes Kubecost network cost allocation, how to enable it, and what it provides. 

When this feature is enabled, Kubecost gathers network traffic metrics in combination with provider specific network costs to provide insight on network data sources as well as the aggregate costs of transfers. 

### Enabling Network Costs

To enable this feature, set the following parameter in values.yaml during [Helm installation](http://kubecost.com/install):
 ```
 networkCosts.enabled=true
 ```
 You can view a list of common Kubecost chart config options [here](https://github.com/kubecost/cost-analyzer-helm-chart#config-options). 
 
 **Note:** network cost allocation is disabled by default.

### Kubernetes Network Traffic Metrics

The primary source of network metrics come from a daemonset pod hosted on each of the nodes in a cluster. Each daemonset pod uses `hostNetwork: true` such that it can leverage the underlying node kernel module `conntrack`. Network traffic data is gathered and the destination of any outbound networking is labeled as:

 * Internet Egress: Network target destination was not identified within the cluster. 
 * Cross Region Egress: Network target destination was identified, but not in the same provider region.
 * Cross Zone Egress: Network target destination was identified, and was part of the same region but not the same zone.

These specific classifications are important because they correlate with network costing models for popular cloud providers. 

### Feature Validation

To verify this feature is functioning properly, you can complete the following steps.

1. Confirm the `kubecost-network-costs` pods are Running
2. Ensure `kubecost-networking` target is Up in your Prometheus
3. Verify Network Costs are available in your Allocation view 

### Feature Limitations
 
* Today this feature is supported on Unix-based images with conntrack
* Actively tested against GCP and AWS to date, with Azure in progress
 
 
