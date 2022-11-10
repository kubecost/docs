Network Traffic Cost Allocation
===============================

This document summarizes Kubecost network cost allocation, how to enable it, and what it provides.

When this feature is enabled, Kubecost gathers network traffic metrics in combination with provider-specific network costs to provide insight on network data sources as well as the aggregate costs of transfers.

## Enabling network costs

To enable this feature, set the following parameter in _values.yaml_ during [Helm installation](http://kubecost.com/install):
 ```
 networkCosts.enabled=true
 ```
 You can view a list of common config options [here](https://github.com/kubecost/cost-analyzer-helm-chart/blob/ab384e2eb027e74b2c3e61a7e1733ffa1718170e/cost-analyzer/values.yaml#L276). If you are integrating with an existing Prometheus, you can set `networkCosts.prometheusScrape=true` and the network costs service should be auto-discovered.
 
> **Note**: Network cost, which is disabled by default, needs to be run as a privileged pod to access the relevant networking kernel module on the host machine.
 
### Benchmarking metrics

The [network-simulator](http://github.com/kubecost/network-simulator) was used to real-time simulate updating conntrack entries while simultaneously running a cluster simulated [network-costs](http://github.com/kubecost/kubecost-network-costs) instance. To profile the heap, after a warmup of roughly five minutes, a heap profile of 1,000,000 Conntrack entries was gathered and examined.

Each Conntrack entry is equivalent to two transport directions, so every conntrack entry is two map entries (connections).

After modifications were made to the network-costs to parallelize the delta and dispatch, large map comparisons were significantly lighter in memory. The same tests were performed against simulated data with the following footprint results.

![images/post optimization.PNG](https://github.com/kubecost/docs/blob/130e641856d3b6306171f386591e1cd71bc21985/images/post%20optimization.PNG)

## Kubernetes network traffic metrics

The primary source of network metrics is a DaemonSet Pod hosted on each of the nodes in a cluster. Each daemonset pod uses `hostNetwork: true` such that it can leverage an underlying kernel module to capture network data. Network traffic data is gathered and the destination of any outbound networking is labeled as:

 * Internet Egress: Network target destination was not identified within the cluster.  
 * Cross Region Egress: Network target destination was identified, but not in the same provider region.  
 * Cross Zone Egress: Network target destination was identified, and was part of the same region but not the same zone.  

These classifications are important because they correlate with network costing models for most cloud providers. To see more detail on these metric classifications, you can view pod logs with the following command:

```
kubectl logs kubecost-network-costs-<pod-identifier> -n kubecost
```

This will show you the top source and destination IP addresses and bytes transferred on the node where this Pod is running. To disable logs, you can set the helm value `networkCosts.trafficLogging` to `false`. 

## Overriding traffic classifications

For traffic routed to addresses outside of your cluster but inside your VPC, Kubecost supports the ability to directly classify network traffic to a particular IP address or CIDR block. This feature can be configured in your [_values.yaml_](https://github.com/kubecost/cost-analyzer-helm-chart/blob/ab384e2eb027e74b2c3e61a7e1733ffa1718170e/cost-analyzer/values.yaml#L288-L322) under `networkCosts.config`. Classifications are defined as follows:

* In-zone: A list of destination addresses/ranges that will be classified as an in-zone traffic, which is free for most providers. 
* In-region: A list of addresses/ranges that will be classified as the same region between source and destinations but different zones.
* Cross-region: A list of addresses/ranges that will be classified as the different region from the source regions

## Cloud Provider Service Tagging

When traffic is directed towards a cloud providers service, the network traffic pod can tag the traffic with the relevant service name (e.g. AWS S3, Azure Storage, Google Cloud Storage).

To enable this feature, set the following Helm values:

* For AWS, use [`networkCosts.config.services.amazon-web-services=true`](https://github.com/kubecost/cost-analyzer-helm-chart/blob/5787607bf307379363715a220a271e203f0207b4/cost-analyzer/values.yaml#L582)
* For Azure, use [`networkCosts.config.services.azure-cloud-services=true`](https://github.com/kubecost/cost-analyzer-helm-chart/blob/5787607bf307379363715a220a271e203f0207b4/cost-analyzer/values.yaml#L585)
* For GCP, use [`networkCosts.config.services.google-cloud-services=true`](https://github.com/kubecost/cost-analyzer-helm-chart/blob/5787607bf307379363715a220a271e203f0207b4/cost-analyzer/values.yaml#L579)

## Troubleshooting

To verify this feature is functioning properly, you can complete the following steps:

1. Confirm the `kubecost-network-costs` Pods are Running. If these Pods are not in a Running state, _kubectl describe_ them and/or view their logs for errors.  
2. Ensure `kubecost-networking` target is Up in your Prometheus Targets list. View any visible errors if this target is not Up. You can further verify data is being scrapped by the presence of the `kubecost_pod_network_egress_bytes_total` metric in Prometheus. 
3. Verify Network Costs are available in your Kubecost Allocation view. View your browser's Developer Console on this page for any access/permissions errors if costs are not shown.  

### Common issues:

* Failed to locate network pods -- Error message displayed when the Kubecost app is unable to locate the network pods, which we search for by a label that includes our release name. In particular, we depend on the label `app=<release-name>-network-costs` to locate the pods. If the app has a blank release name this issue may happen. 

* Resource usage is a function of unique src and dest IP/port combinations. Most deployments use a small fraction of a CPU and it is also ok to have this Pod CPU throttled. Throttling should increase parse times but should not have other impacts. The following Prometheus metrics are available in v15.3 for determining the scale and the impact of throttling:

`kubecost_network_costs_parsed_entries` is the last number of conntrack entries parsed  
`kubecost_network_costs_parse_time` is the last recorded parse time  

## Feature limitations

* Today this feature is supported on Unix-based images with conntrack  
* Actively tested against GCP, AWS, and Azure  
* Daemonsets have shared IP addresses on certain clusters  



<!--- {"article":"4407595973527","section":"4402815636375","permissiongroup":"1500001277122"} --->
