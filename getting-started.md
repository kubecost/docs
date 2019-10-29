# Getting Started

Welcome to Kubecost! This page provides commonly used product configurations and feature overviews to help get you up and running after the Kubecost product has been [installed](http://kubecost.com/install). 

__Configuration__  
[Configuring metric storage](#storage-config)   
[Using an existing Prometheus or Grafana installation](#custom-prom)  
[Using an existing node exporter installation](#node-exporter)  
[Creating an Ingress with basic auth](#basic-auth)  
[Adding a spot instance configuration (AWS only)](#spot-nodes)  
[Allocating out of cluster costs](#out-of-cluster)

__Next Steps__  
[Measure cluster cost efficiency](#cluster-efficiency)  
[Cost monitoring best practices](http://blog.kubecost.com/blog/cost-monitoring/)   
[Understanding cost allocation metrics](/cost-allocation.md)
<br/><br/>

## <a name="storage-config"></a>Storage configuration

The default Kubecost installation comes with a 32Gb persistent volume and 15-day retention period for Prometheus metrics. This is enough space to retain data for ~300 pods, depending on your exact node and container count. See the Kubecost Helm chart [configuration options](https://github.com/kubecost/cost-analyzer-helm-chart) to adjust both retention period and storage size. 

## <a name="custom-prom"></a>Custom Prometheus & Grafana

Using your existing Grafana & Prometheus installation is officially supported in our paid products today. You can see basic setup instructions [here](/custom-prom.md). In our free product, we provide best efforts support for this integration because of nuances required in completing this integration successfully. Please contact us (team@kubecost.com) if you want to learn more or if you think we can help!

## <a name="node-exporter"></a>Using an existing node exporter 

You can use an existing node exporter DaemonSet, instead of installing another, by toggling the Kubecost helm chart config options (`prometheus.nodeExporter.enabled` and `prometheus.serviceAccounts.nodeExporter.create`) shown [here](https://github.com/kubecost/cost-analyzer-helm-chart). Note: to do this successfully your existing node exporter must be configured to explore metrics on it's default endpoint.

## <a name="basic-auth"></a>Basic auth Ingress example 

The following definition provides an example Ingress with basic auth.

Note: on GCP, you will need to update the `kubecost-cost-analyzer` service to become a `NodePort` instead of a `ClusterIP` type service.

```
apiVersion: v1
data:
  auth: YWRtaW46JGFwcjEkZ2tJenJxU2ckMWx3RUpFN1lFcTlzR0FNN1VtR1djMAo= # default is admin:admin -- to be replaced
kind: Secret
metadata:
  name: kubecost-auth
  namespace: kubecost
type: Opaque
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: kubecost-ingress
  namespace: kubecost
  labels:
    app: kubecost
  annotations:
     nginx.ingress.kubernetes.io/auth-type: basic
     nginx.ingress.kubernetes.io/auth-secret: kubecost-auth
     nginx.ingress.kubernetes.io/auth-realm: "Authentication Required - ok"
spec:
  backend:
    serviceName: kubecost-cost-analyzer
    servicePort: 9090
``` 

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
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": "*"
        }
    ]
}
```

## <a name="out-of-cluster"></a>Allocating out of cluster costs

**[AWS]** Provide your congifuration info in Settings. The information needs includes S3 bucket name, Athena table name, Athena table region, and Athena database name. View [this page](/aws-out-of-cluster.md) for more information on completing this process.

**[GCP]** Provide configuration info by selecting "Add key" from the Cost Allocation Page. View [this page](/gcp-out-of-cluster.md) for more information on completing this process.


## <a name="cluster-efficiency"></a>Measuring cluster cost efficiency

For teams interested in reducing their Kubernetes costs, we have seen it be beneficial to first understand how efficiently  provisioned resources have been used. This can be answered by measuring the cost of idle resources (e.g. compute, memory, etc)  as a percentage of your overall cluster spend. This figure represents the impact of many infrastructure and application-level decision, i.e. machine type selection, bin packing efficiency, and more. The Kubecost product (Cluster Overview page) provides a view into this data for an initial assessment of resource efficiency and the cost of waste.

<div style="text-align:center;"><img src="/cluster-efficiency.png" /></div>

With an overall understanding of idle spend you will have a better sense for where to focus efforts for efficiency gains. Each resource type can now be tuned for your business. Most teams we’ve seen end up targeting utilization in the following ranges:

* CPU: 50%-65%
* Memory: 45%-60%
* Storage: 65%-80%

Target figures are highly dependent on the predictability and distribution of your resource usage (e.g. P99 vs median), the impact of high utilization on your core product/business metrics, and more. While too low resource utilization is wasteful, too high utilization can lead to latency increases, reliability issues, and other negative behavior. 
