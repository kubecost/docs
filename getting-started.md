# Getting Started

Welcome to Kubecost! This page provides commonly used product configurations and feature overviews to help get you up and running after the Kubecost product has been [installed](https://kubecost.com/install).

**Configuration**

* [Setting up a cloud integration](getting-started.md#cloud-integration)
* [Product configuration at install-time](getting-started.md#install-configs)
* [Configuring metric storage](getting-started.md#storage-config)
* [Setting requests & limits](getting-started.md#requests-limits)
* [Using an existing Prometheus installation](/custom-prom.md)
* [Using an existing Grafana installation](/custom-grafana.md)
* [Using an existing node exporter installation](getting-started.md#node-exporter)
* [Exposing Kubecost with an Ingress](ingress-examples.md)
* [Deploying Kubecost without persistent volumes](getting-started.md#no-pvs)

**Next steps**

* [Measure cluster cost efficiency](getting-started.md#cluster-efficiency)
* [Cost monitoring best practices](https://blog.kubecost.com/blog/cost-monitoring/)
* [Understanding cost allocation metrics](cost-allocation.md)

## Overview

There are many methods to setup Kubecost. A simple Helm install will provide most functionality to understand what Kubecost can do. When you do not pass any values to the Helm install, many of the customizations below are available in _Settings_.

By default, Kubecost will detect the cloud provider where it is installed and pull **list prices** for nodes, storage and LoadBalancers on Azure, AWS, and GCP.

## Use cloud-integration(s) for Accurate Billing Data <a href="#cloud-integration" id="cloud-integration"></a>

While the basic Helm install is useful for understanding the value Kubecost provides, most will want to deploy with an **Infrastructure as code** model. There are many methods to provide Kubecost with the necessary service accounts or privileges needed. Follow the various `cloud-integration` guides below.

By completing the cloud-integration with each provider, Kubecost is able to reconcile costs with your actual cloud bill to reflect enterprise discounts, spot market prices, commitment discounts, and more.

Cloud-integration also enables the ability to view Kubernetes cost metrics side-by-side with external cloud services cost, e.g. S3, BigQuery, Azure Database Services.

For Enterprise Subscriptions, Cloud-integration is only run on the `Primary Cluster`. Note that the file is a json array where multiple accounts and providers can be configured.

* [AWS cloud-integration](aws-cloud-integrations.md)
* [Azure cloud-integration](azure-out-of-cluster.md)
* [GCP cloud-integration](gcp-out-of-cluster.md)

## Additional considerations

The remaining sections are optional and may be useful for specific use cases.

<details>

<summary><strong>Product configuration at install-time</strong></summary>

Kubecost has a number of product configuration options that you can specify at install time in order to minimize the number of settings changes required within the product UI. This makes it simple to redeploy Kubecost. These values can be configured under `kubecostProductConfigs` in our [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/bb8bcb570e6c52db2ed603f69691ac8a47ff4a26/cost-analyzer/values.yaml#L335). These parameters are passed to a ConfigMap that Kubecost detects and writes to its /var/configs.

</details>

The default Kubecost installation comes with a 32Gb persistent volume and a 15-day retention period for Prometheus metrics. This is enough space to retain data for \~300 pods, depending on your exact node and container count. See the Kubecost Helm chart [configuration options](https://github.com/kubecost/cost-analyzer-helm-chart) to adjust both retention period and storage size.

To determine the appropriate disk size, you can use this formula to approximate:

```
needed_disk_space = retention_time_minutes * ingested_samples_per_minutes * bytes_per_sample
```

Where ingested samples can be measured as the average over a recent period, e.g. `sum(avg_over_time(scrape_samples_post_metric_relabeling[24h]))`. On average, Prometheus uses around 1.5-2 bytes per sample. So ingesting 100k samples per minute and retaining for 15 days would demand around 40 GB. It’s recommended to add another 20-30% capacity for headroom and WAL. More info on disk sizing [here](https://prometheus.io/docs/prometheus/latest/storage/#operational-aspects).

**Note:** More than 30 days of data should not be stored in Prometheus for larger clusters. For long-term data retention, contact us (support@kubecost.com) about Kubecost with durable storage enabled.

[More info on Kubecost Storage here](docs.kubecost.com/storage/).

<details>

<summary><strong>Setting Requests &#x26; Limits</strong></summary>

Users should set and/or update resource requests and limits before taking Kubecost into production at scale. These inputs can be configured in the Kubecost [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) for Kubecost modules and subcharts.

The exact recommended values for these parameters depend on the size of your cluster, availability requirements, and usage of the Kubecost product. Suggested values for each container can be found within Kubecost itself on the namespace page. More info on these recommendations is available [here](https://blog.kubecost.com/blog/requests-and-limits/).

For best results, run Kubecost for up to seven days on a production cluster and then tune resource requests/limits based on resource consumption. Reach out any time to support@kubecost.com if we can help give further guidance.

</details>

<details>

<summary><strong>Using an existing node exporter</strong></summary>

For teams already running node exporter on the default port, our bundled node exporter may remain in a `Pending` state. You can optionally use an existing node exporter DaemonSet by setting the `prometheus.nodeExporter.enabled` and `prometheus.serviceAccounts.nodeExporter.create` Kubecost helm chart config options to `false`. More configs options shown [here](https://github.com/kubecost/cost-analyzer-helm-chart). Note: this requires your existing node exporter endpoint to be visible from the namespace where Kubecost is installed.

</details>

<details>

<summary><strong>Deploying Kubecost without persistent volumes</strong></summary>

You may optionally pass the following Helm flags to install Kubecost and its bundled dependencies without any Persistent Volumes. Note any time the Prometheus server pod is restarted then all historical billing data will be lost unless Thanos or other long-term storage is enabled in the Kubecost product.

```
--set prometheus.alertmanager.persistentVolume.enabled=false
--set prometheus.pushgateway.persistentVolume.enabled=false
--set prometheus.server.persistentVolume.enabled=false
--set persistentVolume.enabled=false
```

</details>

<details>

<summary><strong>Cost Optimization</strong></summary>

To learn more about pod resource efficiency and cluster idle costs, visit this [doc](./efficiency-idle.md).

</details>
