# Network Traffic Cost Allocation

This document summarizes Kubecost network cost allocation, how to enable it, and what it provides.

When this feature is enabled, Kubecost gathers network traffic metrics in combination with provider-specific network costs to provide insight on network data sources as well as the aggregate costs of transfers.

### Enabling Network Costs

To enable this feature, set the following parameter in values.yaml during [Helm installation](http://kubecost.com/install):
 ```
 networkCosts.enabled=true
 ```
 You can view a list of common config options [here](https://github.com/kubecost/cost-analyzer-helm-chart/blob/ab384e2eb027e74b2c3e61a7e1733ffa1718170e/cost-analyzer/values.yaml#L276). If you are integrating with an existing Prometheus, you can set `networkCosts.prometheusScrape=true` and the network costs service should be auto-discovered.
 
 To estimate the resources required to run Kubecost network cost,  you can view our [benchmarking metrics](https://docs.google.com/document/d/10b-Ew78R90UOaZ5gXQUjU5GWZXBIy8H11RK5bbCd2EM/edit).

 > **Note:** network cost, which are disabled by default, run as a privileged pod to access the relevant networking kernel module on the host machine.

### Kubernetes Network Traffic Metrics

The primary source of network metrics come from a daemonset pod hosted on each of the nodes in a cluster. Each daemonset pod uses `hostNetwork: true` such that it can leverage an underlying kernel module to capture network data. Network traffic data is gathered and the destination of any outbound networking is labeled as:

 * Internet Egress: Network target destination was not identified within the cluster.  
 * Cross Region Egress: Network target destination was identified, but not in the same provider region.  
 * Cross Zone Egress: Network target destination was identified, and was part of the same region but not the same zone.  

These classifications are important because they correlate with network costing models for most cloud providers. To see more detail on these metric classifications, you can view pod logs with the following command:

```
kubectl logs kubecost-network-costs-<pod-identifier> -n kubecost
```

This will show you top source and destination IP addresses and bytes transferred on the node where this pod is running. To disable logs, you can set the helm value `networkCosts.trafficLogging` to `false`. 

### Overriding traffic classifications

For traffic routed to addresses outside of your cluster but inside your VPC, Kubecost supports the ability to directly classifify network traffic to a particular IP address or CIDR block. This feature can be configured in your [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/ab384e2eb027e74b2c3e61a7e1733ffa1718170e/cost-analyzer/values.yaml#L288-L322) under `networkCosts.config`. Classifications are defined as follows:

* in-zone - a list of destination addresses/ranges that will be classified as an in-zone traffic, which is free for most providers. 
* in-region - a list of addresses/ranges that will be classified as the same region between source and destinations but different zones.
* cross-region -- a list of addresses/ranges that will be classified as different region from the source regions


### Troubleshooting

To verify this feature is functioning properly, you can complete the following steps:

1. Confirm the `kubecost-network-costs` pods are Running. If these pods are not in a Running state, _kubectl describe_ them and/or view their logs for errors.  
2. Ensure `kubecost-networking` target is Up in your Prometheus Targets list. View any visible errors if this target is not Up. You can further verify data is being scrapped by the presence of the `kubecost_pod_network_egress_bytes_total` metric in Prometheus. 
3. Verify Network Costs are available in your Kubecost Allocation view. View your browser's Developer Console on this page for any access/permissions errors if costs are not shown.  

Common issues:

* Failed to locate network pods -- Error message displayed when the Kubecost app is unable to locate the network pods, which we search for by a label that includes our release name. In particular, we depend on the label `app=<release-name>-network-costs` to locate the pods. If the app has a blank release name this issue may happen. 

* Resource usage is a function of unique src and dest IP/port combinations. Most deployments use a small fraction of a CPU and it is also ok to have this pod CPU throttled. Throttling should increase parse times but should not have other impact. The following Prometheus metrics are available in v15.3 for determining scale and the impact of throttling:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; `kubecost_network_costs_parsed_entries` is the last number of conntrack entries parsed  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; `kubecost_network_costs_parse_time` is the last recorded parse time  

### Feature Limitations

* Today this feature is supported on Unix-based images with conntrack  
* Actively tested against GCP, AWS, and Azure  
* Daemonsets have shared IP addresses on certain clusters  
