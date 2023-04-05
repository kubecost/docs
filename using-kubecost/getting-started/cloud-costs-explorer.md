# Cloud Costs Explorer

> **Note**: Cloud Cost is currently in beta. Please read the documentation carefully.

The Cloud Cost Explorer is a dashboard which provides visualizations of your cloud spending.

### Installation and configuration

Cloud Cost will not be available in Kubecost upon fresh install like other similar dashboards. It needs to be enabled first through Helm, using the following parameters:

```
kubecostModel:
  cloudCost:
     enabled: true
     labelList:
       isIncludeList: false
       # format labels as comma separated string (ex. "label1,label2,label3")
       labels: ""
     topNItems: 1000
```

Enabling Cloud Cost is required. Optional parameters include:

* `labelList.labels`: Comma separated list of labels; empty string indicates that the list is disabled
* `labelList.isIncludeList`: If true, label list is a white list; if false, it is a black list
* `topNItems`: number of sampled "top items" to collect per day

While Cloud Cost is enabled, it is recommended to disable Cloud Usage, which is more memory-intensive.

```
kubecostModel:
  etlCloudUsage: false
```

> **Note**: Disabling Cloud Usage will restrict functionality of your Assets dashboard. Learn more about Cloud Usage [here](https://docs.kubecost.com/install-and-configure/install/cloud-integration#cloud-usage).

### Date range

You can adjust your displayed metrics using the date range feature, represented by _Last 7 days_, the default range. This will control the time range of metrics that appear. Select the date range of the report by setting specific start and end dates, or by using one of the preset options. Select _Apply_ to make changes.

### Aggregate filters

You can adjust your displayed metrics by aggregating your cost by category. Supported fields are _Billing Account_, _Provider_, _Service_, and _Workspace_, as well as custom labels. The Cloud Costs Explorer dashboard supports single and multi-aggregation.

|   Aggregation   | Description                                                                                                                                                      |
| :-------------: | ---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Billing Account | The ID of the billing account your cloud provider bill comes from. (Examples: AWS Management/Payer Account ID, GCP Billing Account ID, Azure Billing Account ID) |
|     Provider    | Cloud provider (Examples: AWS, Azure, GCP)                                                                                                                       |
|     Service     | Cloud provider services (Examples: AWS - S3, Azure - microsoft.compute, GCP - BigQuery)                                                                          |
|    Workspace    | Cloud provider account (Examples: AWS Account, Azure Subscription, GCP Project)                                                                                  |
|      Labels     | Labels/tags on your cloud resources (Examples: AWS tags, Azure tags, GCP labels)                                                                                 |

### Add filters

You can filter displayed dashboard metrics by selecting _Edit_, then adding a filter. Filters can be created for the following categories (see descriptions of each category in the Aggregate filters table above):

* Service
* Workspace
* Billing Account
* Provider
* Labels

### Table metrics

Your cloud cost spending will be displayed across your dashboard with several key metrics:

* Credits: Discounts and credits applied
* K8 Utilization: Percent of cost which can be traced back to Kubernetes cluster
* Total cost: Total cloud spending
