# Getting Started

Welcome to Kubecost! This page provides commonly used product configurations and feature overviews to help get you up and running after the Kubecost product has been [installed](http://kubecost.com/install).

**Configuration**

* [Setting up a cloud integration](getting-started.md#cloud-integration)
* [Product configuration at install-time](getting-started.md#install-configs)
* [Configuring metric storage](getting-started.md#storage-config)
* [Setting requests & limits](getting-started.md#requests-limits)
* [Using an existing Prometheus installation](https://guide.kubecost.com/hc/en-us/articles/4407595941015-Custom-Prometheus)
* [Using an existing Grafana installation](https://guide.kubecost.com/hc/en-us/articles/6605291944087-Grafana-Configuration-Guide)
* [Using an existing node exporter installation](getting-started.md#node-exporter)
* [Exposing Kubecost with an Ingress](https://guide.kubecost.com/hc/en-us/articles/4407601820055-Ingress-Examples)
* [Deploying Kubecost without persistent volumes](getting-started.md#no-pvs)

**Next Steps**

* [Measure cluster cost efficiency](getting-started.md#cluster-efficiency)
* [Cost monitoring best practices](http://blog.kubecost.com/blog/cost-monitoring/)
* [Understanding cost allocation metrics](cost-allocation.md)\
  \


## Overview

There are many methods to setup Kubecost. A simple helm install will provide most functionality to understand what Kubecost can do. When you do not pass any values to the helm install, many of the customizations below are available in the settings tab.

By default, Kubecost will detect the cloud provider where it is installed and pull **list prices** for nodes, storage and LoadBalancers on Azure, AWS, and GCP.

## Use cloud-integration(s) for Accurate Billing Data <a href="#cloud-integration" id="cloud-integration"></a>

While the basic helm install is useful for understanding the value Kubecost provides, most will want to deploy with an **Infrastructure as code** model. There are many methods to provide Kubecost with the necessary service accounts / privileges needed. We generally recommend using the various `cloud-integration` guides below.

By completing the cloud-integration with each provider, Kubecost is able to reconcile costs with your actual cloud bill to reflect enterprise discounts, spot market prices, commitment discounts, and more.

Cloud-integration also enables the ability to view Kubernetes cost metrics side-by-side with external cloud services cost, e.g. S3, BigQuery, Azure Database Services.

For Enterprise Subscriptions, Cloud-integration is only run on the `Primary Cluster`. Note that the file is a json array where multiple accounts and providers can be configured.

* [AWS cloud-integration](aws-cloud-integrations.md)
* [Azure cloud-integration](azure-out-of-cluster.md)
* [GCP cloud-integration](gcp-out-of-cluster.md)

## Additional Considerations

The remaining sections are optional and may be useful for specific use cases.

<details>

<summary><strong>Product configuration at install-time</strong></summary>

Kubecost has a number of product configuration options that you can specify at install time in order to minimize the number of settings changes required within the product UI. This makes it simple to redeploy Kubecost. These values can be configured under `kubecostProductConfigs` in our [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/bb8bcb570e6c52db2ed603f69691ac8a47ff4a26/cost-analyzer/values.yaml#L335). These parameters are passed to a ConfigMap that Kubecost detects and writes to its /var/configs.

</details>

<details>

<summary><strong>Storage configuration</strong></summary>

The default Kubecost installation comes with a 32Gb persistent volume and a 15-day retention period for Prometheus metrics. This is enough space to retain data for \~300 pods, depending on your exact node and container count. See the Kubecost Helm chart [configuration options](https://github.com/kubecost/cost-analyzer-helm-chart) to adjust both retention period and storage size.

To determine the appropriate disk size, you can use this formula to approximate:

```
needed_disk_space = retention_time_minutes * ingested_samples_per_minutes * bytes_per_sample
```

Where ingested samples can be measured as the average over a recent period, e.g. `sum(avg_over_time(scrape_samples_post_metric_relabeling[24h]))`. On average, Prometheus uses around 1.5-2 bytes per sample. So ingesting 1 million samples per minute and retaining for 15 days (21,600 minutes) would demand around 40 GB. It's recommended to add another 20-30% capacity for headroom and WAL. More info on disk sizing [here](https://prometheus.io/docs/prometheus/latest/storage/#operational-aspects).

**Note:** We do not recommend retaining greater than 30 days of data in Prometheus for larger clusters. For long-term data retention, contact us (support@kubecost.com) about Kubecost with durable storage enabled.

[More info on Kubecost Storage](storage.md)

</details>

<details>

<summary><strong>Setting Requests &#x26; Limits</strong></summary>

It's recommended that users set and/or update resource requests and limits before taking Kubecost into production at scale. These inputs can be configured in the Kubecost [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) for Kubecost modules + subcharts.

The exact recommended values for these parameters depend on the size of your cluster, availability requirements, and usage of the Kubecost product. Suggested values for each container can be found within Kubecost itself on the namespace page. More info on these recommendations is available [here](http://blog.kubecost.com/blog/requests-and-limits/).

In practice, we recommend running Kubecost for up to 7 days on a production cluster and then tuning resource requests/limits based on resource consumption. Reach out any time to support@kubecost.com if we can help give further guidance.

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

For teams interested in reducing their Kubernetes costs, we have seen it be beneficial to first understand how provisioned resources have been used. There are two major concepts to start with: pod resource efficiency and cluster idle costs.

1. Resource efficiency over a time window is defined as the resource utilization over that time window versus the resource request over the same time window. It is cost-weighted and defined as followed: ((CPU Usage / CPU Requested) \* CPU Cost) + (RAM Usage / RAM Requested) \* RAM Cost) / (RAM Cost + CPU Cost)) CPU Usage = rate(container\_cpu\_usage\_seconds\_total) over the time window RAM Usage = avg(container\_memory\_working\_set\_bytes) over the time window

Eg: If a pod is requesting 2 CPU and 1Gb, using 500mCPU and 500MB, CPU on the node costs $10/CPU , and RAM on the node costs $1/GB, we have ((0.5/2) \* 20 + (0.5/1) \* 1) / (20 + 1) = 5.5 / 21 = 26% 2. Idle Cost is defined as the difference between the cost of allocated resources and the cost of the hardware they run on. Allocation is defined as the max of usage and requests. So, idle costs can also be thought of as the cost of the space that the kubernetes scheduler could add pods without disrupting any workloads in but is not currently. Idle can be charged back to pods on a cost-weighted basis or viewed as a separate line item.

The most common pattern fo cost reduction is to ask service owners to tune the efficiency of their pods, then reclaiming space by setting target idle costs. The Kubecost product (Cluster Overview page) provides a view into this data for an initial assessment of resource efficiency and the cost of waste.

With an overall understanding of idle spend and resource efficiency, you will have a better sense of where to focus efforts for efficiency gains. Each resource type can now be tuned for your business. Most teams we’ve seen end up targeting idle in the following ranges.

* CPU: 50%-65%
* Memory: 45%-60%
* Storage: 65%-80%

Target figures are highly dependent on the predictability and distribution of your resource usage (e.g. P99 vs median), the impact of high utilization on your core product/business metrics, and more. While too low resource utilization is wasteful, too high utilization can lead to latency increases, reliability issues, and other negative behavior.

Efficiency targets can depend on the SLAs of the application-- see our notes on [request right-sizing](https://github.com/kubecost/docs/blob/main/api-request-right-sizing.md) for more details.

</details>

\


Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/getting-started.md)
