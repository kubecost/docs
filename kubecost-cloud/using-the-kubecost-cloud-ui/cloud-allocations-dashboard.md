# Kubecost Cloud: Allocations Dashboard

{% hint style="info" %}
This documentation should only be consulted when using Kubecost Cloud! For information about the Allocations dashboard for self-hosted Kubecost, see [here](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/README.md).
{% endhint %}

Here you can aggregate cost by namespace, deployment, service, and other native Kubernetes concepts. While selecting _Single Aggregation_, you will only be able to categorize by one concept at a time. While selecting _Multi Aggregation_, you will be able to filter for multiple concepts at the same time.

{% hint style="info" %}
Service in this context refers to a Kubernetes object that exposes an interface to outside consumers, not a cloud service.
{% endhint %}

Costs aggregations are also visible by other meaningful organizational concepts, e.g. Team, Department, and Product. These aggregations are based on Kubernetes labels, referenced at both the pod and namespace-level, with labels at the pod-level being favored over the namespace label when both are present. Workloads without the relevant label will be shown as `__unallocated__`.

## UI Overview

### Date range

You can control the window of allocation spend by selecting _Last 7 days_ (the default option), and choosing the time window you want to view spend for. When using custom dates instead of a preset, select Apply to make changes.

### Aggregate By

Here you can aggregate cost by namespace, deployment, service, and other native Kubernetes concepts. While selecting _Single Aggregation_, you will only be able to categorize by one concept at a time. While selecting _Multi Aggregation_, you will be able to filter for multiple concepts at the same time.

Costs aggregations are also visible by other meaningful organizational concepts, e.g. Team, Department, and Product. These aggregations are based on Kubernetes labels, referenced at both the pod and namespace-level, with labels at the pod-level being favored over the namespace label when both are present. Workloads without the relevant label will be shown as `__unallocated__`.

### Edit Report

Selecting _Edit Report_ will provide more options of filtering and visualizing your window query.

#### Idle costs

For an overview of what idle costs are and how they are calculated, see the [bottom of the page](/kubecost-cloud/using-the-kubecost-cloud-ui/cloud-allocations-dashboard.md#idle).

Customize how you wish idle costs to be displayed in your report chart:

* Hide: Hides idle costs.
* Separate By Cluster: Associates idle costs with the clusters they are a part of.
* Separate By Node: Associates idle costs with the nodes they are scheduled to.

#### Chart

View Allocations data in the following formats:

1. Cost over time: Cost per aggregation broken down over days or hours depending on date range
2. Cost: Total cost per aggregation over date range
3. Proportional cost: Cost per aggregate displayed as a percentage of total cost over date range
4. Cost Treemap: Hierarchically structured view of costs in current aggregation

While _Cost over time_ is selected, hover over any interval to receive a breakdown of your spending.

#### Cost metric

View either cumulative or run rate costs measured over the selected time window based on the resources allocated.

* Cumulative Cost: represents the actual/historical spend captured by the Kubecost agent over the selected time window
* Rate metrics: Monthly, daily, or hourly "run rate" cost, also used for projected cost figures, based on samples in the selected time window

Costs allocations are based on the following:

1. Resources allocated, i.e. max of resource requests and usage
2. The cost of each resource
3. The amount of time resources were provisioned

For more information, refer to the[ OpenCost spec](https://github.com/opencost/opencost/blob/develop/spec/opencost-specv01.md).

Filters

Filter resources by namespace, cluster, and/or Kubernetes label to more closely investigate a rise in spend or key cost drivers at different aggregations such as deployments or pods. When a filter is applied, only resources with this matching value will be shown. These filters are also applied to external out-of-cluster asset tags:

| Cluster        | Limit results to workloads in a set of clusters with matching IDs. Note: clusterID is passed in _values_ at install-time.                                          |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Node           | Limit results to workloads where the node name is filtered for.                                                                                                    |
| Namespace      | Limit results to workloads in a set of Kubernetes namespaces.                                                                                                      |
| Label          | Limit results to workloads with matching Kubernetes labels. Namespace labels are applied to all of its workloads. Supports filtering by `__unallocated__` as well. |
| Service        | Limit results to workloads based on Kubernetes service name.                                                                                                       |
| Controller     | Limit results to workloads based on Kubernetes controller name.                                                                                                    |
| Controllerkind | Limit results to workloads based on Kubernetes controller (Daemonset, Deployment, Job, Statefulset, Replicaset, etc) type.                                         |
| Pod            | Limit results to workloads where the Kubernetes pod name is filtered for.                                                                                          |

Comma-separated lists are supported to filter by multiple categories, e.g. namespace filter equals `kube-system,kubecost`. Wild card filters are also supported, indicated by a `*` following the filter, e.g. `namespace=kube*` to return any namespace beginning with `kube`.

### Additional options

The three horizontal dots icon provides additional means of handling your query data. You can open a saved report or download your query data as a CSV file.

## Idle

Cluster idle cost is defined as the difference between the cost of allocated resources and the cost of the hardware they run on. Allocation is defined as the max of usage and requests. It can also be expressed as follows:

> _idle\_cost = sum(cluster\_cost) - (cpu\_allocation\_cost + ram\_allocation\_cost + gpu\_allocation\_cost)_
>
> where\
> _allocation = max(request, usage)_

Idle costs can also be thought of as the cost of the space that the Kubernetes scheduler could schedule pods, without disrupting any existing workloads, but it is not currently.
