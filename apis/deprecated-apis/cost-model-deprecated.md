# costDataModel & aggregatedCostModel API

{% hint style="danger" %}
These APIs are now deprecated. This page should not be consulted. Please reference the [Allocation API](/apis/monitoring-apis/api-allocation.md) doc for updated information.
{% endhint %}

Kubecost exposes multiple APIs to obtain cost, resource allocation, and utilization data. Below is documentation on two options: the cost model API and aggregated cost model API.

## Cost model API

The full cost model API exposes pricing model inputs at the individual container/workload level and is available at:

`http://<kubecost-address>/model/costDataModel`

Here's an example use:

`http://localhost:9090/model/costDataModel?timeWindow=7d&offset=7d`

API parameters include the following:

* `timeWindow` dictates the applicable window for measuring cost metrics. Supported units are d, h, and m.
* `offset` shifts timeWindow backward relative to the current time. Supported units are d, h, and m.

This API returns a set of JSON elements in this format:

```json
{
  cpuallocated: [{timestamp: 1567531940, value: 0.01}]
  cpureq: [{timestamp: 1567531940, value: 0.01}]
  cpuused: [{timestamp: 1567531940, value: 0.006}]
  deployments: ["cost-model"]
  gpureq: [{timestamp: 0, value: 0}]
  labels: {app: "cost-model", pod-template-hash: "1576869057"}
  name: "cost-model"
  namespace: "cost-model"
  node: {hourlyCost: "", CPU: "2", CPUHourlyCost: "0.031611", RAM: "13335256Ki",…}
  nodeName: "gke-kc-demo-highmem-pool-b1faa4fc-fs6g"
  podName: "cost-model-59cbdbf49c-rbr2t"
  pvcData: [{class: "standard", claim: "kubecost-model", namespace: "kubecost",…}]
  ramallocated: [{timestamp: 1567531940, value: 55000000}]
  ramreq: [{timestamp: 1567531940, value: 55000000}]
  ramused: [{timestamp: 1567531940, value: 19463457.32}]
  services: ["cost-model"]
}
```

\
Optional request parameters include the following:

| Field          | Description                                                                                                                                                    |
| -------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `filterFields` | Blacklist of fields to be filtered from the response. For example, appending `&filterFields=cpuused,cpureq,ramreq,ramused` will remove request and usage data. |
| `namespace`    | Filter results by namespace. For example, appending `&namespace=kubecost` only returns data for the `kubecost` namespace                                       |

## Aggregated cost model API

> NOTE: this API is actively being replaced by the [Allocation API](/apis/monitoring-apis/api-allocation.md). That is the recommended API for querying historical and run-rate cost allocation metrics.

The aggregated cost model API retrieves data similar to the Kubecost Allocation frontend view (e.g. cost by namespace, label, deployment, and more) and is available at the following endpoint:

`http://<kubecost-address>/model/aggregatedCostModel`

Here are example uses:

* `http://localhost:9090/model/aggregatedCostModel?window=1d&aggregation=namespace`
* `http://localhost:9090/model/aggregatedCostModel?window=1d&aggregation=label&aggregationSubfield=product`
* `http://localhost:9090/model/aggregatedCostModel?window=1d&aggregation=namespace&sharedNamespaces=kube-system`

API parameters include the following:

* `window` dictates the applicable window for measuring cost metrics. Current support options:
  * "15m", "24h", "7d", "48h", etc.
  * "today", "yesterday", "week", "month", "lastweek", "lastmonth"
  * "1586822400,1586908800", etc. (start and end unix timestamps)
  * "2020-04-01T00:00:00Z,2020-04-03T00:00:00Z", etc. (start and end UTC RFC3339 pairs)
* `offset` (optional) shifts window backward from current time. Supported units are d, h, m, and s.
* `aggregation` is the field used to consolidate cost model data. Supported types are cluster, namespace, controller, deployment, service, label, pod and container.
* `aggregationSubfield` used for aggregation types that require subfields, e.g. aggregation type equals `label` and the value of the label (aggregationSubfield) equals `app`. Comma-separated list of values supported.
* `allocateIdle` (optional) when set to `true`, applies the cost of all idle compute resources to tenants, default `false`.
* `sharedNamespaces` (optional) provide a comma-separated list of namespaces (e.g. kube-system) to be allocated to other tenants. These resources are evenly allocated to other tenants as `sharedCost`.
* `sharedLabelNames` (optional) provide a comma-separated list of Kubernetes labels (e.g. app) to be allocated to other tenants. Must provide the corresponding set of label values in `sharedLabelValues`.
* `sharedLabelValues` (optional) label value (e.g. prometheus) associated with `sharedLabelNames` parameter.
* `sharedSplit` (optional) Shared costs are split evenly across tenants unless `weighted` is passed for this request parameter. When allocating shared costs on a weighted basis, these costs are distributed based on the percentage of in-cluster resource costs of the individual pods in the particular aggregation, e.g. namespace.
* `disableCache` this API caches recently fetched data by default. Set this variable to `false` to avoid cache entirely.
* `etl` setting this variable to `true` forces a request to be served by the ETL pipeline. More info on this feature is in the Caching Overview section below.

\
Optional filter parameters include the following:

| Filter      | Description                                                                                                                                                                                                               |
| ----------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `cluster`   | Filter results by cluster ID. For example, appending `&cluster=cluster-one` will restrict data only to the `cluster-one` cluster. Note: cluster ID is generated from `cluster_id` provided during installation.           |
| `namespace` | Filter results by namespace. For example, appending `&namespace=kubecost` only returns data for the `kubecost` namespace.                                                                                                 |
| `labels`    | Filter results by label(s). For example, appending `&labels=app%3Dcost-analyzer` only returns data for pods with label `app=cost-analyzer`. CSV list of label values supported. Note that parameters must be URL encoded. |

This API returns a set of JSON objects in this format:

```json
{
  aggregation: "namespace"        // value of aggregation type parameter
  cpuAllocationAverage: 0.01      // average number of cores allocated over time window, max(request,usage)
  cpuCost: 0.053106479            // total cost of CPU allocated
  cpuEfficiency: 0.0469166        // ratio of cost-weighted CPUs being utilized
  efficiency: 0.1476976           // efficiency of both CPU and RAM provisioned
  environment: "ingress-nginx"    // instance of aggregation 
  gpuAllocationAverage: 0         // average number of cores allocated over time window, based on request
  gpuCost: 0                      // total cost of GPU allocated
  networkCost: 0                  // cost of network egress
  pvAllocationAverage: 0          // average GB allocated, based on amount provisioned
  pvCost: 0                       // total cost of persistent volumes allocated
  ramAllocationAverage: 0.0880    // average number of RAM GB allocated over time window, max(request,usage)
  ramCost: 0.006268486            // total cost of RAM allocated
  ramEfficiency: 1.00             // ratio of cost-weighted RAM being utilized
  sharedCost: 0                   // value of costs allocated via sharedOverhead, sharedNamespaces, or sharedLabelNames
  totalCost: 0.059374966          // sum of all costs
}
```

#### Caching Overview

Kubecost implements a two-layer caching system for cost allocation metrics.

First, the unaggregated cost model is pre-cached for commonly used time windows, 1 and 2 days by default. This data is refreshed every \~5 minutes.

Longer time windows, 120 days by default, are part of an ETL pipeline that stores cost by day for each workload. This pipeline is updated approximately \~10 mins. On update, only the latest day is rebuilt to reduce the load on the underlying data store. Currently, this ETL pipeline is stored in memory and is built any time the pod restarts. ETL is built with daily granularity for UI improved performance. Daily aggregations default to `UTC` but timezones can be configured with the `utcOffset` within [values](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml#L102).

Returning cached data from either caching layer typically takes < 300ms on medium-sized clusters. To guarantee you bypass both caches, you can set `etl=false` and `disableCache=false`.

Have questions? Email us at [support@kubecost.com](mailto:support@kubecost.com).
