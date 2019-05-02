# Getting Started

This page provides commonly used product configurations and recommended next steps for Kubecost once [installation](http://kubecost.com/install) is completed. 

__Configuration__  
[Using an existing Prometheus or Grafana installation](#custom-prom)  
[Creating an Ingress with basic auth](#basic-auth)  
[Spot Instance Configuration (AWS only)](#spot-nodes)  
[Allocating out of cluster costs](#out-of-cluster)

## <a name="custom-prom"></a>Custom Prometheus & Grafana

Using your existing Grafana & Prometheus installation is supported in our paid offering today. This is not currently included in our free tier because of several nuances required in completing this integration successfully. Please contact us (team@kubecost.com) if you want to learn more!

## <a name="basic-auth"></a>Basic auth Ingress example 

The following definition provides an example Ingress with basic auth.

Note: on GCP, you will need to update the `kubecost-cost-analyzer` service to become a `NodePort` instead of a `ClusterIP` type service.

```
apiVersion: v1
data:
  auth: YWRtaW46JGFwcjEkZ2tJenJxU2ckMWx3RUpFN1lFcTlzR0FNN1VtR1djMAo= # default is admin:admin -- to be replaced
kind: Secret
metadata:
  creationTimestamp: "2019-04-26T23:36:47Z"
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

[AWS] Provide your bucket congifuration info in `/bucketconfig.html` which is available from the Cost Allocation page. This information includes S3 bucket name, Athena table name, Athena table region, and Athena database name. View [this page](/aws-out-of-cluster.md) for more information on completing this process.
