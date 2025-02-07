# Multi-Cluster

{% hint style="info" %}
Kubecost Free can now be installed on an unlimited number of individual clusters. Larger teams will benefit from using Kubecost Enterprise to better manage many clusters. See [pricing](https://www.kubecost.com/pricing) for more details.
{% endhint %}

## Primary and secondary clusters

In an Enterprise multi-cluster setup, the UI is accessed through a designated primary cluster. All other clusters in the environment send metrics to a central object-store with a lightweight agent (aka secondary clusters). The primary cluster is the one running [Aggregator](/install-and-configure/install/multi-cluster/federated-etl/aggregator.md). This cluster will consume additional resources to run the Kubecost UI and backend.

{% hint style="warning" %}
Because the UI is only accessible through the primary cluster, Helm flags related to UI display are not applied to secondary clusters.
{% endhint %}

## Enterprise Federation

{% hint style="info" %}
This feature is only supported for Kubecost Enterprise.
{% endhint %}

There are two methods to aggregate all cluster information back to a single Kubecost UI:

* Preferred: [Kubecost ETL Federation](/install-and-configure/install/multi-cluster/federated-etl/federated-etl.md)
* Deprecated: [Thanos Federation](/install-and-configure/install/multi-cluster/thanos-setup/thanos-setup.md)

Both methods allow for greater compute efficiency by running the most resource-intensive workloads on a single primary cluster.

For environments that already have a Prometheus instance, ETL Federation may be preferred because only a single Kubecost pod is required.

The below diagrams highlight the two architectures:

**Kubecost ETL Federation (Preferred)**

![ETL Federation Overview](/images/diagrams/etl-federation.png)

**Kubecost Thanos Federation**

{% hint style="warning" %}
As of Kubecost v2, support for Thanos is deprecated. Consider [transitioning to our Aggregator architecture](/install-and-configure/install/multi-cluster/federated-etl/thanos-migration-guide.md) if you plan to upgrade.
{% endhint %}

![Thanos Overview](/images/thanos-architecture.png)
