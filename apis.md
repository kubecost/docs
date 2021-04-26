This resource covers primary APIs across open source and commercial Kubecost products.


## Open source APIs

__[/costDataModel](https://github.com/kubecost/docs/blob/2ea9021e8530369d53184ea5382b2e4c080bb426/allocation-api.md#cost-model-api)__

Returns unaggregated cost model rate data at the individual container/workload level. Does not include ETL caching layer and therefore optimal for small to medium-sized clusters.

__/costDataModelRange__

Time-series version of /costDataModel API. Does not include ETL caching layer and therefore optimal for small to medium-sized clusters.


## Other APIs (available in Free tier)

__[/allocation](https://github.com/kubecost/docs/blob/master/allocation.md)__

The Kubecost Allocation API is used by the Kubecost Allocation frontend and retrieves cost allocation information for any Kubernetes concept, e.g. cost by namespace, label, deployment, service and more. This API is directly integrated with the Kubecost ETL caching layer and CSV pipeline so it is able to scale to large clusters.

__[/aggregatedCostModel](https://github.com/kubecost/docs/blob/master/allocation-api.md#aggregated-cost-model-api)__

The aggregated cost model API is actively being replaced by the Kubecost Allocation API.

__[/assets](https://github.com/kubecost/docs/blob/master/assets.md)__

Assets API retrieves the backing cost data broken down by individual assets, e.g. node, disk, etc, and provides various aggregations of this data. Optionally provides the ability to integrate with external cloud assets. 

__[/savings](https://docs.google.com/document/d/1h_LQuTdwzbzcSonZ49w0lktaaHsulNsIj-O0OZR12fc/edit)__

Exposes a set of APIs for cost optimization insights, e.g. pod-rightsizing and more. 

