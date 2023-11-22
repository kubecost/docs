# Kubecost API Directory

Welcome to the Kubecost API library! This directory will show you how Kubecost APIs can assist in monitoring, maintaining, and optimizing your cloud spend. Learn also how Kubecost APIs power different features of the UI below.

## Monitoring APIs

### [**Allocation API**](api-allocation.md)

The Allocation API retrieves cost allocation information for any Kubernetes concept, e.g. cost by namespace, label, deployment, service, and more. This API is directly integrated with the Kubecost ETL caching layer and CSV pipeline so it can scale for large clusters.

### [Allocation Trends API](allocation-trends-api.md)

The Trends API compares cost usage between two windows of the same duration and presents a percentage value showing the change in cost.

### [**Assets API**](assets-api.md)

The Assets API retrieves the backing cost data broken down by individual Kubernetes assets (e.g. node, disk, etc.), and provides various aggregations of this data. Optionally provides the ability to integrate with external cloud assets.

### [Asset Diff API](asset-diff.md)

The Asset Diff API compares two asset sets between two windows of the same duration and accumulates the results.

### [Cloud Costs API](cloud-cost-api.md)

The Cloud Costs API retrieves cloud cost data from cloud providers by reading cost and usage reports.

## Governance APIs

### [Budget API](budget-api.md)

The Budget API allows you to establish spending budget rules for your workload across clusters and namespaces to ensure you don't go over your allotted budget.

### [Cost Events Audit API](cost-events-audit-api.md)

The Cost Events Audit API presents recent changes at the cluster level.

### [Predict API](spec-cost-prediction-api.md)

The Prediction API takes Kubernetes objects as input and produces an estimation of the cost impact when making changes to your workload.

## Diagnostic APIs

### [**Events API**](api-events.md)

The Events API provides a log of different occurrences in your workload in order to help with troubleshooting. Logs generated with this API are helpful for submitting bug reports.

## Optimization APIs

### Savings API

Savings endpoints provide cost optimization insights. The following savings endpoints are available at `http://<kubecost-address>/model/ENDPOINT`:

<table><thead><tr><th width="342">Endpoint</th><th>Brief description</th></tr></thead><tbody><tr><td><code>/savings</code></td><td>Provides cluster-level potential savings estimates based on specific savings opportunities available in other endpoints.</td></tr><tr><td><a href="cluster-right-sizing-recommendation-api.md"><code>/savings/clusterSizingETL</code></a></td><td>Provides recommendations for sizing clusters (node types and quantities).</td></tr><tr><td><a href="api-request-right-sizing-v2.md"><code>/savings/requestSizingV2</code></a></td><td>Provides recommendations for setting container resource requests.</td></tr><tr><td><a href="api-abandoned-workloads.md"><code>/savings/abandonedWorkloads</code></a></td><td>List abandoned workloads based on network traffic.</td></tr><tr><td><a href="api-request-recommendation-apply.md"><code>/cluster/requestsizer/planV2</code></a></td><td>Applies Kubecost's container request recommendations to your cluster.</td></tr><tr><td><code>/projectDisks</code></td><td>List orphaned disks.</td></tr><tr><td><code>/projectAddresses</code></td><td>List orphaned IP addresses.</td></tr></tbody></table>

## Kubecost UI counterparts

Many, but not all, Kubecost APIs power different features in the Kubecost UI. The UI counterpart may not fully reflect all functionality of the corresponding API. Please consult the original API docs for complete details.

| API Name                                          | UI Equivalent                                                                                                                                    |
| ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Allocation API                                    | [Allocations dashboard](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/README.md)                                                |
| Allocation Trends API                             | Allocations dashboard, Total cost column percentage                                                                                              |
| Assets API                                        | [Assets dashboard](/using-kubecost/navigating-the-kubecost-ui/assets.md)                                                              |
| Cloud Cost API                                    | [Cloud Costs Explorer dashboard](/using-kubecost/navigating-the-kubecost-ui/cloud-costs-explorer.md)                                  |
| Budget API                                        | [Budgets dashboard](/using-kubecost/navigating-the-kubecost-ui/budgets.md)                                                            |
| Cost Events Audit API                             | [Audits dashboard](/using-kubecost/navigating-the-kubecost-ui/audits.md)                                                              |
| Predict API                                       | [Audits dashboard, Estimated monthly cost impact](/using-kubecost/navigating-the-kubecost-ui/audits.md#estimated-monthly-cost-impact) |
| Savings API                                       | [Savings dashboard](/using-kubecost/navigating-the-kubecost-ui/savings/savings.md)                                                                                                                  |
| Cluster Right Sizing Recommendation API           | [Cluster Sizing Recommendations page](/using-kubecost/navigating-the-kubecost-ui/savings/cluster-right-sizing-recommendations.md)                                                                    |
| Container Request Right Sizing Recommendation API | [Request right sizing recommendations page](/using-kubecost/navigating-the-kubecost-ui/savings/container-request-right-sizing-recommendations.md)                                                                              |
| Abandoned Workloads API                           | [Abandoned Workloads page](/using-kubecost/navigating-the-kubecost-ui/savings/abandoned-workloads.md)                                                                                               |
