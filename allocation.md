# Cost Allocation API

The cost allocation API provides workload allocation data from the daily [Kubecost ETL pipeline](https://github.com/kubecost/docs/blob/master/allocation-api.md#caching-overview) and powers the Kubecost Reports view. Workloads can be aggregated by any Kubernetes concept, e.g. namespace, label, controller, service, pod, etc. The endpoint is available at the following address:

`http://<kubecost-address>/model/allocation`

Here are example uses:

* http://localhost:9090/model/allocation?window=today
* http://localhost:9090/model/allocation?window=7d&aggregate=namespace&shareIdle=false
* http://localhost:9090/model/allocation?window=week&aggregate=cluster,namespace 
* http://localhost:9090/model/allocation?window=week&aggregate=label:app,label:component

API parameters include the following:

* `window` dictates the applicable window for measuring historical cost. Given this API uses the Kubecost ETL pipeline, data is returned with daily resolution. For more granular cost metrics, view the [aggregatedCostModel API](https://github.com/kubecost/docs/blob/master/allocation-api.md#aggregated-cost-model-api).  Supported time window options are as follows:
  * "15m", "24h", "7d", "48h", etc. 
  * "today", "yesterday", "week", "month", "lastweek", "lastmonth"
  * "1586822400,1586908800", etc. (start and end unix timestamps)
  * "2020-04-01T00:00:00Z,2020-04-03T00:00:00Z", etc. (start and end UTC RFC3339 pairs)
* `aggregate` is used to consolidate cost model data. Supported types are cluster, namespace, deployment, controller, service, and label. With labels, a CSV with label:key format is used.
* `accumulate` when set to false this endpoint returns daily time series data vs cumulative data. Default value is false.
* `shareIdle` (optional) when set to true applies the cost of all idle compute resources to tenants, default false.
* `shareCost` (optional) a fixed external monthly amount to be split between tenants, e.g. `1000`
* `shareNamespaces`(optional) a CSV list of Kubernetes namespaces whose costs should be shared, e.g. `kubecost`
* `shareLabels`(optional) a CSV list of Kubernetes labels whose costs should be shared, e.g. `app:prometheus`
* `shareSplit` to be used with shareCost, shareNamespaces, or shareLabels. Supported options: `weighted` (to share proportionate to tenant cost) and `even` (to share cost uniformly)

This API returns a set of JSON objects in this format:

```
{
  cpuCoreHours: 0.05                     // cumulative hours of CPU cores consumed
  cpuCost: 0.083                         // total cost of CPU allocated
  cpuEfficiency: .87                     // percentage of CPU requested that is utilized, weighted by cost
  end: "2020-09-14T00:00:00+01:00"       // end of window
  gpuCost: 0                             // total cost of GPU allocated 
  gpuHours: 0                            // cumulative hours of GPU consumed, in # of GPUs
  minutes: 1440                          // cumulative count of minutes running
  name: "data-science"                   // value of aggregator 
  networkCost: 0                         // measured cost of network egress
  properties: {cluster: "cluster-one"}   // meta-data for this aggregation
  pvByteHours: 100                       // cumulative hours of disk consumed, in bytes
  pvCost: .70                            // total cost of persistent volume allocated
  ramByteHours: 123684420.26             // cumulative hours of RAM consumed, in bytes
  ramCost: 0.023                         // total cost of RAM allocated
  ramEfficiency: .56                     // percentage of RAM requested that is utilized, weighted by cost
  sharedCost: 0
  start: "2020-09-13T00:00:00+01:00"     // beginning of window
  totalCost: 0.024                       // sum of all costs
  totalEfficiency: .72                   // percentage of RAM + CPU equested that is utilized, weighted by cost
}
```
