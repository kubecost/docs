# Anomaly Detection

{% hint style="info" %}
Anomaly Detection is currently in beta. Please read the documentation carefully.
{% endhint %}

Anomaly Detection is a governance tool which detects when cloud services significantly deviate from their projected spend. This feature, as well as [Forecasting](anomaly-detection.md#forecasting), are powered by the Anomaly Detection Container, which is enabled in Kubecost by default. Kubecost samples spend data from the last seven days to determine of a service's spend has become anomalous.

![Anomaly detection](/images/anomalydetection.png)

## Forecasting

Forecasting is a predictive cost monitoring tool which can visualize cost forecasts across Kubecost's major monitoring pages; [Allocations](cost-allocation/README.md), [Assets](assets.md), and [Cloud Cost Explorer](cloud-costs-explorer.md).

Forecasting can be accessed from any of these dashboards by selecting *Edit* > *Chart* > *Cost Forecast*. You can then choose your desired window of projected spend from the date range picker. Projected spend is visualized with a margin of error. Hovering over the projected spend will provide you the projected cost and confidence interval.

![Forecasting](/images/forecasting.png)

## Managing anomalies

Selecting an anomaly will open the Cloud Cost Explorer with a filter for that specific service, allowing you to observe more cost metrics for that service.

ANomaly detection is determined by the provided window of time of data for Kubecost to sample (default *Last 7 days*). This range establishes how much acitvity Kubecost will sample per service to detect anomalies, and will only display anomalies detecting in that window.