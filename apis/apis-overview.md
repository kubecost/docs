# Kubecost API Directory

Welcome to the Kubecost API library! This directory will show you how Kubecost APIs can assist in monitoring, maintaining, and optimizing your cloud spend. Learn also how Kubecost APIs power different features of the UI below.

## Kubecost APIs

### Monitoring APIs

#### [Allocation API](monitoring-apis/api-allocation.md)

The Allocation API retrieves cost allocation information for any Kubernetes concept, e.g. cost by namespace, label, deployment, service, and more. This API is directly integrated with the Kubecost ETL caching layer and CSV pipeline so it can scale for large clusters.

#### [Allocation Trends API](monitoring-apis/allocation-trends-api.md)

The Allocation Trends API compares cost usage between two windows of the same duration and presents a percentage value showing the change in cost.

#### [Assets API](monitoring-apis/assets-api.md)

The Assets API retrieves the backing cost data broken down by individual Kubernetes assets (e.g. node, disk, etc.), and provides various aggregations of this data. Optionally provides the ability to integrate with external cloud assets.

#### [Asset Diff API](monitoring-apis/asset-diff.md)

The Asset Diff API compares two asset sets between two windows of the same duration and accumulates the results.

#### [Cloud Costs API](monitoring-apis/cloud-cost-api.md)

The Cloud Costs API retrieves cloud cost data from cloud providers by reading cost and usage reports.

#### [Cloud Cost Trends API](monitoring-apis/cloud-cost-trends-api.md)

The Cloud Cost Trends API compares cost usage between two windows of the same duration and presents a percentage value showing the change in cloud costs.

### Governance APIs

#### [Budget API](governance-apis/budget-api.md)

The Budget API allows you to establish spending budget rules for your workload across clusters and namespaces to ensure you don't go over your allotted budget.

#### [Cost Events Audit API](governance-apis/cost-events-audit-api.md)

The Cost Events Audit API presents recent changes at the cluster level.

#### [Predict API](governance-apis/spec-cost-prediction-api.md)

The Prediction API takes Kubernetes objects as input and produces an estimation of the cost impact when making changes to your workload.

### Diagnostic APIs

#### [Events API](diagnostic-apis/api-events.md)

The Events API provides a log of different occurrences in your workload in order to help with troubleshooting. Logs generated with this API are helpful for submitting bug reports.

#### [Aggregator Diagnostic APIs](diagnostic-apis/api-aggregator-diagnostics.md)

These diagnostic APIs for [Aggregator](/install-and-configure/install/multi-cluster/federated-etl/aggregator.md) are designed to assist in troubleshooting without inspecting the PV directly.

### Savings APIs

Savings endpoints provide cost optimization insights. The following savings endpoints are available at `http://<kubecost-address>/model/ENDPOINT`:

<table><thead><tr><th width="342">Endpoint</th><th>Description</th></tr></thead><tbody><tr><td><code>/savings</code></td><td>Provides cluster-level potential savings estimates based on specific savings opportunities available in other endpoints.</td></tr><tr><td><a href="savings-apis/cluster-right-sizing-recommendation-api.md"><code>/savings/clusterSizingETL</code></a></td><td>Provides recommendations for sizing clusters (node types and quantities).</td></tr><tr><td><a href="savings-apis/api-request-right-sizing-v2.md"><code>/savings/requestSizingV2</code></a></td><td>Provides recommendations for setting container resource requests.</td></tr><tr><td><a href="savings-apis/api-abandoned-workloads.md"><code>/savings/abandonedWorkloads</code></a></td><td>List abandoned workloads based on network traffic.</td></tr><tr><td><a href="savings-apis/api-request-recommendation-apply.md"><code>/cluster/requestsizer/planV2</code></a></td><td>Applies Kubecost's container request recommendations to your cluster.</td></tr><tr><td><code>/projectDisks</code></td><td>List orphaned disks.</td></tr><tr><td><code>/projectAddresses</code></td><td>List orphaned IP addresses.</td></tr></tbody></table>

## Kubecost UI counterparts

Many, but not all, Kubecost APIs power different features in the Kubecost UI. The UI counterpart may not fully reflect all functionality of the corresponding API. Please consult the original API docs for complete details.

| API Name                                          | UI Equivalent                                                                                                                                    |
| ------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Allocation API                                    | [Allocations dashboard](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/README.md)                                                |
| Allocation/Cloud Cost Explorer Trends API         | Allocations/Cloud Cost Explorer dashboards, Total cost column percentage                                                                                              |
| Assets API                                        | [Assets dashboard](/using-kubecost/navigating-the-kubecost-ui/assets.md)                                                              |
| Cloud Cost API                                    | [Cloud Costs Explorer dashboard](/using-kubecost/navigating-the-kubecost-ui/cloud-costs-explorer/cloud-costs-explorer.md)                                  |
| Budget API                                        | [Budgets dashboard](/using-kubecost/navigating-the-kubecost-ui/budgets.md)                                                            |
| Cost Events Audit API                             | [Audits dashboard](/using-kubecost/navigating-the-kubecost-ui/audits.md)                                                              |
| Predict API                                       | [Audits dashboard, Estimated monthly cost impact](/using-kubecost/navigating-the-kubecost-ui/audits.md#estimated-monthly-cost-impact) |
| Savings API                                       | [Savings dashboard](/using-kubecost/navigating-the-kubecost-ui/savings/savings.md)                                                                                                                  |
| Cluster Right Sizing Recommendation API           | [Cluster Sizing Recommendations page](/using-kubecost/navigating-the-kubecost-ui/savings/cluster-right-sizing-recommendations.md)                                                                    |
| Container Request Right Sizing Recommendation API | [Request right sizing recommendations page](/using-kubecost/navigating-the-kubecost-ui/savings/container-request-right-sizing-recommendations.md)                                                                              |
| Abandoned Workloads API                           | [Abandoned Workloads page](/using-kubecost/navigating-the-kubecost-ui/savings/abandoned-workloads.md)                                                                                               |

## Using the `window` parameter:

Several Kubecost APIs use the `window` parameter to establish the duration of time Kubecost should sample to provide cost metrics, right-sizing recommendations, or other savings information. The following APIs accept `window` as parameter:

* Allocation API
* Allocation Trends API
* Assets API
* Cloud Cost API
* Cloud Cost Trends API
* Spec Cost Prediction API
* Events API
* Aggregator Diagnostic APIs
* Cluster Right-Sizing Recommendation API
* Container Request Right-Sizing Recommendation API

Acceptable formats for using `window` parameter include:

* Common units of time: "15m", "24h", "7d", "48h", etc.
* Relative units of time: "today", "yesterday", "week", "month", "lastweek", "lastmonth"
* Start and end unix timestamps: "1586822400,1586908800"
* Start and end UTC RFC3339 pairs: "2020-04-01T00:00:00Z,2020-04-03T00:00:00Z"