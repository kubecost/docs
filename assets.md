The Kubecost Assets view shows Kubernetes cluster costs broken down by the individual backing assets in your cluster (e.g. cost by node, disk, and other assets). 
It’s used to identify spend drivers over time and to audit Allocation data. 

![Kubecost Assets view](images/assets-screenshot.png)

# Assets API

The cluster assets API retrieves the backing cost data broken down by individual assets in your cluster but also provides various aggregations of this data.

The API is available at the following endpoint:

```
http://<your-kubecost-address>/model/assets
```

Here are example uses:

* http://localhost:9090/model/assets?window=today
* http://localhost:9090/model/assets?window=7d
* http://localhost:9090/model/assets?window=7d&aggregate=type
* http://localhost:9090/model/assets?window=7d&aggregate=type&accumulate=true

API parameters include the following:

* `window` dictates the applicable window for measuring historical asset cost. Currently supported options are as follows:
    - "15m", "24h", "7d", "48h", etc. 
    - "today", "yesterday", "week", "month", "lastweek", "lastmonth"
    - "1586822400,1586908800", etc. (start and end unix timestamps)
    - "2020-04-01T00:00:00Z,2020-04-03T00:00:00Z", etc. (start and end UTC RFC3339 pairs)
* `aggregate` is used to consolidate cost model data. Supported aggregation types are cluster and type. Passing an empty value for this parameter, or not passing one at all, returns data by individual asset.
* `accumulate` when set to false this endpoint returns daily time series data vs cumulative data. Default value is false.
* `disableAdjustments` when set to true, zeros out all adjustments from cloud provider reconciliation, which would otherwise change the totalCost.

This API returns a set of JSON objects in this format:

```
  {
  cluster: "cluster-one"  // parent cluster for asset
  cpuCores: 2  // number of CPUs, given this is a node asset type
  cpuCost: 0.047416 // cumulative cost of CPU measured over time window
  discount: 0.3 // discount applied to asset cost
  end: "2020-08-21T00:00:00+0000" // end of measured time window
  gpuCost: 0
  key: "cluster-one/node/gke-niko-n1-standard-2-wljla-8df8e58a-hfy7"
  name: "gke-niko-n1-standard-2-wljla-8df8e58a-hfy7"
  nodeType: "n1-standard-2"
  preemptible: 0
  providerID: "gke-niko-n1-standard-2-wljla-8df8e58a-hfy7"
  ramBytes: 7840256000
  ramCost: 0.023203
  start: "2020-08-20T00:00:00+0000"
  adjustment: 0.0023 // amount added to totalCost during reconciliation with cloud provider data
  totalCost: 0.049434 // total asset cost after applied discount 
  type: "node" // e.g. node, disk, cluster management fee, etc
}
```
