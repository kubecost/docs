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

#### [Cloud Costs API](monitoring-apis/cloud-cost-api.md)

The Cloud Costs API retrieves cloud cost data from cloud providers by reading cost and usage reports.

#### [Cloud Cost Trends API](monitoring-apis/cloud-cost-trends-api.md)

The Cloud Cost Trends API compares cost usage between two windows of the same duration and presents a percentage value showing the change in cloud costs.

#### [External Costs API](monitoring-apis/external-costs-api.md)

The External Costs API displays costs related to third party services, currently limited to Datadog.

### Governance APIs

#### [Budget API](governance-apis/budget-api.md)

The Budget API allows you to establish spending budget rules for your workloads to ensure you don't go over your allotted budget.

#### [Forecast API](governance-apis/forecast-api.md)

The Forecast API uses a predictive learning model to approximate future spend of Allocation, Assets, or Cloud Cost data.

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
| Allocation API                                    | [Allocations dashboard](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/README.md)                                                    |
| Allocation/Cloud Cost Explorer Trends API         | Allocations/Cloud Cost Explorer dashboards, Total cost column percentage                                                                         |
| Assets API                                        | [Assets dashboard](/using-kubecost/navigating-the-kubecost-ui/assets.md)                                                                         |
| Cloud Cost API                                    | [Cloud Costs Explorer dashboard](/using-kubecost/navigating-the-kubecost-ui/cloud-costs-explorer/cloud-costs-explorer.md)                        |
| External Costs API                                | [External Costs dashboard](/using-kubecost/navigating-the-kubecost-ui/external-costs.md)                                                         |
| Budget API                                        | [Budgets dashboard](/using-kubecost/navigating-the-kubecost-ui/budgets.md)                                                                       |
| Cost Events Audit API                             | [Audits dashboard](/using-kubecost/navigating-the-kubecost-ui/audits.md)                                                                         |
| Predict API                                       | [Audits dashboard, Estimated monthly cost impact](/using-kubecost/navigating-the-kubecost-ui/audits.md#estimated-monthly-cost-impact)            |
| Savings API                                       | [Savings dashboard](/using-kubecost/navigating-the-kubecost-ui/savings/savings.md)                                                               |
| Cluster Right Sizing Recommendation API           | [Cluster Sizing Recommendations page](/using-kubecost/navigating-the-kubecost-ui/savings/cluster-right-sizing-recommendations.md)                |
| Container Request Right Sizing Recommendation API | [Request right sizing recommendations page](/using-kubecost/navigating-the-kubecost-ui/savings/container-request-right-sizing-recommendations.md)|
| Abandoned Workloads API                           | [Abandoned Workloads page](/using-kubecost/navigating-the-kubecost-ui/savings/abandoned-workloads.md)                                            |

## API usage

### Using the `window` parameter

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

### Using the `/topline` endpoint to summarize costs

Several Kubecost  APIs have an additional `/topline` endpoint which will accept all parameters for corresponding APIs, but will total all costs by category. These categories should mirror cost metric column totals found across various Kubecost UI dashboards. The following APIs accept `/topline` as an endpoint:

* Allocation API
* Assets API
* Request Right-Sizing Recommendation API
* Abandoned Workloads API

You must still provide a value for `window` when querying a `/topline` endpoint.

An example of using `/topline` to view total costs for Assets data would look like:

`GET` `http://<your-kubecost-address>/model/assets/topline?window=...`

When querying for Allocation data, you must add a `/summary` before `topline`, and the query for that will look like:

`GET` `http://<your-kubecost-address>/model/allocation/summary/topline?window=...`

### Using `offset` and `limit` parameters to parse payload results

The `offset` and `limit` parameters apply to multiple querying APIs to introduce pagination to your results in order to avoid lengthy payloads. Similar to how Kubecost's UI pages display your queried items in limited amounts per page across multiple pages, these two parameters allow your to filter your displayed results. These following APIs accept `offset` and `limit` as parameters:

* Allocation API
* Assets API
* Cloud Cost API

 Both parameters must be formatted as integers. `offset` refers to how many line items you'd like to offset. `limit` controls how many results per page you would like to see. This means when `offset` is equal to `limit`, you will be offsetting an entire page of line items. You can multiply your `limit` value by the number of pages you'd like to offset to obtain an `offset` value. When using `limit`, you **must** also set the parameter `accumulate` to `true` when possible in order to receive a single list of line items. The order of items across all pages is determined by total cost, where the largest costs are presented first.

 An example of using these parameters in an Allocation query to see results starting from the third page of line items:

`GET` `http://<your-kubecost-address>/model/allocation?window=3d&offset=20&limit=10&accumulate=true`