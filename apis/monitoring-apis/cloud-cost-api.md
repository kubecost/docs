# Cloud Cost API

The Cloud Cost API provides multiple endpoints to obtain accurate cost information from your cloud service providers (CSPs), including data available from cloud billing reports (such as AWS' Cost and Usage Report (CUR)).

{% swagger method="get" path="/model/cloudCost" baseUrl="http://<your-kubecost-address>" summary="Cloud Cost querying API" %}
{% swagger-description %}
Samples full granularity of cloud costs from cloud billing report (ex. AWS' Cost and Usage Report)
{% endswagger-description %}

{% swagger-parameter in="path" name="window" required="true" %}
Duration of time over which to query. Accepts multiple different formats of time (see this [Using the `window` parameter](/apis/apis-overview.md#using-the-window-parameter) section for more info).
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

{% swagger-parameter in="path" name="filter" type="string" required="false" %}
Filter your results by any category which you can aggregate by, can support multiple filterable items in the same category in a comma-separated list. For example, to filter results by providers A and B, use `filter=provider:providerA,providerB`. See our [Filter Parameters](/apis/filters-api.md) doc for a complete explanation of how to use filters and what categories are supported.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}

```json
{
    "code": 200,
    "data": {
        "sets": [
            {
                "cloudCosts": {
                    "": {
                        "properties": {
                            "provider": ""
                        },
                        "window": {
                            "start": "",
                            "end": ""
                        },
                        "listCost": {
                            "cost": ,
                            "kubernetesPercent":
                        },
                        "netCost": {
                            "cost": ,
                            "kubernetesPercent":
                        },
                        "amortizedNetCost": {
                            "cost": ,
                            "kubernetesPercent":
                        },
                        "invoicedCost": {
                            "cost": ,
                            "kubernetesPercent":
                        },
                        "amortizedCost": {
                            "cost": ,
                            "kubernetesPercent":
                        }
                    },
                },
                "window": {
                    "start": "",
                    "end": ""
                },
            }
        ],
        "window": {
            "start": "",
            "end": ""
        }
    }
}
```

{% endswagger-response %}
{% endswagger %}

## Schema overview

### Cloud cost metrics

Cloud cost metric types values are based on and calculated following standard FinOps dimensions and metrics. The five types of cloud cost metrics provided by the Cloud Cost API are:

| Cost Metric        | Description                                                                                 |
| ------------------ | ------------------------------------------------------------------------------------------- |
| Amortized Net Cost | `netCost` with removed cash upfront fees and amortized (default)                             |
| Net Cost           | Costs inclusive of discounts and credits. Will also include one-time and recurring charges. |
| List Cost          | CSP pricing without any discounts                                                           |
| Invoiced Cost      | Pricing based on usage during billing period                                                |
| Amortized Cost     | Effective/upfront cost across the billing period                                            |

See our [Cloud Cost Metrics](/using-kubecost/navigating-the-kubecost-ui/cloud-costs-explorer/cloud-cost-metrics.md) doc to learn more about these cost metric types and how they are calculated.

### `kubernetesPercent`

Each cost metric also has a `kubernetesPercent` value. Unaggregated, this value will be 0 or 1. When you aggregate, `kubernetesPercent` is determined by multiplying the cost metric cost by its `kubernetesPercent` and aggregating that value as `kubernetesCost` for that cost metric. That `kubernetesCost` is then divided by the aggregated total costs to determine the new `kubernetesPercent`. Since this process results in unique values for each cost metric, this value is included as part of the cost metric.

## Examples

#### Query for cloud net costs within the past two days, aggregated by accounts, filtered only for Amazon EC2 costs

{% tabs %}
{% tab title="Request" %}

```http
http:/<your-kubecost-address>/model/cloudCost?window=2d&aggregate=invoiceEntityID&filter=service:"AmazonEC2"
```

{% endtab %}

{% tab title="Response" %}

````
```json
{
    "code": 200,
    "data": {
        "sets": [
            {
                "cloudCosts": {
                    "297945954695": {
                        "properties": {
                            "invoiceEntityID": "297945954695"
                        },
                        "window": {
                            "start": "2024-04-23T00:00:00Z",
                            "end": "2024-04-24T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 523.9306541567001,
                            "kubernetesPercent": 0.9678930844926895
                        },
                        "netCost": {
                            "cost": 523.9306541567001,
                            "kubernetesPercent": 0.9678930844926895
                        },
                        "amortizedNetCost": {
                            "cost": 523.9306541567001,
                            "kubernetesPercent": 0.9678930844926895
                        },
                        "invoicedCost": {
                            "cost": 523.9306541567001,
                            "kubernetesPercent": 0.9678930844926895
                        },
                        "amortizedCost": {
                            "cost": 523.9306541567001,
                            "kubernetesPercent": 0.9678930844926895
                        }
                    }
                },
                "window": {
                    "start": "2024-04-23T00:00:00Z",
                    "end": "2024-04-24T00:00:00Z"
                },
                "aggregationProperties": [
                    "invoiceEntityID"
                ]
            },
            {
                "cloudCosts": null,
                "window": {
                    "start": "2024-04-24T00:00:00Z",
                    "end": "2024-04-25T00:00:00Z"
                },
                "aggregationProperties": [
                    "invoiceEntityID"
                ]
            }
        ],
        "window": {
            "start": "null",
            "end": "null"
        }
    }
}
```
````

{% endtab %}
{% endtabs %}
