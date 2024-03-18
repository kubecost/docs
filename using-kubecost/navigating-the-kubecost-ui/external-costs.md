# External Costs

{% hint style="info" %}
External Costs is currently in beta.
{% endhint %}

External Costs is a monitoring dashboard for third party service costs that are not directly from cloud providers. Currently, this includes monitoring for Datadog costs. More third party services are expected to be supported in the future.

## Enabling External Costs

Kubecost will require the integration of a service's plugin in order to detect and display costs associated with that service.

## Configuring your query

### Date range

Select the date range of the report by setting specific start and end dates, or using one of the preset options.

### Aggregation

Here you can aggregate your results by one or several categories. While selecting Single Aggregation, you will only be able to select one concept at a time. While selecting Multi Aggregation, you will be able to filter for multiple concepts at the same time. Costs will be aggregated by *Domain* by default. Fields by which you can aggregate are:

* Zone
* Resource Type
* Account Name
* Provider ID
* Charge Category
* Usage Unit
* Resource Name
* Domain

### Filtering

You can also view the External Costs page from the Cloud Cost Explorer, when aggregating by *Provider*. Third party services will appear on this page, and when any line item is selected, you will be taken to External Costs.