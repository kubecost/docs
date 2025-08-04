# External Costs API

{% hint style="info" %}
External Costs can only be queried after you have configured at least one external service with Kubecost. You can learn how to integrate Datadog through this method in our [External Costs](/using-kubecost/navigating-the-kubecost-ui/external-costs.md#enabling-external-costs) doc.
{% endhint %}

{% swagger method="get" path="/model/customCost/timeseries" baseUrl="http://<your-kubecost-address>" summary="External Costs API summary query" %}
{% swagger-description %}
Samples costs of connected third party services
{% endswagger-description %}

{% swagger-parameter in="path" name="window" required="true" %}
Duration of time over which to query. Accepts multiple different formats of time (see this [Using the `window` parameter](/apis/apis-overview.md#using-the-window-parameter) section for more info).
{% endswagger-parameter %}

{% swagger-parameter in="path" name="aggregate" required="false" %}
Field by which to aggregate the results. Accepts: `zone`, `accountName`, `chargeCategory`, `description`, `resourceName`, `resourceType`, `providerId`, `usageUnit`, `domain`, and `costSource`. Supports multi-aggregation using comma-separated lists. Example: `aggregate=zone,description`
{% endswagger-parameter %}

{% swagger-parameter in="path" name="accumulate" type="boolean" required="false" %}
When set to `false`, this endpoint returns daily time series data vs cumulative data. Default value is `false`.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filter" required="false" %}
Filter your results by any category which you can aggregate by, can support multiple filterable items in the same category in a comma-separated list. For example, to filter results by charge categories `usage` and `billing`, use `filter=chargeCategory:usage,billing` See our [Filter Parameters](/apis/filters-api.md) doc for a complete explanation of how to use filters and what categories are supported.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}

```json
{
    "code": 200,
    "data": {
        "window": {
            "start": "2024-04-07T00:00:00Z",
            "end": "2024-04-09T00:00:00Z"
        },
        "timeseries": [
            {
                "window": {
                    "start": "2024-04-07T00:00:00Z",
                    "end": "2024-04-07T01:00:00Z"
                },
                "totalBilledCost": 0,
                "totalListCost": 0,
                "customCosts": [
                    {
                        "id": "",
                        "zone": "",
                        "account_name": "",
                        "charge_category": "",
                        "description": "",
                        "resource_name": "",
                        "resource_type": "",
                        "provider_id": "",
                        "billedCost": 0,
                        "listCost": 0,
                        "list_unit_price": 0,
                        "usage_quantity": 0,
                        "usage_unit": "",
                        "domain": "datadog",
                        "cost_source": "observability",
                        "aggregate": "__unallocated__/__unallocated__/__unallocated__/__unallocated__/__unallocated__/__unallocated__/__unallocated__/__unallocated__/datadog/observability"
                    }
                ]
            },
        ],
    }
```

{% endswagger-response %}
{% endswagger %}

{% swagger method="get" path="/model/customCost/total" baseUrl="http://<your-kubecost-address>" summary="External Costs API total query" %}
{% swagger-description %}
Samples costs of connected third party services, but summarizes subwindows into singular window of total cost. Can be compared to [`/topline` endpoint of other APIs](/apis/apis-overview.md#using-the-topline-endpoint-to-summarize-costs).
{% endswagger-description %}

{% swagger-parameter in="path" name="window" required="true" %}
Duration of time over which to query. Accepts multiple different formats of time (see this [Using the `window` parameter](/apis/apis-overview.md#using-the-window-parameter) section for more info).
{% endswagger-parameter %}

{% swagger-parameter in="path" name="aggregate" required="false" %}
Field by which to aggregate the results. Accepts: `zone`, `accountName`, `chargeCategory`, `description`, `resourceName`, `resourceType`, `providerId`, `usageUnit`, `domain`, and `costSource`. Supports multi-aggregation using comma-separated lists. Example: `aggregate=zone,description`
{% endswagger-parameter %}

{% swagger-parameter in="path" name="accumulate" type="boolean" required="false" %}
When set to `false`, this endpoint returns daily time series data vs cumulative data. Default value is `false`.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filter" required="false" %}
Filter your results by any category which you can aggregate by, can support multiple filterable items in the same category in a comma-separated list. For example, to filter results by charge categories `usage` and `billing`, use `filter=chargeCategory:usage,billing` See our [Filter Parameters](/apis/filters-api.md) doc for a complete explanation of how to use filters and what categories are supported.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}

```json
{
    "code": 200,
    "data": {
        "window": {
            "start": "2024-04-07T00:00:00Z",
            "end": "2024-04-09T00:00:00Z"
        },
        "totalBilledCost": 0,
        "totalListCost": 0,
        "customCosts": [
            {
                "id": "",
                "zone": "",
                "account_name": "",
                "charge_category": "",
                "description": "",
                "resource_name": "",
                "resource_type": "",
                "provider_id": "",
                "billedCost": 0,
                "listCost": 0,
                "list_unit_price": 0,
                "usage_quantity": 0,
                "usage_unit": "",
                "domain": "datadog",
                "cost_source": "observability",
                "aggregate": "__unallocated__/__unallocated__/__unallocated__/__unallocated__/__unallocated__/__unallocated__/__unallocated__/__unallocated__/datadog/observability"
            }
        ]
    }
}
```

{% endswagger-response %}
{% endswagger %}
