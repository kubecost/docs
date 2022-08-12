Asset Diff API
====================================

The diff API provides a diff of two windows that returns all the added, removed, or cost changed assets from the later window (before parameter) to the earlier window (after parameter). This endpoint does a comparison of two asset sets in the given windows and accumulates the results.

The endpoint is available at
```
http://<kubecost-address>/model/assets/diff
```

## Paramters
| Name | Type | Description |
|------|------|-------------|
| `before` | string | Duration in time of the past. Supports hours or days before the current time in the following format: `2h` or `3d`. See the [Allocation API documentation](https://github.com/kubecost/docs/blob/main/allocation.md#querying) for more a more detailed explanation of valid inputs to `window`. Important note: `before` must be further in the past than `after` (e.g. `after=1d`, `before=1d offset 1d`) |
| `after` | string | Duration in time closest to now. Supports hours or days before the current time in the following format: `2h` or `3d`. See the [Allocation API documentation](https://github.com/kubecost/docs/blob/main/allocation.md#querying) for more a more detailed explanation of valid inputs to `window`. Important note: `after` must be closer to now than `before` (e.g. `before=1d offset 7d`, `after=1d offset 3d`) |
| `costChangeRatio` | float64 | Changes the ratio of cost changes when displaying 'Changed' types. e.g. `costChangeRatio=0.1` will display all assets that had a cost change of 0.1 (10%) or more. Defaults to 0.05 (5%). |
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
// Compare yesterdays assets to todays assets
http://localhost:9090/model/assets/diff?before=yesterday&after=today

// Compare assets from 5 days ago to assets from the last day
http://localhost:9090/model/assets/diff?before=1d offset 5d&after=1d

// Compare assets from last month to assets from this month
http://localhost:9090/model/assets/diff?before=lastmonth&after=month

// Compare assets on 07/01/2022 to assets on 07/06/2022
http://localhost:9090/model/assets/diff?before=2022-07-01T00:00:00Z,2022-07-02T00:00:00Z&after=2022-07-06T00:00:00Z,2022-07-07T00:00:00Z

// Compare yesterdays assets to todays assets, displaying all assets that have a total cost change of 10% or more
http://localhost:9090/model/assets/diff?before=yesterday&after=today&costChangeRatio=0.1
```

## Example API Response

```
{
    ...
    "__undefined__/__undefined__/__undefined__/Storage/__undefined__/Disk/Kubernetes/gke-nick-dev-default-pool-d26dab9e-55qb/gke-nick-dev-default-pool-d26dab9e-55qb":
        {
            Entity: // this is a typical asset
                {
                    type: "Disk",
                    properties: {"category":"Storage","service":"Kubernetes","name":"gke-nick-dev-default-pool-d26dab9e-55qb","providerID":"gke-nick-dev-default-pool-d26dab9e-55qb"},
                    labels: {},
                    window: {"start":"2022-07-18T22:00:00Z","end":"2022-07-19T22:00:00Z"},
                    start: "2022-07-18T15:00:00-07:00",
                    end: "2022-07-19T14:43:00-07:00",
                    minutes: 1423.000000,
                    byteHours: 2763070371089.066895,
                    bytes: 116503318528.000015,
                    breakdown: {"idle":0.9518633801103309,"other":0,"system":0.04813661988966931,"user":0},
                    adjustment: 0.000000,
                    totalCost: 0.144021
                },
            Kind: "added" // the type of change ("added", "removed", or "changed")
        }
    ...
}
```