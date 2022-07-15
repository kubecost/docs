Asset Diff API
====================================

The diff API provides a diff between two windows of all the added or removed assets from the later (before parameter) to the earlier (after parameter) window.

The endpoint is available at
```
http://<kubecost-address>/model/assets/diff
```

## Paramters
| Name | Type | Description |
|------|------|-------------|
| `before` | string | Duration in time of the past. Supports hours or days before the current time in the following format: `2h` or `3d`. See the [Allocation API documentation](https://github.com/kubecost/docs/blob/main/allocation.md#querying) for more a more detailed explanation of valid inputs to `window`. Important note: `before` must be further in the past than `after` (e.g. `after=1d`, `before=1d offset 1d`) |
| `after` | string | Duration in time closest to now. Supports hours or days before the current time in the following format: `2h` or `3d`. See the [Allocation API documentation](https://github.com/kubecost/docs/blob/main/allocation.md#querying) for more a more detailed explanation of valid inputs to `window`. Important note: `after` must be closer to now than `before` (e.g. `before=1d offset 7d`, `after=1d offset 3d`) |
| `aggregate` | string | Used to consolidate cost model data. Passing an empty value for this parameter, or not passing one at all, returns data by an individual asset. |
| `filterClusters` | string | Comma-separated list of clusters to match; e.g. `cluster-one,cluster-two` will return results from only those two clusters. |
| `filterNodes` | string | Comma-separated list of nodes to match; e.g. `node-one,node-two` will return results from only those two nodes. |
| `filterNamespaces` | string | Comma-separated list of namespaces to match; e.g. `namespace-one,namespace-two` will return results from only those two namespaces. |
| `filterLabels` | string | Comma-separated list of annotations to match; e.g. `app:cost-analyzer, app:prometheus` will return results with either of those two label key-value-pairs. |
| `filterServices` | string | Comma-separated list of services to match; e.g. `frontend-one,frontend-two` will return results with either of those two services. |
| `filterControllerKinds` | string | Comma-separated list of controller kinds to match; e.g. `deployment,job` will return results with only those two controller kinds. |
| `filterControllers` | string | Comma-separated list of controllers to match; e.g. `deployment-one,statefulset-two` will return results from only those two controllers. |
| `filterPods` | string | Comma-separated list of pods to match; e.g. `pod-one,pod-two` will return results from only those two pods. |
| `filterAnnotations` | string | Comma-separated list of annotations to match; e.g. `name:annotation-one,name:annotation-two` will return results with either of those two annotation key-value-pairs. |
| `filterContainers` | string | Comma-separated list of containers to match; e.g. `container-one,container-two` will return results from only those two containers. |

## API Examples

```
http://localhost:9090/model/assets/diff?before=yesterday&after=today

http://localhost:9090/model/assets/diff?before=1d offset 5d&after=1d

http://localhost:9090/model/assets/diff?before=lastmonth&after=month

http://localhost:9090/model/assets/diff?before=2022-07-01T00:00:00Z,2022-07-02T00:00:00Z&after=2022-07-06T00:00:00Z,2022-07-07T00:00:00Z

```

## Example API Response

```
{
    ...
    Entity: // this is just a typical asset
        { 
            type: Disk,
            properties: {"category":"Storage","provider":"GCP","project":"guestbook-227502","service":"Kubernetes","cluster":"cluster-one","name":"gke-nick-dev-default-pool-d26dab9e-55qb","providerID":"gke-nick-dev-default-pool-d26dab9e-55qb"},
            labels: {},
            window: {"start":"2022-07-08T00:00:00Z","end":"2022-07-16T00:00:00Z"},
            start: "2022-07-08T00:00:00Z",
            end: "2022-07-15T18:33:00Z",
            minutes: 11193.000000,
            byteHours: 21733694071398.398438,
            bytes: 116503318527.999985,
            breakdown: {"idle":0.9557036583241117,"other":0,"system":0.04429634167588818,"user":0},
            adjustment: 0.000000,
            totalCost: 1.118155
        }
    Kind: "added" // the kind of change it was ("added" or "removed")
    ...
}
```