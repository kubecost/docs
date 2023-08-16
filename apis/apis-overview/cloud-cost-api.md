# Cloud Cost API

{% hint style="warning" %}
The Cloud Cost API cannot be used until you have enabled Cloud Cost via Helm. See Kubecost's [Cloud Cost Explorer](https://docs.kubecost.com/using-kubecost/navigating-the-kubecost-ui/cloud-costs-explorer#installation-and-configuration) doc for instructions.
{% endhint %}

## Intro to Cloud Cost API

The Cloud Cost API provides multiple endpoints to obtain accurate cost information from your cloud service providers (CSPs), including data available from cloud billing reports (such as AWS' Cost and Usage Report (CUR)).

There are three distinct endpoints for using the Cloud Cost API. The default endpoint for querying Cloud Costs should be `/model/cloudCost/view`.

{% swagger method="get" path="/model/cloudCost/view" baseUrl="http://<your-kubecost-address>" summary="Cloud Cost View API" %}
{% swagger-description %}
Samples full granularity of cloud costs from cloud billing report (ex. AWS' Cost and Usage Report)
{% endswagger-description %}

{% swagger-parameter in="path" name="window" required="true" %}
Window of the query.

**Only accepts daily intervals**

, example

`window=3d`

.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="CostMetric" required="false" %}
Determines which cloud cost metric type will be returned. Acceptable values are

`AmortizedNetCost`

,

`InvoicedCost`

,

`ListCost`

, and

`NetCost`

. Default is

`AmortizedNetCost`

.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="aggregate" required="false" %}
Field by which to aggregate the results. Accepts:

`invoiceEntityID`

,

`accountID`

,

`provider`

,

`service`

, and

`label:<name>`

. Supports multi-aggregation using comma-separated lists. Example:

`aggregate=accountID,service`
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

The endpoint `/model/cloudCost/top` will use all parameters of `/model/cloudCost/view` listed above, **except for** `CostMetric`. This is because `/top` samples full granularity from your cloud billing reports and will return information for all four accepted metric types (see below for more information on these types).

The endpoint `/view` contains all parameters for `/model/CloudCost/aggregate`, and if your `/view` query parameters are in a subset of `/aggregate`, your payload will be pulled from `/aggregate` instead (this payload will return a larger amount of information than `/view`). Otherwise, your `/view` query will pull from `/top`.

{% swagger method="get" path="/model/cloudCost/aggregate" baseUrl="http://<your-kubecost-address>" summary="Cloud Cost Aggregate API" %}
{% swagger-description %}
Query cloud cost aggregate data
{% endswagger-description %}

{% swagger-parameter in="path" name="window" required="true" type="string" %}
Window of the query. Accepts all standard Kubecost window formats (See our doc on using

[the `window` parameter](https://docs.kubecost.com/apis/apis-overview/assets-api#using-window-parameter)

).
{% endswagger-parameter %}

{% swagger-parameter in="path" name="aggregate" type="string" required="false" %}
Field by which to aggregate the results. Accepts:

`invoiceEntityID`

,

`accountID`

,

`provider`

,

`service`

, and

`label:<name>`

. Supports multi-aggregation using comma-separated lists. Example:

`aggregate=accountID,service`
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterInvoiceEntityIDs" type="string" required="false" %}
Filter for account
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterAccountIDs" type="string" required="false" %}
GCP only, filter for projectID
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterProviders" type="string" required="false" %}
Filter for cloud service provider
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterServices" type="string" required="false" %}
Filter for cloud service
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterLabel" required="false" %}
Filter for a specific label. Does not support filtering for multiple labels at once.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
````
```json
{
    "code": 200,
    "data": {
        "sets": [
            {
                "cloudCosts": {
                    "": {
                        "properties": {
                            "provider": "",
                            "invoiceEntityID": ""
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
                            "cost": 5,
                            "kubernetesPercent": 
                        },
                        "invoicedCost": {
                            "cost": ,
                            "kubernetesPercent": 
                        }
                    }
                },
                "window": {
                    "start": "",
                    "end": ""
                },
                "aggregationProperties": [
                    ""
                ]
            }
        ],
        "window": {
            "start": "",
            "end": ""
        }
    }
}
````
{% endswagger-response %}
{% endswagger %}

## Using the `CostMetric` parameter

{% hint style="warning" %}
Using the endpoint `/model/cloudCost/top` will accept all parameters of `model/cloudCost/view` **except for** `MetricCost`.
{% endhint %}

`CostMetric` values are based on and calculated following standard FinOps dimensions and metrics. The four available metrics supported by the Cloud Cost API are:

| CostMetric value | Description                                                                                 |
| ---------------- | ------------------------------------------------------------------------------------------- |
| NetCost          | Costs inclusive of discounts and credits. Will also include one-time and recurring charges. |
| AmortizedNetCost | `NetCost` with removed cash upfront fees and amortized                                      |
| ListCost         | CSP pricing without any discounts                                                           |
| InvoicedCost     | Pricing based on usage during billing period                                                |

Providing a value for `CostMetric` is optional, but it will default to `AmortizedNetCost` if not otherwise provided.

## Understanding `kubernetesPercent`

Each `CostMetric` also has a `kubernetesPercent` value. Unaggregated, this value will be 0 or 1. When you aggregate, `kubernetesPercent` is determined by multiplying the `costMetric` cost by its `kubernetesPercent` and aggregating that value as `kubernetesCost` for that `costMetric`. That `kubernetesCost` is then divided by the aggregated total costs to determine the new `kubernetesPercent`. Since this process results in unique values for each `costMetric`, this value is included as part of the cost metric.

## Examples

#### **Query for cloud costs within the past three days, aggregated by cloud service, filtered for only services provided by AWS**

{% tabs %}
{% tab title="Request" %}
```
http://<your-kubecost-address>/model/cloudCost/aggregate?window=3d&aggregate=service&filterProviders=AWS
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
                    "5hnnev4d0v7mapf09j0v8of0o2": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "5hnnev4d0v7mapf09j0v8of0o2"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 8.207999999999997,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 8.207999999999997,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 8.207999999999997,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 8.207999999999997,
                            "kubernetesPercent": 0
                        }
                    },
                    "AWSBackup": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AWSBackup",
                            "labels": {
                                "name": "khand-dev"
                            }
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 4e-10,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 4e-10,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 4e-10,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 4e-10,
                            "kubernetesPercent": 0
                        }
                    },
                    "AWSCloudTrail": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AWSCloudTrail"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 4.9206699999999985,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 4.9206699999999985,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 4.9206699999999985,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 4.9206699999999985,
                            "kubernetesPercent": 0
                        }
                    },
                    "AWSCostExplorer": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AWSCostExplorer"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0.26426064520000003,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0.26426064520000003,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0.26426064520000003,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0.26426064520000003,
                            "kubernetesPercent": 0
                        }
                    },
                    "AWSELB": {
                        "properties": {
                            "provider": "AWS",
                            "invoiceEntityID": "297945954695",
                            "service": "AWSELB"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 43.00682560389998,
                            "kubernetesPercent": 0.8073338296107909
                        },
                        "netCost": {
                            "cost": 43.00682560389998,
                            "kubernetesPercent": 0.8073338296107909
                        },
                        "amortizedNetCost": {
                            "cost": 43.00682560389998,
                            "kubernetesPercent": 0.8073338296107909
                        },
                        "invoicedCost": {
                            "cost": 43.00682560389998,
                            "kubernetesPercent": 0.8073338296107909
                        }
                    },
                    "AWSGlue": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AWSGlue"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0.43269115999999996,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0.43269115999999996,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0.43269115999999996,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0.43269115999999996,
                            "kubernetesPercent": 0
                        }
                    },
                    "AWSLambda": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AWSLambda"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        }
                    },
                    "AWSQueueService": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AWSQueueService"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonAthena": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonAthena"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0.10061275,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0.10061275,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0.10061275,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0.10061275,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonCloudWatch": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonCloudWatch"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0.21150513669999998,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0.21150513669999998,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0.21150513669999998,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0.21150513669999998,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonEC2": {
                        "properties": {
                            "provider": "AWS",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonEC2"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 337.4926118030998,
                            "kubernetesPercent": 0.6543833295809984
                        },
                        "netCost": {
                            "cost": 337.4926118030998,
                            "kubernetesPercent": 0.6543833295809984
                        },
                        "amortizedNetCost": {
                            "cost": 337.4926118030998,
                            "kubernetesPercent": 0.6543833295809984
                        },
                        "invoicedCost": {
                            "cost": 337.4926118030998,
                            "kubernetesPercent": 0.6543833295809984
                        }
                    },
                    "AmazonECR": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonECR"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0.00018308879999999998,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0.00018308879999999998,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0.00018308879999999998,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0.00018308879999999998,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonECRPublic": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonECRPublic"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonEFS": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonEFS"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 6.123e-07,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 6.123e-07,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 6.123e-07,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 6.123e-07,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonEKS": {
                        "properties": {
                            "provider": "AWS",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonEKS"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 43.19999999999999,
                            "kubernetesPercent": 1
                        },
                        "netCost": {
                            "cost": 43.19999999999999,
                            "kubernetesPercent": 1
                        },
                        "amortizedNetCost": {
                            "cost": 43.19999999999999,
                            "kubernetesPercent": 1
                        },
                        "invoicedCost": {
                            "cost": 43.19999999999999,
                            "kubernetesPercent": 1
                        }
                    },
                    "AmazonFSx": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonFSx"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 5.6010275086000005,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 5.6010275086000005,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 5.6010275086000005,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 5.6010275086000005,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonPrometheus": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonPrometheus"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 5.03357787,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 5.03357787,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 5.03357787,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 5.03357787,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonQuickSight": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonQuickSight"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0.8000000064000001,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0.8000000064000001,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0.8000000064000001,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0.8000000064000001,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonRoute53": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonRoute53"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0.0005856,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0.0005856,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0.0005856,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0.0005856,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonS3": {
                        "properties": {
                            "provider": "AWS",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonS3"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 45.7935617916,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 45.7935617916,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 45.7935617916,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 45.7935617916,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonSNS": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonSNS"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonVPC": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonVPC"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 2.8800000000000017,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 2.8800000000000017,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 2.8800000000000017,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 2.8800000000000017,
                            "kubernetesPercent": 0
                        }
                    },
                    "awskms": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "awskms"
                        },
                        "window": {
                            "start": "2023-04-30T00:00:00Z",
                            "end": "2023-05-01T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0.23333333520000016,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0.23333333520000016,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0.23333333520000016,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0.23333333520000016,
                            "kubernetesPercent": 0
                        }
                    }
                },
                "window": {
                    "start": "2023-04-30T00:00:00Z",
                    "end": "2023-05-01T00:00:00Z"
                },
                "aggregationProperties": [
                    "service"
                ]
            },
            {
                "cloudCosts": {
                    "5hnnev4d0v7mapf09j0v8of0o2": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "5hnnev4d0v7mapf09j0v8of0o2"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 7.865999999999996,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 7.865999999999996,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 7.865999999999996,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 7.865999999999996,
                            "kubernetesPercent": 0
                        }
                    },
                    "AWSCloudTrail": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AWSCloudTrail"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 6.373088000000007,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 6.373088000000007,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 6.373088000000007,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 6.373088000000007,
                            "kubernetesPercent": 0
                        }
                    },
                    "AWSCostExplorer": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AWSCostExplorer"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0.24415709680000003,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0.24415709680000003,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0.24415709680000003,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0.24415709680000003,
                            "kubernetesPercent": 0
                        }
                    },
                    "AWSELB": {
                        "properties": {
                            "provider": "AWS",
                            "invoiceEntityID": "297945954695",
                            "service": "AWSELB"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 41.16003439479998,
                            "kubernetesPercent": 0.8082905243733983
                        },
                        "netCost": {
                            "cost": 41.16003439479998,
                            "kubernetesPercent": 0.8082905243733983
                        },
                        "amortizedNetCost": {
                            "cost": 41.16003439479998,
                            "kubernetesPercent": 0.8082905243733983
                        },
                        "invoicedCost": {
                            "cost": 41.16003439479998,
                            "kubernetesPercent": 0.8082905243733983
                        }
                    },
                    "AWSGlue": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AWSGlue"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0.5083949200000001,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0.5083949200000001,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0.5083949200000001,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0.5083949200000001,
                            "kubernetesPercent": 0
                        }
                    },
                    "AWSLambda": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AWSLambda"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        }
                    },
                    "AWSQueueService": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AWSQueueService"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonAthena": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonAthena"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 10.695624500000003,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 10.695624500000003,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 10.695624500000003,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 10.695624500000003,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonCloudWatch": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonCloudWatch"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0.0148635813,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0.0148635813,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0.0148635813,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0.0148635813,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonEC2": {
                        "properties": {
                            "provider": "AWS",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonEC2"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 309.4241635897003,
                            "kubernetesPercent": 0.6593596481215193
                        },
                        "netCost": {
                            "cost": 309.4241635897003,
                            "kubernetesPercent": 0.6593596481215193
                        },
                        "amortizedNetCost": {
                            "cost": 309.4241635897003,
                            "kubernetesPercent": 0.6593596481215193
                        },
                        "invoicedCost": {
                            "cost": 309.4241635897003,
                            "kubernetesPercent": 0.6593596481215193
                        }
                    },
                    "AmazonECR": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonECR"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0.00014835589999999998,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0.00014835589999999998,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0.00014835589999999998,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0.00014835589999999998,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonECRPublic": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonECRPublic"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonEFS": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonEFS"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 5.681000000000001e-07,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 5.681000000000001e-07,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 5.681000000000001e-07,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 5.681000000000001e-07,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonEKS": {
                        "properties": {
                            "provider": "AWS",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonEKS"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 39.6,
                            "kubernetesPercent": 1
                        },
                        "netCost": {
                            "cost": 39.6,
                            "kubernetesPercent": 1
                        },
                        "amortizedNetCost": {
                            "cost": 39.6,
                            "kubernetesPercent": 1
                        },
                        "invoicedCost": {
                            "cost": 39.6,
                            "kubernetesPercent": 1
                        }
                    },
                    "AmazonFSx": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonFSx"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 4.968756381500007,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 4.968756381500007,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 4.968756381500007,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 4.968756381500007,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonPrometheus": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonPrometheus"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 1.04940423,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 1.04940423,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 1.04940423,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 1.04940423,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonQuickSight": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonQuickSight"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0.7419354719999997,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0.7419354719999997,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0.7419354719999997,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0.7419354719999997,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonRoute53": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonRoute53"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 1.5010184,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 1.5010184,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 1.5010184,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 1.5010184,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonS3": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonS3"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 35.486366779799866,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 35.486366779799866,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 35.486366779799866,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 35.486366779799866,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonSNS": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonSNS"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonVPC": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonVPC"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 2.849999999999996,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 2.849999999999996,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 2.849999999999996,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 2.849999999999996,
                            "kubernetesPercent": 0
                        }
                    },
                    "AmazonWorkSpaces": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "AmazonWorkSpaces"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 38,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 38,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 38,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 38,
                            "kubernetesPercent": 0
                        }
                    },
                    "awskms": {
                        "properties": {
                            "provider": "AWS",
                            "accountID": "297945954695",
                            "invoiceEntityID": "297945954695",
                            "service": "awskms"
                        },
                        "window": {
                            "start": "2023-05-01T00:00:00Z",
                            "end": "2023-05-02T00:00:00Z"
                        },
                        "listCost": {
                            "cost": 0.2163978459999994,
                            "kubernetesPercent": 0
                        },
                        "netCost": {
                            "cost": 0.2163978459999994,
                            "kubernetesPercent": 0
                        },
                        "amortizedNetCost": {
                            "cost": 0.2163978459999994,
                            "kubernetesPercent": 0
                        },
                        "invoicedCost": {
                            "cost": 0.2163978459999994,
                            "kubernetesPercent": 0
                        }
                    }
                },
                "window": {
                    "start": "2023-05-01T00:00:00Z",
                    "end": "2023-05-02T00:00:00Z"
                },
                "aggregationProperties": [
                    "service"
                ]
            },
            {
                "cloudCosts": {},
                "window": {
                    "start": "2023-05-02T00:00:00Z",
                    "end": "2023-05-03T00:00:00Z"
                },
                "aggregationProperties": [
                    "service"
                ]
            }
        ],
        "window": {
            "start": "2023-04-30T00:00:00Z",
            "end": "2023-05-03T00:00:00Z"
        }
    }
}
```
````
{% endtab %}
{% endtabs %}

#### Query for cloud net costs within the past two days, aggregated by accounts, filtered only for Amazon EC2 costs

{% tabs %}
{% tab title="Request" %}
```
http:/<your-kubecost-address>/model/cloudCost/view?window=2d&filterServices=AmazonEC2&aggregate=invoiceEntityID
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
