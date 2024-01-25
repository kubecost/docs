# Anomaly Detection

{% hint style="info" %}
Anomaly Detection is currently in beta. Please read the documentation carefully.
{% endhint %}

Anomaly Detection is a governance tool which detects when cloud services significantly deviate from their projected spend. Kubecost predicts future spend using its forecasting feature.

![Anomaly detection](/images/anomalydetection.png)

## Forecasting

Forecasting is a predictive cost monitoring tool which can visualize cost forecasts across Kubecost's major monitoring pages; [Allocations](cost-allocation/README.md), [Assets](assets.md), and [Cloud Cost Explorer](cloud-costs-explorer.md).

Forecasting can be accessed from any of these dashboards by selecting *Edit* > *Chart* > *Cost Forecast*. You can then choose your desired window of projected spend from the date range picker. Projected spend is visualized with a margin of error. Hovering over the projected spend will provide you the projected cost and confidence interval.

![Cost forecast](/images/costforecast.png)

## Managing anomalies

Selecting an anomaly will open the Cloud Cost Explorer with a filter for that specific service, allowing you to observe more cost metrics for that service.