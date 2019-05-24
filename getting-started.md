# Getting Started

This page provides commonly used product configurations and recommended next steps once the commercial Kubecost product has been [installed](http://kubecost.com/install). 

__Configuration__  
[Storage configuration](#storage-config)   
[Using an existing Prometheus or Grafana installation](#custom-prom)  
[Creating an Ingress with basic auth](#basic-auth)  
[Spot Instance Configuration (AWS only)](#spot-nodes)  
[Allocating out of cluster costs](#out-of-cluster)

__Initial Actions__  
[Measure cluster cost efficiency](#cluster-efficiency)

## <a name="storage-config"></a>Storage configuration

The default Kubecost installation comes with a 32Gb persistent volume and 15-day retention period. This is enough space to retain data for ~300 pods, depending on node and container count. See the Kubecost Helm chart [configuration options](https://github.com/kubecost/cost-analyzer-helm-chart) on how to change both retention period and storage size. 

## <a name="custom-prom"></a>Custom Prometheus & Grafana

Using your existing Grafana & Prometheus installation is supported in our paid offering today. You can see basic setup instructions [here](/custom-prom.md). In our free product, we provide best efforts support for this intergation because of nuances required in completing this integration successfully. It's actively support in our paid product. Please contact us (team@kubecost.com) if you want to learn more or if you think we can help!

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


## <a name="out-of-cluster"></a>Allocating out of cluster costs

[AWS] Provide your congifuration info in Settings. The information needs includes S3 bucket name, Athena table name, Athena table region, and Athena database name. View [this page](/aws-out-of-cluster.md) for more information on completing this process.

[GCP] Provide configuration info by selecting "Add key" from the Cost Allocation Page. View [this page](/gcp-out-of-cluster.md) for more information on completing this process.


## <a name="cluster-efficiency"></a>Measuring cluster cost efficiency

For teams interested in reducing their Kubernetes costs, we have seen it be beneficial to first understand how efficiently  provisioned resources have been used. This can be answered by measuring the cost of idle resources (e.g. compute, memory, etc)  as a percentage of your overall cluster spend. This figure represents the impact of many infrastructure and application-level decision, i.e. machine type selection, bin packing efficiency, and more. The Kubecost product (Cluster Overview page) provides a view into this data for an initial assessment of resource efficiency and the cost of waste.

<div style="text-align:center;"><img src="/cluster-efficiency.png" /></div>

With an overall understanding of idle spend you will have a better sense for where to focus efforts for efficiency gains. Each resource type can now be tuned for your business. Most teams we’ve seen end up targeting utilization in the following ranges:

* CPU: 50%-65%
* Memory: 45%-60%
* Storage: 65%-80%

Target figures are highly dependent on the predictability and distribution of your resource usage (e.g. P99 vs median), the impact of high utilization on your core product/business metrics, and more. While too low resource utilization is wasteful, too high utilization can lead to latency increases, reliability issues, and other negative behavior. 
