# Kubecost Cloud: Cloud Cost Explorer

{% hint style="info" %}
This documentation should only be consulted when using Kubecost Cloud! For information about the Cloud Cost Explorer dashboard for self-hosted Kubecost, see [here](/using-kubecost/navigating-the-kubecost-ui/cloud-costs-explorer/cloud-cost-metrics.md).
{% endhint %}

The Cloud Cost Explorer is a dashboard which provides visualization and filtering of your cloud spending. This dashboard includes the costs for all assets in your connected cloud accounts by pulling from those providers' Cost and Usage Reports (CURs) or other cloud billing reports.

For help on integrating one or several cloud service providers (CSPs), see the corresponding documentation:

* [Kubecost Cloud AWS Integration](/kubecost-cloud/kubecost-cloud-cloud-billing-integrations/kubecost-cloud-aws-integration.md)
* [Kubecost Cloud GCP Integration](/kubecost-cloud/kubecost-cloud-cloud-billing-integrations/kubecost-cloud-gcp-integration.md)
* [Kubecost Cloud Azure Integration](/kubecost-cloud/kubecost-cloud-cloud-billing-integrations/kubecost-cloud-azure-integration.md)

## UI Overview

### Date range

You can adjust your displayed metrics using the date range feature, represented by _Last 7 days_, the default range. This will control the time range of metrics that appear. Select the date range of the report by setting specific start and end dates, or by using one of the preset options.

### Aggregate filters

You can adjust your displayed metrics by aggregating your cost by category. Supported fields are _Account, Provider, Invoice Entity, Service_, _Item_, as well as custom labels. The Cloud Cost Explorer dashboard supports single and multi-aggregation. See the table below for descriptions of each field.

<table><thead><tr><th width="172" align="center">Aggregation</th><th>Description</th></tr></thead><tbody><tr><td align="center">Account</td><td>The ID of the billing account your cloud provider bill comes from. (ex: AWS Management/Payer Account ID, GCP Billing Account ID, Azure Billing Account ID)</td></tr><tr><td align="center">Provider</td><td>Cloud service provider (ex: AWS, Azure, GCP)</td></tr><tr><td align="center">Invoice Entity</td><td>Cloud provider account (ex: AWS Account, Azure Subscription, GCP Project)</td></tr><tr><td align="center">Service</td><td>Cloud provider services (ex: S3, microsoft.compute, BigQuery)</td></tr><tr><td align="center">Item</td><td>Individual items from your cloud billing report(s)</td></tr><tr><td align="center">Labels</td><td>Labels/tags on your cloud resources (ex: AWS tags, Azure tags, GCP labels)</td></tr></tbody></table>

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

The Cost Metric dropdown allows you to adjust the displayed cost data based on different calculations. Cost Metric values are based on and calculated following standard FinOps dimensions and metrics, but may be calculated differently depending on your CSP. Learn more about how these metrics are calculated by each CSP in the [Cloud Cost Metrics](/using-kubecost/navigating-the-kubecost-ui/cloud-costs-explorer/cloud-cost-metrics.md) doc. The five available metrics supported by the Cloud Costs Explorer are:

<table><thead><tr><th width="201">Cost Metric</th><th>Description</th></tr></thead><tbody><tr><td>Amortized Net Cost</td><td>Net Cost with removed cash upfront fees and amortized (default)</td></tr><tr><td>Net Cost</td><td>Costs inclusive of discounts and credits. Will also include one-time and recurring charges.</td></tr><tr><td>List Cost</td><td>CSP pricing without any discounts</td></tr><tr><td>Invoiced Cost</td><td>Pricing based on usage during billing period</td></tr><tr><td>Amortized Cost</td><td>Effective/upfront cost across the billing period</td></tr></tbody></table>

### Additional options

Selecting _Save_ will save your current Cloud Costs query for access on the Reports page.

Select the three horizontal dots icon to view additional options. Select _Open Report_ to open any existing Cloud Costs reports. Selecting _Download CSV_ will download the current query as a CSV file.
