# Forecast API

{% swagger method="get" path="/model/forecast/forecast/<monitoringEndpoint>" baseUrl="http://<your-kubecost-address>" summary="Forecast API" %}
{% swagger-description %}
The Forecast API predicts a range of total future spending for any of Kubecost's three major monitoring data sets; Allocation, Assets, and CloudCosts, as established via the `monitoringEndpoint` (more below).
{% endswagger-description %}

{% swagger-parameter in="body" name="prediction_window" type="string" required="true" %}
Range of future spend to predict. The larger the value of this parameter, the wider the confidence interval. Should be formatted in number of days, ex: `prediction_window=30d`
{% endswagger-parameter %}

{% swagger-parameter in="body" name="aggregate" type="string" required="false" %}
Does not ever support `job`, `daemonSet`, or `statefulSet`.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
```

```
{% endswagger-response %}
{% endswagger %}

## Forecast Container

The Forecast Container powers multiple cost prediction features in Kubecost including Forecasting and [Anomaly Detection](/using-kubecost/navigating-the-kubecost-ui/anomaly-detection.md). It reads the last 100 days of cost data to form a reliable model of prediction when querying with the Forecast API.

The Forecasting Container can be disabled by setting the Helm flag:

```
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

