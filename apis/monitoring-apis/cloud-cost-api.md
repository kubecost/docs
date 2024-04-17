# Cloud Cost API

The Cloud Cost API provides multiple endpoints to obtain accurate cost information from your cloud service providers (CSPs), including data available from cloud billing reports (such as AWS' Cost and Usage Report (CUR)).

{% swagger method="get" path="/model/cloudCost" baseUrl="http://<your-kubecost-address>" summary="Cloud Cost querying API" %}
{% swagger-description %}
Samples full granularity of cloud costs from cloud billing report (ex. AWS' Cost and Usage Report)
{% endswagger-description %}

{% swagger-parameter in="path" name="window" required="true" %}
Duration of time over which to query. Accepts multiple different formats of time (see this [Using the `window` parameter](/apis/apis-overview.md#using-the-window-parameter) section for more info).
{% endswagger-parameter %}

{% swagger-parameter in="path" name="costMetric" required="false" %}
Determines which cloud cost metric type will be returned. Acceptable values are `AmortizedNetCost`, `InvoicedCost`, `ListCost`, and `NetCost`. Default is `AmortizedNetCost`.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="aggregate" required="false" %}
Field by which to aggregate the results. Accepts: `invoiceEntityID`, `accountID`, `provider`, `service`, and `label:<name>`. Supports multi-aggregation using comma-separated lists. Example: `aggregate=accountID,service`
{% endswagger-parameter %}

{% swagger-parameter in="path" name="accumulate" type="boolean" required="false" %}
When set to `false`, this endpoint returns daily time series data vs cumulative data. Default value is `false`.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="offset" type="int" required="false" %}
Refers to the number of line items you are offsetting. Pairs with `limit`. See the section on [Using `offset` and `limit` parameters to parse payload results](/apis/apis-overview.md#using-offset-and-limit-parameters-to-parse-payload-results) for more info.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="limit" type="int" required="false" %}
Refers to the number of line items per page. Pair with the `offset` parameter to filter your payload to specific pages of line items. You should also set `accumulate=true` to obtain a single list of line items, otherwise you will receive a group of line items per interval of time being sampled.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterInvoiceEntityIDs" required="false" %}
Filter for account
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterAccountIDs" required="false" %}
GCP only, filter for projectID
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterProviders" required="false" %}
Filter for cloud service provider
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterProvidersID" required="false" %}
Filter for resource-level ID given by CSP
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterServices" required="false" %}
Filter for cloud service
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterCategories" required="false" %}
Filter based on object type
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterLabels" required="false" %}
Filter for a specific label. Does not support filtering for multiple labels at once.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
```json
{
    "code": 200,
    "data": {
        "graphData": [
            {
                "start": "",
                "end": "",
                "items": []
            }
        ],
        "tableTotal": {
            "name": "",
            "kubernetesPercent": 0,
            "cost": 0
        },
        "tableRows": []
    }
}
```
{% endswagger-response %}
{% endswagger %}

## Using the `CostMetric` parameter

`CostMetric` values are based on and calculated following standard FinOps dimensions and metrics. The four available metrics supported by the Cloud Cost API are:

| CostMetric value | Description                                                                                 |
| ---------------- | ------------------------------------------------------------------------------------------- |
| NetCost          | Costs inclusive of discounts and credits. Will also include one-time and recurring charges. |
| AmortizedNetCost | `NetCost` with removed cash upfront fees and amortized                                      |
| ListCost         | CSP pricing without any discounts                                                           |
| InvoicedCost     | Pricing based on usage during billing period                                                |

Providing a value for `CostMetric` is optional, but it will default to `AmortizedNetCost` if not otherwise provided.

See our [Cloud Cost Metrics](/using-kubecost/navigating-the-kubecost-ui/cloud-costs-explorer/cloud-cost-metrics.md) doc to learn more about these cost metric types and how they are calculated.

## Understanding `kubernetesPercent`

Each `CostMetric` also has a `kubernetesPercent` value. Unaggregated, this value will be 0 or 1. When you aggregate, `kubernetesPercent` is determined by multiplying the `costMetric` cost by its `kubernetesPercent` and aggregating that value as `kubernetesCost` for that `costMetric`. That `kubernetesCost` is then divided by the aggregated total costs to determine the new `kubernetesPercent`. Since this process results in unique values for each `costMetric`, this value is included as part of the cost metric.

## Examples

### Query for cloud net costs within the past two days, aggregated by accounts, filtered only for Amazon EC2 costs

{% tabs %}
{% tab title="Request" %}
```
http:/<your-kubecost-address>/model/cloudCost?window=2d&filterServices=AmazonEC2&aggregate=invoiceEntityID
```
{% endtab %}

{% tab title="Response" %}
````
```json
{
    "code": 200,
    "data": {
        "graphData": [
            {
                "start": "2023-05-01T00:00:00Z",
                "end": "2023-05-02T00:00:00Z",
                "items": [
                    {
                        "name": "297945954695",
                        "value": 309.4241635897003
                    }
                ]
            },
            {
                "start": "2023-05-02T00:00:00Z",
                "end": "2023-05-03T00:00:00Z",
                "items": []
            }
        ],
        "tableTotal": {
            "name": "Totals",
            "kubernetesPercent": 0.6593596481215193,
            "cost": 309.4241635897003
        },
        "tableRows": [
            {
                "name": "297945954695",
                "kubernetesPercent": 0.6593596481215193,
                "cost": 309.4241635897003
            }
        ]
    }
```
````
{% endtab %}
{% endtabs %}
