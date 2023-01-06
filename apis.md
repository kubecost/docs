# Kubecost API Directory

This resource covers primary APIs across open source and commercial Kubecost products.

## Open source APIs

**/costDataModelRange**

Time-series version of /costDataModel API. It does not include the ETL caching layer is and therefore optimal for small to medium-sized clusters.

## Other APIs (available in Free tier)

[**/allocation**](allocation.md)

The Kubecost Allocation API is used by the Kubecost Allocation frontend and retrieves cost allocation information for any Kubernetes concept, e.g. cost by namespace, label, deployment, service, and more. This API is directly integrated with the Kubecost ETL caching layer and CSV pipeline so it can scale for large clusters.

[**/aggregatedCostModel**](allocation-api.md#aggregated-cost-model-api)

The aggregated cost model API is actively being replaced by the Kubecost Allocation API.

****[**/assets**](assets-api.md)****

The assets API retrieves the backing cost data broken down by individual assets, e.g. node, disk, etc, and provides various aggregations of this data. Optionally provides the ability to integrate with external cloud assets.

#### Savings

Savings endpoints provide cost optimization insights. The following savings endpoints are available at `http://<kubecost-address>/model/ENDPOINT`:

| Endpoint                                                     | Brief description                                                                                                        |
| ------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| `/savings`                                                   | Provides cluster-level potential savings estimates based on specific savings opportunities available in other endpoints. |
| [`/savings/requestSizingV2`](api-request-right-sizing-v2.md) | Provides recommendations for setting container resource requests.                                                        |
| [`/savings/requestSizing`](api-request-right-sizing.md)      | (DEPRECATED, use v2) Provides recommendations for setting container resource requests.                                   |
| `/projectDisks`                                              | List orphaned disks.                                                                                                     |
| `/projectAddresses`                                          | List orphaned IP addresses.                                                                                              |
| [`/savings/abandonedWorkloads`](api-abandoned-workloads.md)  | List abandoned workloads based on network traffic.                                                                       |
| `/savings/clusterSizing`                                     | Provides recommendations for sizing clusters (node types and quantities).                                                |
