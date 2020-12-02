# Cost Allocation API

The cost allocation API is an internal API that provides workload allocation data from the daily [Kubecost ETL pipeline](https://github.com/kubecost/docs/blob/master/allocation-api.md#caching-overview) and powers the Kubecost Reports view. 
Given the internal status it is subject to change. The endpoint is available at the following address:

`http://<kubecost-address>/model/allocation`

Here are example uses:

* http://localhost:9090/model/allocation?window=today
* http://localhost:9090/model/allocation?window=7d&aggregate=namespace&shareIdle=false
* http://localhost:9090/model/allocation?window=week&aggregate=cluster,namespace 

API parameters include the following:

* `window` dictates the applicable window for measuring historical asset cost. Currently supported options are as follows:
  * "15m", "24h", "7d", "48h", etc. 
  * "today", "yesterday", "week", "month", "lastweek", "lastmonth"
  * "1586822400,1586908800", etc. (start and end unix timestamps)
  * "2020-04-01T00:00:00Z,2020-04-03T00:00:00Z", etc. (start and end UTC RFC3339 pairs)
* `aggregate` is used to consolidate cost model data. Supported types are cluster, namespace, deployment, controller, service, and label.
* `accumulate` when set to false this endpoint returns daily time series data vs cumulative data. Default value is false.
* `shareIdle` (optional) when set to true applies the cost of all idle compute resources to tenants, default false.
* `shareCost` (optional) a fixed external monthly amount to be split between tenants, e.g. `1000`
* `shareNamespaces`(optional) a CSV list of Kubernetes namespaces whose costs should be shared, e.g. `kubecost`
* `shareLabels`(optional) a CSV list of Kubernetes labels whose costs should be shared, e.g. `app:prometheus`
* `shareSplit` to be used with shareCost, shareNamespaces, or shareLabels. Supported options: `weighted` (to share proportionate to tenant cost) and `even` (to share cost uniformly)

This API returns a set of JSON objects in this format:

```
{
  cpuCoreHours: 0.05
  cpuCost: 0.083
  cpuEfficiency: .87
  end: "2020-09-14T00:00:00+01:00"
  gpuCost: 0
  gpuHours: 0
  minutes: 1440
  name: "data-science"    // value of aggregator 
  networkCost: 0
  properties: {cluster: "cluster-one"}
  pvByteHours: 0
  pvCost: 0
  ramByteHours: 123684420.26
  ramCost: 0.023
  ramEfficiency: .56
  sharedCost: 0
  start: "2020-09-13T00:00:00+01:00"
  totalCost: 0.024
  totalEfficiency: .72
}
```
