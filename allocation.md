# Allocation

The Allocation API is the preferred way to query for costs and resources allocated to Kubernetes workloads, and optionally aggregated by Kubernetes concepts like `namespace`, `controller`, and `label`. Data is served from one of [Kubecost's ETL pipelines](https://github.com/kubecost/docs/blob/master/allocation-api.md#caching-overview). The endpoint is available at the URL:
```
http://<kubecost>/model/allocation
```

> **NOTE**
>
> Throughout, we use `localhost:9090` as the default Kubecost URL, but your Kubecost instance may be exposed by a service or ingress. To reach Kubecost at port 9090, run: `kubectl port-forward deployment/kubecost-cost-analyzer -n kubecost 9090`

## Quick start

Request allocation data for each 24-hour period in the last three days, aggregated by namespace:
```
$ curl http://localhost:9090/model/allocation \
  -d window=3d \
  -d aggregate=namespace \
  -d accumulate=false \
  -d shareIdle=false \
  -G
```
```json
{
  "code": 200,
  "data": [
    {
      "__idle__": { ... },
      "default": { ... },
      "kube-system": { ... },
      "kubecost": { ... }
    },
    {
      "__idle__": { ... },
      "default": { ... },
      "kube-system": { ... },
      "kubecost": { ... }
    },
    {
      "__idle__": { ... },
      "default": { ... },
      "kube-system": { ... },
      "kubecost": { ... }
    },
    {
      "__idle__": { ... },
      "default": { ... },
      "kube-system": { ... },
      "kubecost": { ... }
    }
  ]
}
```

Note: querying for "3d" will likely return a range of four sets because the queried range will overlap with four precomputed 24-hour sets, each aligned to the configured timezone. For instance, querying "3d" on 2021/01/04T12:00:00 will return:
- 2021/01/04 00:00:00 until 2021/01/04T12:00:00 (now)
- 2021/01/03 00:00:00 until 2021/01/04 00:00:00
- 2021/01/02 00:00:00 until 2021/01/03 00:00:00
- 2021/01/01 00:00:00 until 2021/01/02 00:00:00

See [Querying](#querying) for the full list of arguments and [Examples](#query-examples) for more example queries.

## Allocation schema (version 1.76)
Field | Description
---: | :---
name | Name of each relevant Kubernetes concept described by the allocation, delimited by slashes, e.g. "cluster/node/namespace/pod/container"
properties | Map of name-to-value for all relevant property fields, including: `cluster`, `node`, `namespace`, `controller`, `controllerKind`, `pod`, `container`, `labels`, `annotation`, etc.
window | Period of time over which the allocation is defined.
start | Precise starting time of the allocation. By definition must be within the window.
end | Precise ending time of the allocation. By definition must be within the window.
minutes | Number of minutes running; i.e. the minutes from `start` until `end`.
cpuCores | Average number of CPU cores allocated while running.
cpuCoreRequestAverage | Average number of CPU cores requested while running.
cpuCoreUsageAverage | Average number of CPU cores used while running.
cpuCoreHours | Cumulative CPU core-hours allocated.
cpuCost | Cumulative cost of allocated CPU core-hours.
cpuEfficiency | Ratio of `cpuCoreUsageAverage`-to-`cpuCoreRequestAverage`, meant to represent the fraction of requested resources that were used.
gpuHours | Cumulative GPU-hours allocated.
gpuCost | Cumulative cost of allocated GPU-hours.
networkCost | Cumulative cost of network usage.
pvBytes | Average number of bytes of PersistentVolumes allocated while running.
pvByteHours | Cumulative PersistentVolume byte-hours allocated.
pvCost | Cumulative cost of allocated PersistentVolume byte-hours.
ramBytes | Average number of RAM bytes allocated while running.
ramByteRequestAverage | Average number of RAM bytes allocated while running.
ramByteUsageAverage | Average number of RAM bytes used while running.
ramByteHours | Cumulative RAM byte-hours allocated.
ramCost | Cumulative cost of allocated RAM byte-hours.
ramEfficiency | Ratio of `ramByteUsageAverage`-to-`ramByteRequestAverage`, meant to represent the fraction of requested resources that were used.
sharedCost | Cumulative cost of shared resources, including: shared namespaces, shared labels, shared overhead.
externalCost | Cumulative cost of external resources.
totalCost | Total cumulative cost
totalEfficiency | Cost-weighted average of `cpuEfficiency` and `ramEfficiency`. In equation form: `((cpuEfficiency * cpuCost) + (ramEfficiency * ramCost)) / (cpuCost + ramCost)`

### Example allocation
Here is an example allocation for the `cost-model` container in a pod in Kubecost's `kubecost-cost-analyzer` deployment, deployed into the `kubecost` namespace. The `properties` object describes that, as well as the `cluster`, `node`, `services`, `labels`, and `annotations` related to this allocation. Notice that this allocation ran for 10 hours within the given window, using the resources described by their respective values at a cost dictated by the node on which it ran.
```
{
  "name": "cluster-one/gke-niko-pool-2-9182dfa7-okb2/kubecost/kubecost-cost-analyzer-94dc86fc-lwvrm/cost-model",
  "properties": {
    "annotation": {},
    "cluster": "cluster-one",
    "container": "cost-model",
    "controller": "kubecost-cost-analyzer",
    "controllerKind": "deployment",
    "label": {
      "app": "cost-analyzer",
      "app_kubernetes_io_instance": "kubecost",
      "app_kubernetes_io_name": "cost-analyzer",
      "name": "kubecost",
      "pod_template_hash": "94dc86fc"
    },
    "namespace": "kubecost",
    "node": "gke-niko-pool-2-9182dfa7-okb2",
    "pod": "kubecost-cost-analyzer-94dc86fc-lwvrm",
    "service": [
      "kubecost-frontend",
      "kubecost-cost-analyzer"
    ]
  },
  "window": {
    "start": "2021-03-11T00:00:00-07:00",
    "end": "2021-03-12T00:00:00-07:00"
  },
  "start": "2021-03-11T07:00:00Z",
  "end": "2021-03-11T17:00:00Z",
  "minutes": 600,
  "cpuCores": 0.200399,
  "cpuCoreRequestAverage": 0.2,
  "cpuCoreUsageAverage": 0.004317,
  "cpuCoreHours": 2.00399,
  "cpuCost": 0.044344,
  "cpuEfficiency": 0.021583,
  "gpuHours": 0,
  "gpuCost": 0,
  "networkCost": 1.3e-05,
  "pvBytes": 11453246122.666668,
  "pvByteHours": 114532461226.66667,
  "pvCost": 0.005845,
  "ramBytes": 59791087.387687,
  "ramByteRequestAverage": 57671680,
  "ramByteUsageAverage": 52687168.319468,
  "ramByteHours": 597910873.876871,
  "ramCost": 0.001652,
  "ramEfficiency": 0.913571,
  "sharedCost": 0,
  "externalCost": 0,
  "totalCost": 0.051853,
  "totalEfficiency": 0.053611
}
```

### Special types of allocation
- `__idle__` refers to resources on a cluster that were not dedicated to a Kubernetes object (e.g. unused CPU core-hours on a node). An idle resource can be shared (proportionally or evenly) with the other allocations from the same cluster. (See the argument `shareIdle`.)
- `__unallocated__` refers to aggregated allocations without the selected `aggregate` field; e.g. aggregating by `label:app` might produce an `__unallocated__` allocation composed of allocations without the `app` label.
- `__unmounted__` (or "Unmounted PVs") refers to the resources used by PersistentVolumes that aren't mounted to a Pod using a PVC, and thus cannot be allocated to a Pod.

## Querying

```
GET /model/allocation
```
Argument | Default | Description
--: | :--: | :--
window (required) | — | Duration of time over which to query. Accepts: words like `today`, `week`, `month`, `yesterday`, `lastweek`, `lastmonth`; durations like `30m`, `12h`, `7d`; comma-separated RFC3339 date pairs like `2021-01-02T15:04:05Z,2021-02-02T15:04:05Z`; comma-separated unix timestamp (seconds) pairs like `1578002645,1580681045`.
aggregate | | Field by which to aggregate the results. Accepts: `cluster`, `namespace`, `controllerKind`, `controller`, `service`, `node`, `pod`, `label:<name>`, and `annotation:<name>`. Also accepts comma-separated lists for multi-aggregation, like `namespace,label:app`.
accumulate | false | If `true`, sum the entire range of sets into a single set.
idle | true | If `true`, include idle cost (i.e. the cost of the un-allocated assets) as its own allocation. (See [special types of allocation](#special-types-of-allocation).)
external | false | If `true`, include [external costs](http://docs.kubecost.com/getting-started#out-of-cluster) in each allocation.
filterClusters | | Comma-separated list of clusters to match; e.g. `cluster-one,cluster-two` will return results from only those two clusters.
filterNodes | | Comma-separated list of nodes to match; e.g. `node-one,node-two` will return results from only those two nodes.
filterNamespaces | | Comma-separated list of namespaces to match; e.g. `namespace-one,namespace-two` will return results from only those two namespaces.
filterControllerKinds | | Comma-separated list of controller kinds to match; e.g. `deployment,job` will return results with only those two controller kinds.
filterControllers | | Comma-separated list of controllers to match; e.g. `deployment-one,statefulset-two` will return results from only those two controllers.
filterPods | | Comma-separated list of pods to match; e.g. `pod-one,pod-two` will return results from only those two pods.
filterAnnotations | | Comma-separated list of annotations to match; e.g. `name:annotation-one,name:annotation-two` will return results with either of those two annotation key-value-pairs.
filterLabels | | Comma-separated list of annotations to match; e.g. `app:cost-analyzer, app:prometheus` will return results with either of those two label key-value-pairs.
filterServices | | Comma-separated list of services to match; e.g. `frontend-one,frontend-two` will return results with either of those two services.
shareIdle | false | If `true`, idle cost is allocated proportionally across all non-idle allocations, per-resource. That is, idle CPU cost is shared with each non-idle allocation's CPU cost, according to the percentage of the total CPU cost represented.
splitIdle | false | If `true`, and `shareIdle == false` Idle Allocations are created on a per cluster or per node basis rather than being aggregated into a single "\_idle\_" allocation.
idleByNode | false | If `true`, idle allocations are created on a per node basis. Which will result in different values when shared and more idle allocations when split.
reconcile | false | If `true` pulls data from the Assets cache and corrects prices of Allocations according to their related Assets. The corrections from this process are stored in each cost categories cost adjustment field. If the integration with you cloud provider's billing data has been set up, this will result in the most accurate costs for Allocations.
shareOverhead | false | If `true`, share the cost of cluster overhead assets such as cluster management costs and node attached volumes across tenants of those resources. Results are added to the sharedCost field.
shareNamespaces | | Comma-separated list of namespaces to share; e.g. `kube-system, kubecost` will share the costs of those two namespaces with the remaining non-idle, unshared allocations.
shareLabels | | Comma-separated list of labels to share; e.g. `env:staging, app:test` will share the costs of those two label values with the remaining non-idle, unshared allocations.
shareCost | 0.0 | Floating-point value representing a monthly cost to share with the remaining non-idle, unshared allocations; e.g. `30.42` ($1.00/day == $30.42/month) for the query `yesterday` (1 day) will split and distribute exactly $1.00 across the allocations.
shareSplit | weighted | Determines how to split shared costs among non-idle, unshared allocations. By default, the split will be `weighted`; i.e. proportional to the cost of the allocation, relative to the total. The other option is `even`; i.e. each allocation gets an equal portion of the shared cost.

### Query examples
Allocation data for today, unaggregated:
```
$ curl http://localhost:9090/model/allocation \
  -d window=today \
  -G
```
```json
{
  "code": 200,
  "data": [
    {
      "__idle__": { ... },
      "cluster-one/gke-niko-pool-2-9182dfa7-okb2/kubecost/kubecost-cost-analyzer-94dc86fc-lwvrm/cost-model": { ... },
      "cluster-one/gke-niko-pool-2-9182dfa7-okb2/kubecost/kubecost-cost-analyzer-94dc86fc-lwvrm/cost-analyzer-frontend": { ... },
      "cluster-one/gke-niko-pool-2-9182dfa7-okb2/kubecost/kubecost-grafana-6df5cc66b6-dzszt/grafana": { ... }
    }
  ]
}
```
Allocation data for last week, per day, aggregated by cluster:
```
$ curl http://localhost:9090/model/allocation \
  -d window=lastweek \
  -d aggregate=cluster \
  -G
```
```json
{
  "code": 200,
  "data": [
    {
      "__idle__": { ... },
      "cluster-one": { ... },
      "cluster-two": { ... }
    },
    {
      "__idle__": { ... },
      "cluster-one": { ... },
      "cluster-two": { ... }
    },
    {
      "__idle__": { ... },
      "cluster-one": { ... },
      "cluster-two": { ... }
    },
    {
      "__idle__": { ... },
      "cluster-one": { ... },
      "cluster-two": { ... }
    },
    {
      "__idle__": { ... },
      "cluster-one": { ... },
      "cluster-two": { ... }
    },
    {
      "__idle__": { ... },
      "cluster-one": { ... },
      "cluster-two": { ... }
    },
    {
      "__idle__": { ... },
      "cluster-one": { ... },
      "cluster-two": { ... }
    }
  ]
}
```
Allocation data for the last 30 days, aggregated by the "app" label, sharing idle allocation, sharing alloctions from two namespaces, sharing $100/mo in overhead, and accumulated into one allocation for the entire window:
```
$ curl http://localhost:9090/model/allocation \
  -d window=30d \
  -d aggregate=label:app \
  -d accumulate=true \
  -d shareIdle=weighted \
  -d shareNamespaces=kube-system,kubecost
  -d shareCost=100
  -G
```
```json
{
  "code": 200,
  "data": [
    {
      "__unallocated__": { ... },
      "app=redis": { ... },
      "app=cost-analyzer": { ... },
      "app=prometheus": { ... },
      "app=grafana": { ... },
      "app=nginx": { ... },
      "app=helm": { ... }
    }
  ]
}
```
Allocation data for 2021-03-10T00:00:00 to 2021-03-11T00:00:00 (i.e. 24h), multi-aggregated by namespace and the "app" label, filtering by `properties.cluster == "cluster-one"`, and accumulated into one allocation for the entire window.
```
$ curl http://localhost:9090/model/allocation \
  -d window=2021-03-10T00:00:00Z,2021-03-11T00:00:00Z \
  -d aggregate=namespace,label:app \
  -d accumulate=true \
  -d filterClusters=cluster-one \
  -G
```
```json
{
  "code": 200,
  "data": [
    {
      "default/app=redis": { ... },
      "kubecost/app=cost-analyzer": { ... },
      "kubecost/app=prometheus": { ... },
      "kubecost/app=grafana": { ... },
      "kubecost/app=prometheus": { ... },
      "kube-system/app=helm": { ... }
    }
  ]
}
```

## Querying on-demand (experimental)

> :warning: **WARNING**
>
> Querying on-demand with high resolution for long windows can cause serious Prometheus performance issues, including OOM errors. Start with short windows (`1d` or less) and proceed with caution.

Computing allocation data on-demand allows for greater flexibility with respect to step size and accuracy-versus-performance. (See `resolution` and [error bounds](#theoretical-error-bounds) for details.) Unlike the standard endpoint, which can only serve results from precomputed sets with predefined step sizes (e.g. 24h aligned to the UTC timezone), asking for a "7d" query will almost certainly result in 8 sets, including "today" and the final set, which might span 6.5d-7.5d ago. With this endpoint, however, you will be computing everything on-demand, so "7d" will return exactly seven days of data, starting at the moment the query is received. (You can still use window keywords like "today" and "lastweek", of course, which should align perfectly with the same queries of the [standard ETL-driven endpoint](#querying).)

```
GET /model/allocation/compute
```
Argument | Default | Description
--: | :--: | :--
window (required) | — | Duration of time over which to query. Accepts: words like `today`, `week`, `month`, `yesterday`, `lastweek`, `lastmonth`; durations like `30m`, `12h`, `7d`; RFC3339 date pairs like `2021-01-02T15:04:05Z,2021-02-02T15:04:05Z`; unix timestamps like `1578002645,1580681045`.
resolution | 1m | Duration to use as resolution in Prometheus queries. Smaller values (i.e. higher resolutions) will provide better accuracy, but worse performance (i.e. slower query time, higher memory use). Larger values (i.e. lower resolutions) will perform better, but at the expense of lower accuracy for short-running workloads. (See [error bounds](#theoretical-error-bounds) for details.)
step | `window` | Duration of a single allocation set. If unspecified, this defaults to the `window`, so that you receive exactly one set for the entire window. If specified, it works chronologically backwards, querying in durations of `step` until the full window is covered.
aggregate | | Field by which to aggregate the results. Accepts: `cluster`, `namespace`, `controllerKind`, `controller`, `service`, `label:<name>`, and `annotation:<name>`. Also accepts comma-separated lists for multi-aggregation, like `namespace,label:app`.
accumulate | false | If `true`, sum the entire range of sets into a single set.

### On-demand query examples

Allocation data for the last 60m, in steps of 10m, with resolution 1m, aggregated by cluster.
```
$ curl http://localhost:9090/model/allocation/compute \
  -d window=60m \
  -d step=10m \
  -d resolution=1m \
  -d aggregate=cluster \
  -d accumulate=false \
  -G
```
```json
{
  "code": 200,
  "data": [
    {
      "cluster-one": { ... },
      "cluster-two": { ... }
    },
    {
      "cluster-one": { ... },
      "cluster-two": { ... }
    },
    {
      "cluster-one": { ... },
      "cluster-two": { ... }
    }
  ]
}
```

Allocation data for the last 9d, in steps of 3d, with resolution of 10m, aggregated by namespace.
```
$ curl http://localhost:9090/model/allocation/compute \
  -d window=9d \
  -d step=3d \
  -d resolution=10m
  -d aggregate=namespace \
  -d accumulate=false \
  -G
```
```json
{
  "code": 200,
  "data": [
    {
      "default": { ... },
      "kubecost": { ... },
      "kube-system": { ... }
    },
    {
      "default": { ... },
      "kubecost": { ... },
      "kube-system": { ... }
    },
    {
      "default": { ... },
      "kubecost": { ... },
      "kube-system": { ... }
    }
  ]
}
```

### Theoretical error bounds

Tuning the resolution parameter allows the querier to make tradeoffs between accuracy and performance. For long-running pods (>1d) resolution can be tuned aggressively low (>10m) with relatively little affect on accuracy. However, even modestly low resolutions (5m) can result in significant accuracy degradation for short-running pods (<1h).

Here, we provide theoretical error bounds for different resolution values given pods of differing running durations. The tuple represents lower- and upper-bounds for accuracy as a percentage of the actual value. For example:
- 1.00, 1.00 means that results should always be accurate to less than 0.5% error
- 0.83, 1.00 means that results should never be high by more than 0.5% error, but could be low by as much as 17% error
- -1.00, 10.00 means that the result could be as high as 1000% error (e.g. 30s pod being counted for 5m) or the pod could be missed altogether, i.e. -100% error.

| resolution | 30s pod | 5m pod | 1h pod | 1d pod | 7d pod |
|--:|:-:|:-:|:-:|:-:|:-:|
| 1m | -1.00, 2.00 |  0.80, 1.00 |  0.98, 1.00 | 1.00, 1.00 | 1.00, 1.00 |
| 2m | -1.00, 4.00 |  0.80, 1.20 |  0.97, 1.00 | 1.00, 1.00 | 1.00, 1.00 |
| 5m | -1.00, 10.00 | -1.00, 1.00 |  0.92, 1.00 | 1.00, 1.00 | 1.00, 1.00 |
| 10m | -1.00, 20.00 | -1.00, 2.00 |  0.83, 1.00 | 0.99, 1.00 | 1.00, 1.00 |
| 30m | -1.00, 60.00 | -1.00, 6.00 |  0.50, 1.00 | 0.98, 1.00 | 1.00, 1.00 |
| 60m | -1.00, 120.00 | -1.00, 12.00 | -1.00, 1.00 | 0.96, 1.00 | 0.99, 1.00 |
