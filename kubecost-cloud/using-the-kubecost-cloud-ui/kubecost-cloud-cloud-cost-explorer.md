# Kubecost Cloud: Cloud Cost Explorer

{% hint style="info" %}
This documentation should only be consulted when using Kubecost Cloud! For information about the Cloud Cost Explorer dashboard for self-hosted Kubecost, see [here](https://docs.kubecost.com/using-kubecost/navigating-the-kubecost-ui/assets).
{% endhint %}

The Cloud Cost Explorer is a dashboard which provides visualization and filtering of your cloud spending. This dashboard includes the costs for all assets in your connected cloud accounts by pulling from those providers' Cost and Usage Reports (CURs) or other cloud billing reports.

For help on integrating one or several cloud service providers (CSPs), see the corresponding documentation:

* [Kubecost Cloud: Cloud Billing Integrations](https://docs.kubecost.com/kubecost-cloud/kubecost-cloud-cloud-billing-integrations)
* [Kubecost Cloud GCP Integration](https://docs.kubecost.com/kubecost-cloud/kubecost-cloud-cloud-billing-integrations/kubecost-cloud-gcp-integration)
* [Kubecost Cloud Azure Integration](https://docs.kubecost.com/kubecost-cloud/kubecost-cloud-cloud-billing-integrations/kubecost-cloud-azure-integration)

## UI Overview

### Date range

You can adjust your displayed metrics using the date range feature, represented by _Last 7 days_, the default range. This will control the time range of metrics that appear. Select the date range of the report by setting specific start and end dates, or by using one of the preset options.

### Aggregate filters

You can adjust your displayed metrics by aggregating your cost by category. Supported fields are _Account, Provider, Invoice Entity, Service_, _Item_, as well as custom labels. The Cloud Cost Explorer dashboard supports single and multi-aggregation. See the table below for descriptions of each field.

|   Aggregation  | Description                                                                                                                                                |
| :------------: | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
|     Account    | The ID of the billing account your cloud provider bill comes from. (ex: AWS Management/Payer Account ID, GCP Billing Account ID, Azure Billing Account ID) |
|    Provider    | Cloud service provider (ex: AWS, Azure, GCP)                                                                                                               |
| Invoice Entity | Cloud provider account (ex: AWS Account, Azure Subscription, GCP Project)                                                                                  |
|     Service    | Cloud provider services (ex: S3, microsoft.compute, BigQuery)                                                                                              |
|      Item      | Individual items from your cloud billing report(s)                                                                                                         |
|     Labels     | Labels/tags on your cloud resources (ex: AWS tags, Azure tags, GCP labels)                                                                                 |

### Edit

Selecting the _Edit_ button will allow for additional filtering and pricing display options for your cloud data.

#### Add filters

You can filter displayed dashboard metrics by selecting _Edit_, then adding a filter. Filters can be created for the following categories (see descriptions of each category in the Aggregate filters table above):

* Service
* Account
* Invoice Entity
* Provider
* Labels

**Cost Metric**

The Cost Metric dropdown allows you to adjust the displayed cost data based on different calculations. Cost Metric values are based on and calculated following standard FinOps dimensions and metrics, but may be calculated differently depending on your CSP. Learn more about how these metrics are calculated by CSP in the [Cloud Cost Metrics](https://docs.kubecost.com/apis/apis-overview/cloud-cost-api/cloud-cost-metrics) doc. The five available metrics supported by the Cloud Costs Explorer are:

| Cost Metric        | Description                                                                                 |
| ------------------ | ------------------------------------------------------------------------------------------- |
| Amortized Net Cost | Net Cost with removed cash upfront fees and amortized (default)                             |
| Net Cost           | Costs inclusive of discounts and credits. Will also include one-time and recurring charges. |
| List Cost          | CSP pricing without any discounts                                                           |
| Invoiced Cost      | Pricing based on usage during billing period                                                |
| Amortized Cost     | Effective/upfront cost across the billing period                                            |

### Additional options

Select the three horizontal dots icon to view additional options. Selecting _Download CSV_ will download the current query as a CSV file.
