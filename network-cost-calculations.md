Network Cost Calculation Methodology
==================

There are two primary concerns when factoring in how Network Costs are calculated: [Cloud Integration](./cloud-integration.md) and the existence of the [Network Costs Daemonset](./network-allocation.md).

## Cloud integration

When working with a Kubecost instance that has cloud integration configured, network costs will be pulled in as line-items on a per-node basis from your cost report. This will result in a baseline estimate that is accurate on the raw price, however, it could lead to discrepancies when viewing from a pod level. For instance, take the example of one pod that communicates inter-regionally with a cloud service, and another interacts cross-regionally. These services would be charged at different rates according to your cloud provider, however they both would be assigned the same network costs due to the network costs being attached to the node itself.

## Network costs daemonset

When you enable the network costs daemonset, Kubecost has the ability to attribute the network-byte traffic to specific pods. This will allow the best level of cost distribution from a pod standpoint, as we have specific values to attribute per-workload. These prices will be based on public API pricing, however, so the exact cost value you see might be incorrect.

## Both cloud integration and network cost daemonset

Enabling both of these options will allow for Kubecost to reconcile the metric data that it gathered from the network costs daemonset. This will allow us to have accurate baseline pricing numbers while also having the network-traffic between pods so that the costs can be correctly distributed.
