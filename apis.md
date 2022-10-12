APIs
====

This resource covers primary APIs across open source and commercial Kubecost products.


# Open source APIs

__[/costDataModel](https://github.com/kubecost/docs/blob/2ea9021e8530369d53184ea5382b2e4c080bb426/allocation-api.md#cost-model-api)__

Returns unaggregated cost model rate data at the individual container/workload level. It does not include the ETL caching layer and is therefore optimal for small to medium-sized clusters.

__/costDataModelRange__

Time-series version of /costDataModel API. It does not include the ETL caching layer is and therefore optimal for small to medium-sized clusters.


# Other APIs (available in Free tier)

__[/allocation](https://github.com/kubecost/docs/blob/main/allocation.md)__

The Kubecost Allocation API is used by the Kubecost Allocation frontend and retrieves cost allocation information for any Kubernetes concept, e.g. cost by namespace, label, deployment, service, and more. This API is directly integrated with the Kubecost ETL caching layer and CSV pipeline so it can scale for large clusters.

__[/aggregatedCostModel](https://github.com/kubecost/docs/blob/main/allocation-api.md#aggregated-cost-model-api)__

The aggregated cost model API is actively being replaced by the Kubecost Allocation API.

__[/assets](https://github.com/kubecost/docs/blob/main/assets.md)__

The assets API retrieves the backing cost data broken down by individual assets, e.g. node, disk, etc, and provides various aggregations of this data. Optionally provides the ability to integrate with external cloud assets.

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


Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/apis.md)

<!--- {"article":"4407601802391","section":"4402829033367","permissiongroup":"1500001277122"} --->
