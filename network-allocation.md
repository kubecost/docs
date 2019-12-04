# Network Traffic Cost Allocation

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

The primary source of network metrics come from a daemonset pod hosted on each of the nodes in a cluster. Each daemonset pod uses `hostNetwork: true` such that it can leverage an underlying kernel module to capture network data. Network traffic data is gathered and the destination of any outbound networking is labeled as:

 * Internet Egress: Network target destination was not identified within the cluster. 
 * Cross Region Egress: Network target destination was identified, but not in the same provider region.
 * Cross Zone Egress: Network target destination was identified, and was part of the same region but not the same zone.

These classifications are important because they correlate with network costing models for most cloud providers. To see more detail on these metric classifications, you can view pod logs with the following command:

```
kubectl logs kubecost-network-costs-<pod-identifier> -n kubecost
```

This will show you top source and destination IP addresses and bytes transfered on the node where this pod is running. 

### Whitelisting internal addresses

For addresses that are outside of your cluster but inside your VPC, Kubecost supports IP or CIDR block whitelisting. This feature can be configured in your [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) under `networkCosts.config`. Any address within the whitelist will be considered in region and zone traffic.

### Feature Validation

To verify this feature is functioning properly, you can complete the following steps.

1. Confirm the `kubecost-network-costs` pods are Running. If these pods are not in a Running state, _kubectl describe_ them and/or view their logs for errors. 
2. Ensure `kubecost-networking` target is Up in your Prometheus Targets list. View any visible errors if this target is not Up. 
3. Verify Network Costs are available in your Kubecost Allocation view. View your browser's Developer Console on this page for any access/permissions errors if costs are not shown. 

### Feature Limitations
 
* Today this feature is supported on Unix-based images with conntrack
* Actively tested against GCP and AWS to date, with Azure in progress
 
 
