# Network Traffic Cost Allocation

This document describes how Kubecost calculates network costs.

![network-costs screenshot](/images/network-cost-overview.png)

## Network cost calculation methodology

Kubecost uses best-effort to allocate network transfer costs to the workloads generating those costs. The level of accuracy has several factors described below.

There are two primary factors when determining how network costs are calculated:&#x20;

1. [Network costs DaemonSet](/install-and-configure/advanced-configuration/network-costs-configuration.md): Must be enabled in order to view network costs
2. [Cloud integration](/install-and-configure/install/cloud-integration/README.md): Optional, allows for accurate cloud billing information

### Base functionality

A default installation of Kubecost will use the onDemand rates for internet egress and proportionally assign those costs by pod using the metric `container_network_transmit_bytes_total`. This is not exactly the same as costs obtained via the network costs DaemonSet, but will be approximately similar.

### Network costs DaemonSet

When you enable the network costs DaemonSet, Kubecost has the ability to attribute the network-byte traffic to specific pods. This will allow the most accurate cost distribution, as Kubecost has per-pod metrics for source and destination traffic.

{% hint style="info" %}
Learn how to enable the network costs DaemonSet in seconds [here](/install-and-configure/advanced-configuration/network-costs-configuration.md#enabling-network-costs).
{% endhint %}

### Cloud integration

Kubecost uses cloud integration to pull actual cloud provider billing information. Without enabling cloud integration, these prices will be based on public onDemand pricing.

Cloud providers allocate data transfers as line-items on a per-node basis. Kubecost will allocate network transfer costs based on each pod's share of `container_network_transmit_bytes_total` of its node.

This will result in a accurate node-based costs. However, it is only estimating the actual pod/application responsible for the network-transfer costs.

### Both cloud integration and network cost DaemonSet

Enabling both cloud-integration and the networkCosts DaemonSet allows Kubecost to give the most accurate data transfer costs to each pod.

### Limitations

At this time, there is a minor limitation where Kubecost cannot determine accurate costs for pods that use hostNetwork. These pods, today, will share all costs with the costs with the node.
