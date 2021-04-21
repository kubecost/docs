# Getting Started

Welcome to Kubecost! This page provides commonly used product configurations and feature overviews to help get you up and running after the Kubecost product has been [installed](http://kubecost.com/install).

__Configuration__  
[Configuring metric storage](#storage-config)  
[Setting requests & limits](#requests-limits)  
[Product configuration at install-time](#install-configs)  
[Setting up a cloud integration](#cloud-integration)  
[Using an existing Prometheus or Grafana installation](#custom-prom)  
[Using an existing node exporter installation](#node-exporter)  
[Exposing Kubecost with an Ingress](#basic-auth)  
[Adding a spot instance configuration (AWS only)](#spot-nodes)  
[Allocating out of cluster costs](#out-of-cluster)  
[Refectling Reserved Instance or Committed Use Pricing](#ri-committed-discount)  
[Deploying Kubecost without persistent volumes](#no-pvs)

__Next Steps__  
[Measure cluster cost efficiency](#cluster-efficiency)  
[Cost monitoring best practices](http://blog.kubecost.com/blog/cost-monitoring/)  
[Understanding cost allocation metrics](/cost-allocation.md)  
<br/><br/>

## <a name="storage-config"></a>Storage configuration

The default Kubecost installation comes with a 32Gb persistent volume and a 15-day retention period for Prometheus metrics. This is enough space to retain data for ~300 pods, depending on your exact node and container count. See the Kubecost Helm chart [configuration options](https://github.com/kubecost/cost-analyzer-helm-chart) to adjust both retention period and storage size.

To determine the appropriate disk size, you can use this formulate to approximate:

```
needed_disk_space = retention_time_minutes * ingested_samples_per_minutes * bytes_per_sample
```

Where ingested samples can be measured as the average over a recent period, e.g. `sum(avg_over_time(scrape_samples_post_metric_relabeling[24h]))`. On average, Prometheus uses around 1.5-2 bytes per sample. So ingesting 100k samples per minute and retaining for 15 days would demand around 40gb. It's recommended to add another 20-30% capacity for headroom and WAL. More info on disk sizing [here](https://prometheus.io/docs/prometheus/latest/storage/#operational-aspects).

**Note:** We do not recommend retaining greater than 30 days of data in Prometheus for larger clusters. For long-term data retention, contact us (team@kubecost.com) about Kubecost with durable storage enabled.

[More info on Kubecost Storage](/storage.md)

## <a name="custom-prom"></a>Bring your own Prometheus or Grafana

The Kubecost Prometheus deployment is used as both as a source and a sink for cost & capacity metrics. It's optimized to not interfere with other observability instrumentation and by default only contains metrics that are useful to the Kubecost product. This amounts to retaining 70-90% fewer metrics than a standard Prometheus deployment.

For the best experience, we generally recommend teams use the bundled `prometheus-server` & `grafana` but reuse their existing `kube-state-metrics` and `node-exporter` deployments if they already exist. This setup allows for the easiest installation process, easiest on-going maintenance, minimal duplication of metrics, and more flexible metric retention.

That being said, we do support using an existing Grafana & Prometheus installation in our paid products today. You can see basic setup instructions [here](/custom-prom.md). In our free product, we only provide best efforts support for this integration because of the nuances required in completing this integration successfully. Please contact us (team@kubecost.com) if you want to learn more or if you think we can help!

## <a name="requests-limits"></a>Setting Requests & Limits

It's recommended that users set and/or update resource requests and limits before taking Kubecost into production at scale. These inputs can be configured in the Kubecost [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) for Kubecost modules + subcharts.

Exact recommended values for these parameters depend on the size of your cluster, availability requirements, and usage of the Kubecost product. Suggested values for each container can be found within Kubecost itself on the namespace page. More info on these recommendations is available [here](http://blog.kubecost.com/blog/requests-and-limits/).

In practice, we recommend running Kubecost for up to 7 days on a production cluster and then tuning resource requests/limits based on resource consumption. Reach out any time to team@kubecost.com if we can help give further guidance.

## <a name="install-configs"></a>Product configuration at install-time

Kubecost has a number of product configuration options that you can specify at install time in order to minimize the number of settings changes required within product UI. This makes it simple to redeploy Kubecost. These values can be configured under `kubecostProductConfigs` in our [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/bb8bcb570e6c52db2ed603f69691ac8a47ff4a26/cost-analyzer/values.yaml#L335). These parameters are passed to a configmap that Kubecost detects and writes to its /var/configs.

## <a name="cloud-integration"></a>Setting up a cloud integration

By default, Kubecost dynamically detects your cloud provider and pulls list prices on Azure, AWS, and GCP for all in-cluster assets. By completing a cloud integration with one of these providers, you get the ability to view Kubernetes cost metrics side-by-side with external cloud services cost, e.g. S3, BigQuery, Azure Database Services. Additionally, it allows Kubecost to reconcile spend with your actual cloud bill to reflect enterprise discounts, spot market prices, comittment discounts, and more. This gives teams running Kubernetes a complete and accurate picture of costs. 

&nbsp;&nbsp;&nbsp;&nbsp;[Azure billing integration](/azure-out-of-cluster.md)  
&nbsp;&nbsp;&nbsp;&nbsp;[AWS billing integration](/aws-out-of-cluster.md)  
&nbsp;&nbsp;&nbsp;&nbsp;[GCP billing integration](/gcp-out-of-cluster.md)  

## <a name="node-exporter"></a>Using an existing node exporter

For teams already running node exporter on the default port, our bundled node exporter may remain in a `Pending` state. You can optionally use an existing node exporter DaemonSet by setting the `prometheus.nodeExporter.enabled` and `prometheus.serviceAccounts.nodeExporter.create` Kubecost helm chart config options to `false`. More configs options shown [here](https://github.com/kubecost/cost-analyzer-helm-chart). Note: this requires your existing node exporter endpoint to be visible from the namespace where Kubecost is installed.

## <a name="basic-auth"></a>Kubecost Ingress examples

Enabling external access to the Kubecost product simply requires exposing access to port 9090 on the `kubecost-cost-analyzer` pod. This can be accomplished with a number of approaches, including Ingress or Service definitions. View [example Ingress definitions](https://github.com/kubecost/docs/blob/master/ingress-examples.md) for a number of approaches for accomplishing this.  

Also, the default [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) has a stock Ingress that can be used.

## <a name="spot-nodes"></a>Spot Instance Configuration (AWS only)

For more accurate Spot pricing data, visit Settings in the Kubecost frontend to configure a [data feed](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-data-feeds.html) for AWS Spot instances. This enables the Kubecost product to have actual Spot node prices vs user-provided estimates.

![AWS Spot info](/spot-settings.png)

**Necessary Steps**

1. Enable the [AWS Spot Instance data feed](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-data-feeds.html).  
2. Provide the required S3 bucket information in Settings (example shown above).  
3. Create and attach an IAM role account which can be used to read this bucket. Here's an example policy:  

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "s3:ListAllMyBuckets",
                "s3:ListBucket",
                "s3:HeadBucket",
                "s3:HeadObject",
                "s3:List*",
                "s3:Get*"
            ],
            "Resource": "*"
        }
    ]
}
```

**Spot Verification**

View logs from the `cost-model` container in the `kubecost-cost-analyzer` pod to confirm there are no Spot data feed access errors. You should also see a confirmation log statement like this:

```
I1104 00:21:02.905327       1 awsprovider.go:1397] Found spot info {Timestamp:2019-11-03 20:35:48 UTC UsageType:USE2-SpotUsage:t2.micro Operation:RunInstances:SV050 InstanceID:i-05487b228492b1a54 MyBidID:sir-9s4rvgbj MyMaxPrice:0.010 USD MarketPrice:0.004 USD Charge:0.004 USD Version:1}
I1104 00:21:02.922372       1 awsprovider.go:1376] Spot feed version is "#Version: 1.0"
```

The Charge figures in logs should be reflected in your `node_total_hourly_cost` metrics in Prometheus.

## <a name="out-of-cluster"></a>Allocating out of cluster costs

**[AWS]** Provide your configuration info in Settings. The information needs to include the S3 bucket name, the Athena table name, the Athena table region, and the Athena database name. View [this page](/aws-out-of-cluster.md) for more information on completing this process.

**[GCP]** Provide configuration info by selecting "Add key" from the Cost Allocation Page. View [this page](/gcp-out-of-cluster.md) for more information on completing this process.

## <a name="ri-committed-discount"></a>Accurately tracking Reserved Instance or committed use discounts

Paid versions of the Kubecost product reflect Reserved Instance (AWS), committed use (GCP), and custom-negotiated discounts into asset pricing. This allows for accurate allocation of costs to individual teams, apps, etc. Enabling this feature simply requires adding role access to cloud provider billing data and does not egress any data to external services. Contact us (team@kubecost.com) if you're interested in more information.

#### AWS Reserved Instance Details:
Accurately tracking AWS Reserved Instance prices requires access to an Athena table containing the Cost and Usage Report (CUR). Data for new RIs may be delayed until the instance data is available in the CUR. Once data is available, Kubecost will reflect the price shown in the [reservation/EffectiveCost]( http://docs.kubecost.com/getting-started#ri-committed-discount) field. Kubecost will also reconcile daily spend with cost figures available in the CUR. 


## <a name="no-pvs"></a>Deploying Kubecost without persistent volumes

You may optionally pass the following Helm flags to install Kubecost and its bundled dependancies without any Persistent Volumes. Note any time the Prometheus server pod is restarted then all historical billing data will be lost, unless Thanos or other long-term storage is enabled in the Kubecost product.  

```
--set prometheus.alertmanager.persistentVolume.enabled=false 
--set prometheus.pushgateway.persistentVolume.enabled=false 
--set prometheus.server.persistentVolume.enabled=false
--set persistentVolume.enabled=false 
```

## <a name="cluster-efficiency"></a>Measuring cluster cost efficiency

For teams interested in reducing their Kubernetes costs, we have seen it be beneficial to first understand how efficiently  provisioned resources have been used. This can be answered by measuring the cost of idle resources (e.g. compute, memory, etc)  as a percentage of your overall cluster spend. This figure represents the impact of many infrastructure and application-level decisions, i.e. machine type selection, bin packing efficiency, and more. The Kubecost product (Cluster Overview page) provides a view into this data for an initial assessment of resource efficiency and the cost of waste.

<div style="text-align:center;"><img src="/cluster-efficiency.png" /></div>

With an overall understanding of idle spend, you will have a better sense of where to focus efforts for efficiency gains. Each resource type can now be tuned for your business. Most teams we’ve seen end up targeting utilization in the following ranges:

* CPU: 50%-65%
* Memory: 45%-60%
* Storage: 65%-80%

Target figures are highly dependent on the predictability and distribution of your resource usage (e.g. P99 vs median), the impact of high utilization on your core product/business metrics, and more. While too low resource utilization is wasteful, too high utilization can lead to latency increases, reliability issues, and other negative behavior.
