# Secondary Clusters Guide

Secondary clusters use a minimal Kubecost deployment to send their metrics to a central storage-bucket (aka durable storage) that is accessed by the primary cluster to provide a **single-pane-of-glass** view into all aggregated cluster costs globally. This aggregated cluster view is exclusive to Kubecost Enterprise.

{% hint style="warning" %}
Kubecost's UI will appear broken when set to a secondary cluster. It should only be used for troubleshooting.
{% endhint %}

This guide explains settings that can be tuned in order to run the minimum Kubecost components to run Kubecost more efficiently.

See the [Additional resources](/install-and-configure/install/multi-cluster/secondary-clusters.md) section below for complete examples in our GitHub repo.

## Kubecost

Disable unnecessary containers/pods on secondary clusters.

```yaml
federatedETL:
  federatedCluster: true
  agentOnly: true
kubecostAggregator:
  cloudCost:
    enabled: false
```

## Grafana

Grafana is not needed on secondary clusters.

```yaml
global:
  grafana:
    enabled: false
    proxy: false
```

## Prometheus

Kubecost and its accompanying Prometheus collect a reduced set of metrics that allow for lower resource/storage usage than a standard Prometheus deployment.

```yaml
prometheus:
  server:
    retention: 2d
```

## Node-Exporter

Node-exporter is disabled by default. You should keep it this way if cluster/node right-sizing recommendations are not required.

{% hint style="info" %}
Node-exporter must remain disabled if there is an existing DaemonSet. More info [here](/troubleshooting/troubleshoot-install.md#failedscheduling-kubecost-prometheus-node-exporter).
{% endhint %}

## Additional resources

You can find complete installation guides and sample files on our [repo](https://github.com/kubecost/poc-common-configurations).

Additional considerations for properly tuning resource consumption is [here](/install-and-configure/advanced-configuration/resource-consumption.md).
