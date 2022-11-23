Getting Started
===============

Welcome to Kubecost! This page provides commonly used product configurations and feature overviews to help get you up and running after the Kubecost product has been [installed](http://kubecost.com/install).

__Configuration__
* [Setting up a cloud integration](#cloud-integration)
* [Product configuration at install-time](#install-configs)
* [Configuring metric storage](#storage-config)
* [Setting requests & limits](#requests-limits)
* [Using an existing Prometheus installation](https://guide.kubecost.com/hc/en-us/articles/4407595941015-Custom-Prometheus)
* [Using an existing Grafana installation](https://guide.kubecost.com/hc/en-us/articles/6605291944087-Grafana-Configuration-Guide)
* [Using an existing node exporter installation](#node-exporter)
* [Exposing Kubecost with an Ingress](https://guide.kubecost.com/hc/en-us/articles/4407601820055-Ingress-Examples)
* [Deploying Kubecost without persistent volumes](#no-pvs)

__Next Steps__
* [Measure cluster cost efficiency](#cluster-efficiency)
* [Cost monitoring best practices](http://blog.kubecost.com/blog/cost-monitoring/)
* [Understanding cost allocation metrics](/cost-allocation.md)
<br/><br/>

## Overview

There are many methods to setup Kubecost. A simple helm install will provide most functionality to understand what Kubecost can do. When you do not pass any values to the helm install, many of the customizations below are available in the settings tab.

By default, Kubecost will detect the cloud provider where it is installed and pull __list prices__ for nodes, storage and LoadBalancers on Azure, AWS, and GCP.

## <a name="cloud-integration"></a>Use cloud-integration(s) for Accurate Billing Data

While the basic helm install is useful for understanding the value Kubecost provides, most will want to deploy with an __Infrastructure as code__ model. There are many methods to provide Kubecost with the necessary service accounts / privileges needed. We generally recommend using the various `cloud-integration` guides below.

By completing the cloud-integration with each provider, Kubecost is able to reconcile costs with your actual cloud bill to reflect enterprise discounts, spot market prices, commitment discounts, and more.

Cloud-integration also enables the ability to view Kubernetes cost metrics side-by-side with external cloud services cost, e.g. S3, BigQuery, Azure Database Services.

For Enterprise Subscriptions, Cloud-integration is only run on the `Primary Cluster`. Note that the file is a json array where multiple accounts and providers can be configured.

* [AWS cloud-integration](/aws-cloud-integrations.md)
* [Azure cloud-integration](/azure-out-of-cluster.md)
* [GCP cloud-integration](/gcp-out-of-cluster.md)

## Additional Considerations

The remaining sections are optional and may be useful for specific use cases.

<details><summary>
<a name="install-configs"></a><b>Product configuration at install-time</b>
</summary>

<p>Kubecost has a number of product configuration options that you can specify at install time in order to minimize the number of settings changes required within the product UI. This makes it simple to redeploy Kubecost. These values can be configured under <code>kubecostProductConfigs</code> in our <a href="https://github.com/kubecost/cost-analyzer-helm-chart/blob/bb8bcb570e6c52db2ed603f69691ac8a47ff4a26/cost-analyzer/values.yaml#L335">values.yaml</a>. These parameters are passed to a ConfigMap that Kubecost detects and writes to its /var/configs.</p>
</details>

<details><summary>
<a name="storage-config"></a><b>Storage configuration</b>
</summary>

<p>The default Kubecost installation comes with a 32Gb persistent volume and a 15-day retention period for Prometheus metrics. This is enough space to retain data for ~300 pods, depending on your exact node and container count. See the Kubecost Helm chart <a href="https://github.com/kubecost/cost-analyzer-helm-chart">configuration options</a> to adjust both retention period and storage size.</p>

<p>To determine the appropriate disk size, you can use this formula to approximate:</p>

<pre><code>needed_disk_space = retention_time_minutes * ingested_samples_per_minutes * bytes_per_sample
</code></pre>

<p>Where ingested samples can be measured as the average over a recent period, e.g. <code>sum(avg_over_time(scrape_samples_post_metric_relabeling[24h]))</code>. On average, Prometheus uses around 1.5-2 bytes per sample. So ingesting 100k samples per minute and retaining for 15 days would demand around 40 GB. It&rsquo;s recommended to add another 20-30% capacity for headroom and WAL. More info on disk sizing <a href="https://prometheus.io/docs/prometheus/latest/storage/#operational-aspects">here</a>.</p>

<p><strong>Note:</strong> We do not recommend retaining greater than 30 days of data in Prometheus for larger clusters. For long-term data retention, contact us (support@kubecost.com) about Kubecost with durable storage enabled.</p>

<p><a href="docs.kubecost.com/storage">More info on Kubecost Storage</a></p>
</details>

<details><summary>
<a name="requests-limits"></a><b>Setting Requests & Limits</b>
</summary>

<p>It's recommended that users set and/or update resource requests and limits before taking Kubecost into production at scale. These inputs can be configured in the Kubecost <a href="https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml">values.yaml</a> for Kubecost modules + subcharts.</p>

<p>The exact recommended values for these parameters depend on the size of your cluster, availability requirements, and usage of the Kubecost product. Suggested values for each container can be found within Kubecost itself on the namespace page. More info on these recommendations is available <a href="http://blog.kubecost.com/blog/requests-and-limits/">here</a>.</p>

<p>In practice, we recommend running Kubecost for up to 7 days on a production cluster and then tuning resource requests/limits based on resource consumption. Reach out any time to support@kubecost.com if we can help give further guidance.</p>
</details>

<details><summary>
<a name="node-exporter"></a><b>Using an existing node exporter</b>
</summary>

<p>For teams already running node exporter on the default port, our bundled node exporter may remain in a <code>Pending</code> state. You can optionally use an existing node exporter DaemonSet by setting the <code>prometheus.nodeExporter.enabled</code> and <code>prometheus.serviceAccounts.nodeExporter.create</code> Kubecost helm chart config options to <code>false</code>. More configs options shown <a href="https://github.com/kubecost/cost-analyzer-helm-chart">here</a>. Note: this requires your existing node exporter endpoint to be visible from the namespace where Kubecost is installed.</p>

</details>

<details><summary>
<a name="no-pvs"></a><b>Deploying Kubecost without persistent volumes</b>
</summary>

<p>You may optionally pass the following Helm flags to install Kubecost and its bundled dependencies without any Persistent Volumes. Note any time the Prometheus server pod is restarted then all historical billing data will be lost unless Thanos or other long-term storage is enabled in the Kubecost product.</p>

<pre><code>--set prometheus.alertmanager.persistentVolume.enabled=false
--set prometheus.pushgateway.persistentVolume.enabled=false
--set prometheus.server.persistentVolume.enabled=false
--set persistentVolume.enabled=false
</code></pre>

</details>

<details><summary>
<a name="cluster-efficiency"></a><b>Cost Optimization</b>
</summary>

<p>For teams interested in reducing their Kubernetes costs, we have seen it be beneficial to first understand how provisioned resources have been used.
  There are two major concepts to start with: pod resource efficiency and cluster idle costs. </p>

<p>1. Resource efficiency over a time window is defined as the resource utilization over that time window versus the resource request over the same time window. It is cost-weighted and defined as followed:

<ul>
<li>((CPU Usage / CPU Requested) * CPU Cost) + (RAM Usage / RAM Requested) * RAM Cost) / (RAM Cost + CPU Cost))</li>
<li>CPU Usage = rate(container_cpu_usage_seconds_total) over the time window </li>
<li>RAM Usage = avg(container_memory_working_set_bytes) over the time window</li>
</ul></p>

<p>Eg: If a pod is requesting 2 CPU and 1Gb, using 500mCPU and 500MB, CPU on the node costs $10/CPU , and RAM on the node costs $1/GB, we have ((0.5/2) * 20 + (0.5/1) * 1) / (20 + 1) = 5.5 / 21 = 26%</p>

<p>2. Idle Cost is defined as the difference between the cost of allocated resources and the cost of the hardware they run on. Allocation is defined as the max of usage and requests. So, idle costs can also be thought of as the cost of the space that the kubernetes scheduler could add pods without disrupting any workloads in but is not currently. Idle can be charged back to pods on a cost-weighted basis or viewed as a separate line item.</p>

<p>The most common pattern fo cost reduction is to ask service owners to tune the efficiency of their pods, then reclaiming space by setting target idle costs. The Kubecost product (Cluster Overview page) provides a view into this data for an initial assessment of resource efficiency and the cost of waste.</p>

<p>With an overall understanding of idle spend and resource efficiency, you will have a better sense of where to focus efforts for efficiency gains. Each resource type can now be tuned for your business. Most teams we’ve seen end up targeting idle in the following ranges.</p>

<ul>
<li>CPU: 50%-65%</li>
<li>Memory: 45%-60%</li>
<li>Storage: 65%-80%</li>
</ul>

<p>Target figures are highly dependent on the predictability and distribution of your resource usage (e.g. P99 vs median), the impact of high utilization on your core product/business metrics, and more. While too low resource utilization is wasteful, too high utilization can lead to latency increases, reliability issues, and other negative behavior.</p>

<p>Efficiency targets can depend on the SLAs of the application-- see our notes on <a href="https://github.com/kubecost/docs/blob/main/api-request-right-sizing.md">request right-sizing</a> for more details.</p>

</details>

</br>



<!--- {"article":"4407595947799","section":"4402815636375","permissiongroup":"1500001277122"} --->
