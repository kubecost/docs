# Kubernetes Cost Allocation

The Kubecost Cost Allocation dashboard allows you to quickly see allocated spend across all native Kubernetes concepts, e.g. namespace, k8s label, and service. It also allows for allocating cost to organizational concepts like team, product/project, department, or environment. This document explains the metrics presented and describes how you can control the data displayed in this view.

## Cost Allocation dashboard

<figure><img src=".gitbook/assets/allocation.png" alt=""><figcaption><p>Allocations page</p></figcaption></figure>

| Element                           | Description                                                                                                         |
| --------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| Date Range (Last 7 days)          | Will report _Last 7 days_ by default. Manually select your start and end date, or pick one of twelve preset options |
| Aggregate By                      | Aggregate costs by one or several concepts. Add custom labels                                                       |
| (Un)save Report                   | Save or unsave the current report                                                                                   |
| Edit Report                       | Includes multiple filtering tools including  cost metric and shared resources                                       |
| Additional options/meatballs icon | Additional options for opening and downloading reports                                                              |

## Date Range

<figure><img src=".gitbook/assets/daterange.png" alt=""><figcaption><p>Date Range window</p></figcaption></figure>

Select the date range of the report by setting specific start and end dates, or by using one of the preset options. Select _Apply_ to make changes.

## Aggregate By filters

<figure><img src=".gitbook/assets/aggregateby.png" alt=""><figcaption><p>Aggregate By window</p></figcaption></figure>

Here you can aggregate cost by namespace, deployment, service, and other native Kubernetes concepts. While selecting _Single Aggregation_, you will only be able to select one concept at a time. While selecting _Multi Aggregation_, you will be able to filter for multiple concepts at the same time.

> **Note**: Service in this context refers to a Kubernetes object that exposes an interface to outside consumers.

Costs aggregations are also visible by other meaningful organizational concepts, e.g. Team, Department, and Product. These aggregations are based on Kubernetes labels, referenced at both the pod and namespace-level, with labels at the pod-level being favored over the namespace label when both are present. The Kubernetes label name used for these concepts can be configured in Settings or in [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/19908983ed7c8d4ff1d3e62d98537a39ab61bbab/cost-analyzer/values.yaml#L427-L445) after setting `kubecostProductConfigs.labelMappingConfigs.enabled` to true. Workloads without the relevant label will be shown as `__unallocated__`.

> **Note**: Kubernetes annotations can also be used for cost allocation purposes, but this requires enabling a Helm flag. [Learn more about using annotations](annotations.md). To see the annotations, you must add them to the label groupings via Settings or in [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/19908983ed7c8d4ff1d3e62d98537a39ab61bbab/cost-analyzer/values.yaml#L427-L445). Annotations will not work as one-off Labels added into reports directly, they will only work when added to the label groups in Settings or within the [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/19908983ed7c8d4ff1d3e62d98537a39ab61bbab/cost-analyzer/values.yaml#L427-L445).

To find what pods are not part of the relevant label set, you can either apply an `__unallocated__` label filter in this allocation view or explore variations of the following kubectl commands:

```
kubectl get pods -l 'app notin (prometheus, cost-analyzer, ...)' --all-namespaces
kubectl get pods --show-labels -n <TARGET_NAMESPACE>
```

## Edit report

<figure><img src=".gitbook/assets/editreport.png" alt=""><figcaption><p>Edit Report window</p></figcaption></figure>

The _Edit Report_ icon has additional options to filter your search.

### Idle costs

Allocating idle costs proportionately distributes slack or idle _cluster costs_ to tenants. Idle refers to resources that are provisioned but not being fully used or requested by a tenant.

As an example, if your cluster is only 25% utilized, as measured by the max of resource usage and requests, applying idle costs would proportionately increase the cost of each pod/namespace/deployment by 4x. This feature can be enabled by default in Settings.

### Chart

View Allocation data in the following formats:

1. Cost: Total cost per aggregation over date range
2. Cost over time: Cost per aggregation broken down over days or hours depending on date range
3. Efficiency over time: Shows resource efficiency over given date range
4. Proportional cost: Cost per aggregate displayed as a percentage of total cost over date range
5. Cost Treemap: Heirarchically structured view of costs in current aggregation

You can select _Edit Report_ > _Chart_, then select _Cost over time_ from the dropdown to have your data displayed by a per-day basis. Hovering over any day's data will provide a breakdown of your spending.

![Cost over time data](https://raw.githubusercontent.com/kubecost/docs/main/images/perdaybasis.png)

### Cost metric

View either cumulative or run rate costs measured over the selected time window based on the resources allocated.

* Cumulative Cost: represents the actual/historical spend captured by the Kubecost agent over the selected time window
* Rate metrics: Monthly, daily, or hourly "run rate" cost, also used for projected cost figures, based on samples in the selected time window

Costs allocations are based on the following:

1. resources allocated, i.e. max of resource requests and usage
2. the cost of each resource
3. the amount of time resources were provisioned

For more information, refer to the [OpenCost spec](https://github.com/opencost/opencost/blob/develop/spec/opencost-specv01.md).

### Filters

Filter resources by namespace, clusterId, and/or Kubernetes label to more closely investigate a rise in spend or key cost drivers at different aggregations such as deployments or pods. When a filter is applied, only resources with this matching value will be shown. These filters are also applied to external out-of-cluster asset tags. Supported filters are as follows:

| Filter         | Description                                                                                                                                                              |
| -------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Cluster        | Limit results to workloads in a set of clusters with matching IDs. Note: clusterID is passed in _values_ at install-time.                                                |
| Node           | Limit results to workloads where the node name is filtered for.                                                                                                          |
| Namespace      | Limit results to workloads in a set of Kubernetes namespaces.                                                                                                            |
| Label          | Limit results to workloads with matching Kubernetes labels. Namespace labels are applied to all of its workloads. Supports filtering by `__unallocated__` field as well. |
| Service        | Limit results to workloads based on Kubernetes service name.                                                                                                             |
| Controller     | Limit results to workloads based on Kubernetes controller name.                                                                                                          |
| Controllerkind | Limit results to workloads based on Kubernetes controller (Daemonset, Deployment, Job, Statefulset, Replicaset, etc) type.                                               |
| Pod            | Limit results to workloads where the Kubernetes pod name is filtered for.                                                                                                |

Comma-separated lists are supported to filter by multiple categories, e.g. namespace filter equals `kube-system,kubecost`. Wild card filters are also supported, indicated by a \* following the filter, e.g. `namespace=kube*` to return any namespace beginning with `kube`.

### Shared resources

Select how shared costs set on the settings page will be shared among allocations. Pick from default shared resources, or select a custom shared resource. A custom shared resource can be selected in the Configure custom shared resources feature at the bottom of the _Edit report_ window.

## Additional options

<figure><img src=".gitbook/assets/dots.png" alt=""><figcaption><p>Additional options</p></figcaption></figure>

The three horizontal lines/meatballs icon will provide additional options for handling your report:

* _Open Report_: Allows you to open one of your saved reports without first navigating to the Reports page
* _Alerts_: Send one of four reports routinely: recurring, efficiency, budget, and spend change
* _Download CSV_: Download your current report as a CSV file
* _Download PDF_: Download your current report as a PDF file

## Cost metrics table

Cost allocation metrics are available for both in-cluster and out-of-cluster resources:

| Metric                      | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| --------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| CPU                         | The total cost of CPU allocated to this object, e.g. namespace or deployment. The amount of CPU allocated is the greater of CPU usage and CPU requested over the measured time window. The price of allocated CPU is based on cloud billing APIs or custom pricing sheets. [Learn more](https://github.com/kubecost/cost-model#questions)                                                                                                                              |
| GPU                         | The cost of GPUs requested by this object, as measured by [resource limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/). Prices are based on cloud billing prices or custom pricing sheets for on-prem deployments. [Learn more](gpu-allocation.md)                                                                                                                                                                         |
| RAM                         | The total cost of memory allocated to this object, e.g. namespace or deployment. The amount of memory allocated is the greater of memory usage and memory requested over the measured time window. The price of allocated memory is based on cloud billing APIs or custom pricing sheets. [Learn more](https://github.com/kubecost/cost-model#questions)                                                                                                               |
| Persistent Volume (PV) Cost | The cost of persistent storage volumes claimed by this object. Prices are based on cloud billing prices or custom pricing sheets for on-prem deployments.                                                                                                                                                                                                                                                                                                              |
| Network                     | The cost of network traffic based on internet egress, cross-zone egress, and other billed transfer. Note: these costs must be enabled. [Learn more](/network-allocation). When Network Traffic Cost are not enabled, the Node network costs from the cloud service provider's [billing integration](/install-and-configure/install/cloud-integration) will be spread proportionally based on cost weighted usage. |
| Load Balancer (LB) cost     | The cost of cloud-service load balancer that has been allocated.                                                                                                                                                                                                                                                                                                                                                                                                       |
| Shared                      | The cost of shared resources allocated to this tenant. This field covers shared overhead, shared namespaces, and shared labels.                                                                                                                                                                                                                                                                                                                                        |
| Cost Efficiency             | The percentage of requested CPU & memory dollars utilized over the measured time window. Values range from 0 to above 100 percent. Workloads with no requests but with usage OR workloads with usage > request can report efficiency above 100%.                                                                                                                                                                                                                       |

### Cost efficiency table example

![Cost Efficiency table](https://raw.githubusercontent.com/kubecost/docs/main/images/table.PNG)
