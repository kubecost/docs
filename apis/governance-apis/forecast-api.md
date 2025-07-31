# Forecast API

{% swagger method="get" path="/forecasting/forecast/<monitoringEndpoint>" baseUrl="http://<your-kubecost-address>" summary="Forecast API" %}
{% swagger-description %}
The Forecast API predicts a range of total future spending for any of Kubecost's three major monitoring data sets; Allocation, Assets, and CloudCosts, as established via the `monitoringEndpoint` (more below).
{% endswagger-description %}

{% swagger-parameter in="body" name="predictionWindow" type="string" required="true" %}
Range of future spend to predict. The larger the value of this parameter, the wider the confidence bounds may become. Should be formatted in number of days, ex: `predictionWindow=30d`
{% endswagger-parameter %}

{% swagger-parameter in="body" name="aggregate" type="string" required="false" %}
Does not ever support `job`, `daemonSet`, or `statefulSet`. Does not affect predicted cost values.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}

```json
{
    "code": 200,
    "data": {
        "arima/type": {
            "TotalPredictedCost": ,
            "aggregate": "type",
            "bestCasePredicted": null,
            "model": "arima",
            "predictions": {
                "all": [
                    {
                        "confidenceInterval": {
                            "confidenceLevel": 0.75,
                            "lowerConfidenceLimit": ,
                            "upperConfidenceLimit": 
                        },
                        "predictedCost": ,
                        "window": {
                            "end": "2024-04-04T00:00:00Z",
                            "start": "2024-04-03T00:00:00Z"
                        }
                    }
                ]
            },
            "status": "trained",
            "worstCasePredicted": null
        }
    }
}
```

{% endswagger-response %}
{% endswagger %}

## Schema

Regardless of the value of `predictionWindow`, results will be returned in daily intervals.

`predictedCost` will be the closest approximation of future costs for the day defined in the `window` field. The bounds of the confidence interval are displayed with the values `lowerConfidenceLimit` and `upperConfidenceLimit`.

## Forecast Container

The Forecast Container powers multiple cost prediction features in Kubecost including Forecasting and [Anomaly Detection](/using-kubecost/navigating-the-kubecost-ui/anomaly-detection.md). It reads the last 100 days of cost data to form a reliable model of prediction when querying with the Forecast API.

The Forecasting Container can be disabled by setting the Helm flag:

```yaml
forecasting:
  enabled: false
```

## Configuring `monitoringEndpoint`

The Forecast API requires a configurable endpoint which establishes from which monitoring data you want to forecast:

| Dataset | Description | Endpoint |
|---|---|---|
| [Allocation](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/README.md) | Allocated spend | `/allocation` |
| [Assets](/using-kubecost/navigating-the-kubecost-ui/assets.md) | Kubernetes objects and resources | `/assets` |
| [Cloud Costs](/using-kubecost/navigating-the-kubecost-ui/cloud-costs-explorer/cloud-costs-explorer.md) | Cloud services | `/cloudcost` |

## Examples

Forecast future cloud cost spend for the next 60 days:

```http
http://<your-kubecost-address>/forecasting/forecast/cloudcost?predictionWindow=60d
```
