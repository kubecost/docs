APIs
====

This resource covers primary APIs across open source and commercial Kubecost products.

# Open source APIs

__[/costDataModel](https://github.com/kubecost/docs/blob/main/allocation-api.md#cost-model-api)__

Returns unaggregated cost model rate data at the individual container/workload level. Does not include ETL caching layer and therefore optimal for small to medium-sized clusters.

__/costDataModelRange__

Time-series version of /costDataModel API. Does not include ETL caching layer and therefore optimal for small to medium-sized clusters.

__[/aggregatedCostModel](https://github.com/kubecost/docs/blob/main/allocation-api.md#aggregated-cost-model-api)__

Aggregated version of the costDataModelRange API, which gives cumulative and rate-based data (as opposed to time series data) for a given aggregation (e.g. namespace, deployment, pod). (This API is actively being replaced by the Allocation API.)

# Other APIs (available in Free tier)

__[/allocation](https://github.com/kubecost/docs/blob/main/allocation.md)__

The Kubecost Allocation API is used by the Kubecost Allocation frontend and retrieves cost allocation information for any Kubernetes concept, e.g. cost by namespace, label, deployment, service and more. This API is directly integrated with the Kubecost ETL caching layer and CSV pipeline so it is able to scale to large clusters.

__[/assets](https://github.com/kubecost/docs/blob/main/assets.md)__

Assets API retrieves the backing cost data broken down by individual assets, e.g. node, disk, etc, and provides various aggregations of this data. Optionally provides the ability to integrate with external cloud assets. 

### Savings

Savings endpoints provide cost optimization insights. The following savings endpoints
are available at `http://<kubecost-address>/model/ENDPOINT`:

| Endpoint | Brief description |
|----------|-------------------|
| `/savings` | Provides cluster-level potential savings estimates based on specific savings opportunities available in other endpoints. |
| [`/savings/requestSizing`](https://github.com/kubecost/docs/blob/main/api-request-right-sizing.md) | Provides recommendations for setting container resource requests. |
| `/projectDisks` | List orphaned disks. |
| `/projectAddresses` | List orphaned IP addresses. |
| [`/savings/abandonedWorkloads`](https://github.com/kubecost/docs/blob/main/api-abandoned-workloads.md) | List abandoned workloads based on network traffic.|
| `/savings/clusterSizing` | Provides recommendations for sizing clusters (node types and quantities). | `/savings/diagnostics` | Reports cached keys in the savings handlers and recent errors. |

Edit this doc on [Github](https://github.com/kubecost/docs/blob/main/apis.md)

<!--- {"article":"4407601802391","section":"4402829033367","permissiongroup":"1500001277122"} --->
