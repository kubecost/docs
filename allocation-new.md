
## Allocation

The Allocation API is the preferred way to query for costs and resources allocated to Kubernetes workloads, and optionally aggregated by Kubernetes concepts like `namespace`, `controller`, and `label`. Data is served from one of [Kubecost's ETL pipelines](https://github.com/kubecost/docs/blob/master/allocation-api.md#caching-overview). The endpoint is available at the URL:
```
http://<kubecost>/model/allocation
```

### Quick start

Request allocation data for each 24-hour period in the last 3 days, aggregated by namespace:
```
$ curl http://localhost:9090/model/allocation \
  -d window=3d \
  -d aggregate=namespace \
  -d accumulate=false \
  -d shareIdle=false
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
Above, we use `localhost:9090` as the default Kubecost URL (using the command `kubectl port-forward deployment/kubecost-cost-analyzer -n kubecost 9090`) but your Kubecost instance may be exposed by a service or ingress.

See [Querying](#querying) for the full list of arguments and [Examples](#examples) for more example queries.

### Allocation schema (version 1.76)
Field | Description
---: | :---
name |
properties |
window |
start |
end |
minutes |
cpuCores |
cpuCoreRequestAverage |
cpuCoreUsageAverage |
cpuCoreHours |
cpuCost |
cpuEfficiency |
gpuHours |
gpuCost |
networkCost |
pvBytes |
pvByteHours |
pvCost |
ramBytes |
ramByteRequestAverage |
ramByteUsageAverage |
ramByteHours |
ramCost |
ramEfficiency |
sharedCost |
externalCost |
totalCost |
totalEfficiency |

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
- `__idle__` refers to resources on a cluster that were not dedicated to a Kubernetes object. An idle resource can be shared (proportionally or evenly) with the other allocations from the same cluster. (See the argument `shareIdle`.)
- `__unallocated__` refers to aggregated allocations without the selected `aggregate` field; e.g. aggregating by `label:app` might produce an `__unallocated__` allocation composed of allocation without the `app` label.
- `__unmounted__` (or "Unmounted PVs") refers to the resources used by PersistentVolumes that aren't mounted to a Pod using a PVC, and thus cannot be allocated to a Pod.

### Querying

{description of ETL: configuration, build, run, etc.}

```
GET /model/allocation
```
Argument | Description
---: | :---
window (required) | A duration of time over which to query. Accepts: words like `today`, `week`, `month`, `yesterday`, `lastweek`, `lastmonth`; durations like `30m`, `12h`, `7d`; RFC3339 date pairs like `2021-01-02T15:04:05Z,2021-02-02T15:04:05Z`; unix timestamps like `1578002645,1580681045`.
aggregate | A field by which to aggregate the results. Accepts: `cluster`, `namespace`, `controllerKind`, `controller`, `service`, `label:<name>`, and `annotation:<name>`. Also accepts comma-separated lists for multi-aggregation, like `namespace,label:app`.

### Examples
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
      "app:redis": { ... },
      "app:cost-analyzer": { ... },
      "app:prometheus": { ... },
      "app:grafana": { ... },
      "app:nginx": { ... },
      "app:helm": { ... }
    }
  ]
}
```
Allocation data for 2021-03-10 to 2021-03-11 (i.e. 24h), multi-aggregated by namespace and the "app" label, filtering for cluster == cluster-one, and accumulated into one allocation for the entire window.
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
      "kubecost/app:prometheus": { ... },
      "kubecost/app=grafana": { ... },
      "kubecost/app=prometheus": { ... },
      "kube-system/app=helm": { ... }
    }
  ]
}
```

### Querying on-demand (experimental)

{description of resolution, step, and window}

```
GET /model/allocation/compute
```
Argument | Description
---: | :---
window (required) | A duration of time over which to query. Accepts: words like `today`, `week`, `month`, `yesterday`, `lastweek`, `lastmonth`; durations like `30m`, `12h`, `7d`; RFC3339 date pairs like `2021-01-02T15:04:05Z,2021-02-02T15:04:05Z`; unix timestamps like `1578002645,1580681045`.
resolution |
step |
aggregate | A field by which to aggregate the results. Accepts: `cluster`, `namespace`, `controllerKind`, `controller`, `service`, `label:<name>`, and `annotation:<name>`. Also accepts comma-separated lists for multi-aggregation, like `namespace,label:app`.

#### On-demand examples
