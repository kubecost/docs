# Multi-Cluster

{% hint style="info" %}
Kubecost Free can now be installed on an unlimited number of individual clusters. Larger teams will benefit from using Kubecost Enterprise to better manage many clusters. See [pricing](https://www.kubecost.com/pricing) for more details.
{% endhint %}

## Primary and secondary clusters

In an Enterprise multi-cluster setup, the UI is accessed through a designated primary cluster. All other clusters in the environment send metrics to a central object-store with a lightweight agent (aka secondary clusters). The primary cluster is designated by setting the Helm flag `.Values.federatedETL.primaryCluster=true`, which instructs this cluster to read from the `combined` folder that was processed by the federator. This cluster will consume additional resources to run the Kubecost UI and backend.

{% hint style="info" %}
As of Kubecost 1.108, agent health is monitored by a [diagnostic pod](diagnostics.md) that collects information from the local cluster and sends it to an object-store. This data is then processed by the Primary cluster and accessed via the UI and API.
{% endhint %}

{% hint style="warning" %}
Because the UI is only accessible through the primary cluster, Helm flags related to UI display are not applied to secondary clusters.
{% endhint %}

## Enterprise Federation

{% hint style="info" %}
This feature is only supported for Kubecost Enterprise.
{% endhint %}

There are two primary methods to aggregate all cluster information back to a single Kubecost UI:

* [Kubecost ETL Federation (preferred)](/install-and-configure/install/multi-cluster/federated-etl/federated-etl.md)
* [Thanos Federation](/install-and-configure/install/multi-cluster/thanos-setup/thanos-setup.md)

Both methods allow for greater compute efficiency by running the most resource-intensive workloads on a single primary cluster.

For environments that already have a Prometheus instance, ETL Federation may be preferred because only a single Kubecost pod is required.

The below diagrams highlight the two architectures:

**Kubecost ETL Federation (Preferred)**

![ETL Federation Overview](/images/kubecost-ETL-Federated-Architecture.png)

**Kubecost Thanos Federation**

![Thanos Overview](/images/thanos-architecture.png)
