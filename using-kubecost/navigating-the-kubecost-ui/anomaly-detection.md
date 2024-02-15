# Anomaly Detection

{% hint style="info" %}
Anomaly Detection is currently in beta. Please read the documentation carefully.
{% endhint %}

Anomaly Detection is a governance tool which detects when cloud services significantly deviate from their projected spend. This feature, as well as [Forecasting](anomaly-detection.md#forecasting), are powered by the Forecasting Container, which is enabled in Kubecost by default.

{% hint style="info" %}
Anomaly Detection requires at least one cloud provider integration in order to detect anomalies in service spend. See our [Cloud Billing Integrations](/install-and-configure/install/cloud-integration/README.md) doc to get started.
{% endhint %}

![Anomaly detection](/images/anomalydetection.png)

The Forecasting Container can be disabled by setting the Helm flag:

```
forecasting:
        enabled: false
```

## Managing anomalies

Selecting an anomaly will open the Cloud Cost Explorer with a filter for that specific service, allowing you to observe more cost metrics for that service.

Anomaly detection is determined by the provided window of time of data for Kubecost to sample (default *Last 30 days*). This range establishes how much acitvity Kubecost will sample per service to detect anomalies, and will only display anomalies detected in that window.