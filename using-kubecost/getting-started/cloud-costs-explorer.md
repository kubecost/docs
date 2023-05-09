# Cloud Costs Explorer

{% hint style="warning" %}
Cloud Cost is currently in beta. Please read the documentation carefully.
{% endhint %}

The Cloud Cost Explorer is a dashboard which provides visualization and filtering of your cloud spending. This dashboard includes the costs for all assets in your connected cloud accounts by pulling from those providers' Cost and Usage Reports (CURs) or other cloud billing reports.

## Installation and configuration

Cloud Cost needs to be enabled first through Helm, using the following parameters:

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

{% hint style="danger" %}
Disabling Cloud Usage will restrict functionality of your Assets dashboard. This is intentional. Learn more about Cloud Usage [here](https://docs.kubecost.com/install-and-configure/install/cloud-integration#cloud-usage).
{% endhint %}

## UI overview

### Date range

You can adjust your displayed metrics using the date range feature, represented by _Last 7 days_, the default range. This will control the time range of metrics that appear. Select the date range of the report by setting specific start and end dates, or by using one of the preset options.

### Aggregate filters

You can adjust your displayed metrics by aggregating your cost by category. Supported fields are _Workspace, Provider, Billing Account, Service Item_, as well as custom labels. The Cloud Costs Explorer dashboard supports single and multi-aggregation. See the table below for descriptions of each field.

|   Aggregation   | Description                                                                                                                                                |
| :-------------: | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Billing Account | The ID of the billing account your cloud provider bill comes from. (ex: AWS Management/Payer Account ID, GCP Billing Account ID, Azure Billing Account ID) |
|     Provider    | Cloud provider (ex: AWS, Azure, GCP)                                                                                                                       |
|     Service     | Cloud provider services (ex: S3, microsoft.compute, BigQuery)                                                                                              |
|    Workspace    | Cloud provider account (ex: AWS Account, Azure Subscription, GCP Project)                                                                                  |
|       Item      | Individual items from your cloud billing report(s)                                                                                                         |
|      Labels     | Labels/tags on your cloud resources (ex: AWS tags, Azure tags, GCP labels)                                                                                 |

### Edit

Selecting the _Edit_ button will allow for additional filtering and pricing display options for your cloud data.

#### Add filters

You can filter displayed dashboard metrics by selecting _Edit_, then adding a filter. Filters can be created for the following categories (see descriptions of each category in the Aggregate filters table above):

* Service
* Workspace
* Billing Account
* Provider
* Labels

**Cost Metric**

The Cost Metric dropdown allows you to adjust the displayed cost data based on different calculations. Cost Metric values are based on and calculated following standard FinOps dimensions and metrics, as seen in detail [here](https://github.com/finopsfoundation/finops-open-cost-usage-spec/blob/main/specification\_sheet\_import.md). The four available metrics supported by the Cloud Cost UI are:

| Cost Metric        | Description                                                                                 |
| ------------------ | ------------------------------------------------------------------------------------------- |
| Amortized Net Cost | Net Cost with removed cash upfront fees and amortized (default)                             |
| Net Cost           | Costs inclusive of discounts and credits. Will also include one-time and recurring charges. |
| List Cost          | CSP pricing without any discounts                                                           |
| Invoiced Cost      | Pricing based on usage during billing period                                                |

### Table metrics

Your cloud cost spending will be displayed across your dashboard with several key metrics:

* K8 Utilization: Percent of cost which can be traced back to Kubernetes cluster
* Total cost: Total cloud spending
* Sum of Sample Data: **Only when aggregating by **_**Item**_. Only lists the top cost for the timeframe selected. Displays that may not match your CUR.

All line items, after aggregation, should be selectable, allowing you to drill down to further analyze your spending. For example, when aggregating cloud spend by _Service_, you can select an individual cloud service (AmazonEC2, for example) and view spending, K8 utilization, and other details unique to that item.
