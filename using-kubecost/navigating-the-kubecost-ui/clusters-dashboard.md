# Clusters Dashboard

## Overview

The Clusters dashboard provides a list of all your monitored clusters, as well as additional clusters detected in your cloud bill. The dashboard provides details about your clusters including cost, efficiency, and cloud provider. You are able to filter your list of clusters by when clusters were last seen, activity status, and by name (see below).

{% hint style="info" %}
Monitoring of multiple clusters is only supported in [Kubecost Enterprise](https://www.kubecost.com/pricing/) plans. Learn more about Kubecost Enterprise's multi-cluster view [here](/install-and-configure/install/multi-cluster/multi-cluster.md).
{% endhint %}

![Clusters dashboard](/.gitbook/assets/clusters.png)

## Getting started

Before you can begin using the Clusters page, you will need to perform [cloud billing integrations](/install-and-configure/install/cloud-integration/README.md) for any and all cloud service providers you wish to view clusters with. 

You should also confirm that the `kubecostAggregator.cloudCost.readinessProbe.enabled` flag is set to `true`. This flag will be enabled by default:

```yaml
kubecostAggregator:
 cloudCost:
    # The cloudCost component of Aggregator depends on
    # kubecostAggregator.deployMethod:
    # kA.dM = "singlepod" -> cloudCost is run as container inside cost-analyzer
    # kA.dM = "statefulset" -> cloudCost is run as single-replica Deployment
    resources: {}
      # requests:
      #   cpu: 1000m
      #   memory: 1Gi
    # refreshRateHours:
    # queryWindowDays:
    # runWindowDays:
    # serviceAccountName:
    readinessProbe:
      enabled: true
      initialDelaySeconds: 10
      periodSeconds: 10
      failureThreshold: 200
```
## Usage

Clusters are primarily distinguished into three categories:

* Clusters monitored by Kubecost (green circle next to cluster name)
* Clusters not monitored by Kubecost (yellow circle next to cluster name)
* Inactive clusters (gray circle next to cluster name)

For detail on how Kubecost identifies clusters, see [Cloud Cost Metrics](cloud-costs-explorer/cloud-cost-metrics.md#kubernetes-clusters).

Monitored clusters are those that have cost metrics which will appear within your other Monitoring dashboards, like Allocations and Assets. Unmonitored clusters are clusters whose existence is determined from cloud integration, but haven't been added to Kubecost. Inactive clusters are clusters Kubecost once monitored, but haven't reported data over a certain period of time. This time period is three hours for Thanos-enabled clusters, and one hour for non-Thanos clusters.

Efficiency and Last Seen metrics are only provided for monitored clusters.

{% hint style="info" %}
Efficiency is calculated as the amount of node capacity that is used, compared to what is available.
{% endhint %}

Selecting any metric in a specific cluster's row will take you to a Cluster Details page for that cluster which provides more extensive metrics, including assets and namespaces associated with that cluster and their respective cost metrics.

![Cluster Details page](/.gitbook/assets/cluster-details.png)

### Filtering clusters

You are able to filter clusters through a window of when all clusters were last seen (default is _Last 7 days_). Although unmonitored clusters will not provide a metric for Last Seen, they will still appear in applicable windows.

You can also filter your clusters for _Active_, _Inactive_, or _Unmonitored_ status, and search for clusters by name.
