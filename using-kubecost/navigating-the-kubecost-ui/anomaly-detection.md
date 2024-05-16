# Anomaly Detection

{% hint style="info" %}
Anomaly Detection is currently in beta. Please read the documentation carefully.
{% endhint %}

Anomaly Detection is a governance tool which detects when an item in your Allocation or Cloud Cost data significantly deviates from its projected spend. This feature, as well as [Forecasting](anomaly-detection.md#forecasting), are powered by the Forecasting Container, which is enabled in Kubecost by default.

{% hint style="info" %}
Anomaly Detection requires at least one cloud provider integration in order to detect anomalies in service spend. See our [Cloud Billing Integrations](/install-and-configure/install/cloud-integration/README.md) doc to get started.
{% endhint %}

Anomaly Detection can be accessed in the Kubecost UI by selecting *Govern* > *Anomalies* in the left navigation.

![Anomaly detection](/images/anomaly-detection.png)

An anomaly is an increase/decrease in cost greater than the established threshold of acceptable spend, where both the threshold and the window of date used to establish that treshold can be [configured by the user](anomaly-detection.md#edit).

## Configuring your anomaly queries

Anomaly Detection provides two panels of anomalies, divided between *Cloud Costs* and *Allocations*. For every anomaly, Kubecost provides the date the anomaly was detected, the cost, and the percentage of change over time (this includes positive and negative change spend).

There are several means of configuring your displayed items:

### Aggregate

You can aggregate your anomaly results across one or multiple of several categories depending on whether you are viewing Cloud Cost or Allocations items.

Cloud Costs supports the following categories to aggregate by:

* Invoice Entity
* Account
* Provider
* Service (default)
* Category

Allocations supports the following categories to aggregate by:

* Cluster
* Container
* Controller
* Ctrl Kind
* Namespace (default)
* Node
* Pod
* Service

### Filter

Filter items by all available aggregation categories as well as custom labels. When a filter is applied, only resources with this matching value will be shown. Supports advanced filtering options as well.

### Date range

Select the window of time for Kubecost to sample item activity in order to provide trend statistics.

### Edit

Selecting *Edit* provides addtional options for determining what Kubecost should designate as an anomaly.

#### Outlier Threshold

The minimum deviation from the mean to be considered anomalous, as a whole-number percentage. Default value is 50%.

#### Minimum Cost

Ignore anomalies with a cost below this threshold, in the value of your [configured currency](/install-and-configure/install/first-time-user-guide.md#currency-types). Default value is 5.

#### Lookback Window

The number of preceding days to consider when computing the mean. This is the time window used by Kubecost to establish the baseline of acceptable spend, while the date range picker is used for the total number of anomalies detected within that range.

## Managing anomalies

Selecting an anomaly will open the corresponding monitoring dashboard associated with that item, including any any Aggregate/Filter configurations, allowing you to observe more cost metrics for that item and drill down into it.

The Lookback Window will be visualized, with the step interval directly after being highlighted as the detected anomalous spend source. Kubecost is using the configured Lookback Window to calculate an average spend in that duration, then determines if the spend directly proceeding it varies enough from that average to be considered anomalous.

![Detected anomaly](/images/anomaly-drilldown.png)

The Forecasting Container can be disabled by setting the Helm flag (this will stop Anomaly Detection from working!):

```
forecasting:
  enabled: false

```

