Multi-cluster
=============

Kubecost supports the ability to view cost and health data across multiple Kubernetes clusters and cloud providers.
Below are the steps for adding an additional cluster on the **Kubecost Business & Enterprise** tier.

## Add from frontend

When adding a cluster directly from the frontend, Kubecost adds it locally for your browser. To make this cluster accessible to other users in your organization, follow the steps to [add at install-time](#add-at-install-time) below. 

1. Install Kubecost on the additional cluster you would like to view. The recommended Kubecost install path is available at [kubecost.com/install](https://www.kubecost.com/install).

2. Expose port 9090 of the `kubecost-cost-analyzer` pod. This can be done with a Kubernetes Ingress ([example](https://github.com/kubecost/docs/blob/main/getting-started.md#basic-auth)) or LoadBalancer ([example](https://github.com/kubecost/docs/blob/main/kubecost-lb.yaml)). **Warning:** by default a LoadBalancer exposes endpoints to the wide internet. Be careful about following the authentication requirements of your organization and environment.

3. Select `Add new cluster` on the Kubecost home page and provide the accessible URL (with port included) for the target Kubecost installation. Here's an example: `http://e9a706220bae04199-1639813551.us-east-2.elb.amazonaws.com:9090`

![Add a cluster view](https://raw.githubusercontent.com/kubecost/docs/main/kubecost-index.png)

## Add at install-time

After following Steps #1 and #2 above, provide a list of cluster names/endpoints under `kubecostProductConfigs.clusters`
in [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) during Helm install or upgrade. Here's an example values block:

```
 kubecostProductConfigs:
  clusters:
   - name: "Cluster A"
     address: http://cluster-a.kubecost.com:9090
```

Edit this doc on [Github](https://github.com/kubecost/docs/blob/main/multi-cluster.md)

<!--- {"article":"4407595970711","section":"4402815636375","permissiongroup":"1500001277122"} --->
