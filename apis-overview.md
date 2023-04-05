# Kubecost API Directory

Welcome to the Kubecost API library! This directory will show you how Kubecost APIs can assist in monitoring, maintaining, and optimizing your cloud spend. Also learn how Kubecost APIs power different features of the UI below.

## Monitoring APIs

### [**Allocation API**](allocation.md)

The Allocation API retrieves cost allocation information for any Kubernetes concept, e.g. cost by namespace, label, deployment, service, and more. This API is directly integrated with the Kubecost ETL caching layer and CSV pipeline so it can scale for large clusters.

### [Allocation Trends API](https://docs.kubecost.com/apis/apis-overview/allocation-trends-api)

The Trends API compares cost usage between two windows of the same duration and presents a percentage value showing the change in cost.

### [**Assets API**](assets-api.md)

The Assets API retrieves the backing cost data broken down by individual Kubernetes assets (e.g. node, disk, etc.), and provides various aggregations of this data. Optionally provides the ability to integrate with external cloud assets.

### [Asset Diff API](https://docs.kubecost.com/apis/apis-overview/asset-diff)

The Asset Diff API compares two asset sets between two windows of the same duration and accumulates the results.

### [Cloud Costs API](https://docs.kubecost.com/apis/apis-overview/cloud-cost-api)

The Cloud Costs API retrieves cloud cost data from cloud providers by reading cost and usage reports. Unlike the Allocation and Asset APIs, it must be manually enabled.

## Governance APIs

### [Budget API](https://docs.kubecost.com/apis/apis-overview/budget-api)

The Budget API allows you to establish spend budget rules for your workload across clusters and namespaces to ensure you don't go over your alloted budget.

### [Cost Events Audit API](https://docs.kubecost.com/apis/apis-overview/cost-events-audit-api)

The Cost Events Audit API presents recent changes at the cluster level.

### [Predict API](https://docs.kubecost.com/apis/apis-overview/spec-cost-prediction-api)

The Prediction API takes Kubernetes objects as input and produces an estimation of the cost impact when making changes to your workload.

## Diagnostic APIs

### [**Events API**](api-events.md)

The Events API provides a log of different occurrences in your workload in order to help with troubleshooting. Logs generated with this API are helpful for submitting bug reports.

### [**Audit API**](audit-api.md)

The Audit API verifies cached data sources of Kubecost for validity of the data sources and processes through a series of tests.

## Optimization APIs

### Savings API

Savings endpoints provide cost optimization insights. The following savings endpoints are available at `http://<kubecost-address>/model/ENDPOINT`:

| Endpoint                                                                                                                       | Brief description                                                                                                        |
| ------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------ |
| `/savings`                                                                                                                     | Provides cluster-level potential savings estimates based on specific savings opportunities available in other endpoints. |
| [`/savings/requestSizingV2`](https://docs.kubecost.com/apis/apis-overview/api-request-right-sizing-v2)                         | Provides recommendations for setting container resource requests.                                                        |
| `/projectDisks`                                                                                                                | List orphaned disks.                                                                                                     |
| `/projectAddresses`                                                                                                            | List orphaned IP addresses.                                                                                              |
| [`/savings/abandonedWorkloads`](api-abandoned-workloads.md)                                                                    | List abandoned workloads based on network traffic.                                                                       |
| `/savings/clusterSizing`                                                                                                       | Provides recommendations for sizing clusters (node types and quantities).                                                |
| [Container Request Recommendation "Apply" APIs](https://docs.kubecost.com/apis/apis-overview/api-request-recommendation-apply) | Applies Kubecost's container request recommendations to your cluster.                                                    |

## Kubecost UI counterparts

Many, but not all, Kubecost APIs power different features in the Kubecost UI. The UI counterpart may not fully reflect all functionality of the corresponding API. Please consult the original API docs for complete details.

| API Name              | UI Equivalent                                                                                                                                    |
| --------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------ |
| Allocation API        | [Allocations dashboard](https://docs.kubecost.com/using-kubecost/getting-started/cost-allocation)                                                |
| Allocation Trends API | Allocations dashboard, Total cost column percentage                                                                                              |
| Assets API            | [Assets dashboard](https://docs.kubecost.com/using-kubecost/getting-started/assets)                                                              |
| Cloud Cost API        | [Cloud Costs Explorer dashboard](https://docs.kubecost.com/using-kubecost/getting-started/cloud-costs-explorer)                                  |
| Budget API            | [Budgets dashboard](https://docs.kubecost.com/using-kubecost/getting-started/budgets)                                                            |
| Cost Events Audit API | [Audits dashboard](https://docs.kubecost.com/using-kubecost/getting-started/audits)                                                              |
| Predict API           | [Audits dashboard, Estimated monthly cost impact](https://docs.kubecost.com/using-kubecost/getting-started/audits#estimated-monthly-cost-impact) |
| Savings API           | Savings dashboard                                                                                                                                |
