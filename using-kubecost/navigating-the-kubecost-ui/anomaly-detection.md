# Anomaly Detection

{% hint style="info" %}
Anomaly Detection is currently in beta. Please read the documentation carefully.
{% endhint %}

![Anomaly Detection Dashboard](/images/anomalydetection-dashboard.png)

The Anomaly Detection Dashboard (under the ‘Govern’ menu) in Kubecost highlights any significant changes in your Kubernetes or cloud spend - helping you detect unexpected cost increases faster. Detecting and remediating unexpected costs quickly helps teams save money, and is a key part of an effective cost governance strategy. This feature is available on all tiers of Kubecost and (along with the Forecasting feature) requires the Kubecost forecasting container (enabled by default).

If you aren’t interested in the Anomaly Detection or Forecasting features, the Forecasting container can be disabled by setting the Helm flag:

```yaml
forecasting:
  enabled: false
```

## Analyzing Anomalies

Kubecost is able to provide users anomaly detection for both their Kubernetes workloads and cloud spend. Simply toggle between the ‘Cloud Costs’ and the ‘Allocations’ tabs to see your cloud spend or Kubernetes workload anomalies, respectively. Users are able to aggregate and filter the anomalies however they like (including custom labels) to analyze their spend changes for a given business unit (application, team, etc.).

Today, Kubecost defines an anomaly as an increase or decrease in cost greater than some threshold (*outlier threshold*) as compared to the mean of the cost over the previous X days (*lookback window*). The outlier threshold and lookback window can be configured in the ‘edit’ menu.

Clicking ‘edit’ in the upper right corner of the anomaly detection page will allow users to configure what constitutes an anomaly for their team. The configurations available are:

- **Outlier Threshold** - The minimum deviation from the mean to be considered anomalous, as a whole-number percentage.

- **Lookback Window** - The number of preceding days to consider when computing the mean.

- **Minimum Cost** - Ignore anomalies with a cost below this threshold to avoid an overly noisy anomaly detection report.

### Example

I want to see if there is any anomalous Kubernetes spend for my team. I click on the Allocations tab and then filter the page to my team’s namespace. My team will consider spend to be anomalous when our spending increases or decreases by more than 50% and we want the spend change to be compared to the previous month. Therefore, we will set the outlier threshold to be 50% and set the lookback window to be 30 days. Additionally, to prevent this report from getting too noisy, we will set the minimum cost to be $10 to filter out any spend changes for small, cheap workloads.

![Anomaly Detection Drilldown](/images/anomalydectection-drilldown.png)

Once you have configured the anomaly detection page to your needs, you are able to see which entities have anomalous spend changes. You are then able to click on any of these anomalies to drill-down to either the Cloud Costs page or Allocations based on the type of spend you are looking at (cloud or Kubernetes). As you can see in the image above, the anomalous day and lookback window are highlighted to help you understand why this day’s spend has been considered anomalous.