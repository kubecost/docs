# Next Steps with Kubecost

Once you have familiarized yourself with Kubecost and integrated with any cloud providers, it's time to move on to more advanced concepts. This doc provides commonly used product configurations and feature overviews to help get you up and running after the Kubecost product has been [installed](https://kubecost.com/install). You may be redirected to other Kubecost docs to learn more about specific concepts or follow tutorials.

## Memory and storage

The default Kubecost installation has a 32Gb persistent volume and a 15-day retention period for Prometheus metrics. This is enough space to retain data for roughly 300 pods, depending on your exact node and container count. See the Kubecost Helm chart [configuration options](https://github.com/kubecost/cost-analyzer-helm-chart) to adjust both the retention period and storage size.

To determine the appropriate disk size, you can use this formula to approximate:

{% code overflow="wrap" %}
```
needed_disk_space = retention_time_minutes * ingested_samples_per_minutes * bytes_per_sample
```
{% endcode %}

Where ingested samples can be measured as the average over a recent period, e.g. `sum(avg_over_time(scrape_samples_post_metric_relabeling[24h]))`. On average, Prometheus uses around 1.5-2 bytes per sample. So, ingesting 100k samples per minute and retaining them for 15 days would demand around 40 GB. It’s recommended to add another 20-30% capacity for headroom and WAL. More info on disk sizing [here](https://prometheus.io/docs/prometheus/latest/storage/#operational-aspects).

{% hint style="warning" %}
More than 30 days of data should not be stored in Prometheus for larger clusters. For long-term data retention, contact us at support@kubecost.com about Kubecost with durable storage enabled. [More info on Kubecost storage here](../../storage.md).
{% endhint %}

## Setting requests and limits

Users should set and/or update resource requests and limits before taking Kubecost into production at scale. These inputs can be configured in the Kubecost [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) for Kubecost modules and subcharts.

The exact recommended values for these parameters depend on the size of your cluster, availability requirements, and usage of the Kubecost product. Suggested values for each container can be found within Kubecost itself on the namespace page. More info on these recommendations is available [here](https://blog.kubecost.com/blog/requests-and-limits/).

For best results, run Kubecost for up to seven days on a production cluster, then tune resource requests/limits based on resource consumption.

## Configure security of user access

To broaden usage to other teams or departments within your Kubecost environment, basic security measures will usually be required. There are a number of options for protecting your workspace depending on your Kubecost product tier.

### Ingress controller

Establishing an ingress controller will allow for control of access for your workspace. Learn more about enabling external access in Kubecost with our [Ingress Examples](https://docs.kubecost.com/install-and-configure/install/ingress-examples) doc.

### SSO/SAML/RBAC

{% hint style="info" %}
SSO/SAML/RBAC are only officially supported on Kubecost Enterprise plans.
{% endhint %}

SSO/SAML/RBAC is able to be configured on a separate baseline deployment, which will not only shorten the deployment time of security features, but it will also avoid unwanted access denial. This is helpful when using only one developer deployment. See our [User Management](https://docs.kubecost.com/install-and-configure/advanced-configuration/user-management) doc to learn more.

## Using an existing node exporter

For teams already running node exporter on the default port, our bundled node exporter may remain in a `Pending` state. You can optionally use an existing node exporter DaemonSet by setting the `prometheus.nodeExporter.enabled` and `prometheus.serviceAccounts.nodeExporter.create` Kubecost Helm chart config options to `false`. This requires your existing node exporter endpoint to be visible from the namespace where Kubecost is installed. More configs options shown [here](https://github.com/kubecost/cost-analyzer-helm-chart).

## Deploying Kubecost without persistent volumes

You may optionally pass the following Helm flags to install Kubecost and its bundled dependencies without any persistent volumes. However, any time the Prometheus server pod is restarted, **all historical billing data will be lost** unless Thanos or other long-term storage is enabled in the Kubecost product.

```
--set prometheus.alertmanager.persistentVolume.enabled=false
--set prometheus.pushgateway.persistentVolume.enabled=false
--set prometheus.server.persistentVolume.enabled=false
--set persistentVolume.enabled=false
```

## **Resource efficiency and idle costs**

Efficiency and idle costs can teach you more about the cost-value of your Kubernetes spend by showing you how efficiently your resources are used. To learn more about pod resource efficiency and cluster idle costs, see [Efficiency and Idle](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/efficiency-idle.md).

## **See also**

* [Using an existing Prometheus installation](../../custom-prom.md)
* [Using an existing Grafana installation](../../custom-grafana.md)
* [Exposing Kubecost with an Ingress](../../ingress-examples.md)
