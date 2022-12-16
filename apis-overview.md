Kubecost APIs Overview
====

## API Directory

This resource covers primary APIs across open source and commercial Kubecost products, and includes a directory to up-to-date API documentation articles.

__[/allocation](/allocation.md)__

The Allocation API is used by the Kubecost Allocation frontend and retrieves cost allocation information for any Kubernetes concept, e.g. cost by namespace, label, deployment, service, and more. This API is directly integrated with the Kubecost ETL caching layer and CSV pipeline so it can scale for large clusters.

__[/assets](/assets-api.md)__

The Assets API retrieves the backing cost data broken down by individual assets, e.g. node, disk, etc, and provides various aggregations of this data. Optionally provides the ability to integrate with external cloud assets.

__[/audit](/audit-api.md)__

The Audit API varifies cached data sources of Kubecost for validity of the data sources and processes through a series of tests.

### /savings

Savings endpoints provide cost optimization insights. The following savings endpoints
are available at `http://<kubecost-address>/model/ENDPOINT`:

| Endpoint | Brief description |
|----------|-------------------|
| `/savings` | Provides cluster-level potential savings estimates based on specific savings opportunities available in other endpoints. |
| [`/savings/requestSizing`](/api-request-right-sizing.md) | Provides recommendations for setting container resource requests. |
| `/projectDisks` | List orphaned disks. |
| `/projectAddresses` | List orphaned IP addresses. |
| [`/savings/abandonedWorkloads`](/api-abandoned-workloads.md) | List abandoned workloads based on network traffic.|
| `/savings/clusterSizing` | Provides recommendations for sizing clusters (node types and quantities). | `/savings/diagnostics` | Reports cached keys in the savings handlers and recent errors. |
