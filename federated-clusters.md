Multi-Cluster Kubecost
======================


There are three options that Kubecost supports for environments with multiple clusters:

1. `Kubecost Free` gives visibility into a single cluster at time. Each cluster performs its own `cloud-billing` reconciliation.

2. `Kubecost Business` gives visibility into a single cluster at time and uses a [context switcher](/context-switcher.md) to move between each cluster. Each cluster performs its own `cloud-billing` reconciliation.

3. `Kubecost Enterprise` allows for a ___single-pane-of-glass___ view into all aggregated cluster costs globally. A `primary cluster` serves the Kubecost UI and API endpoints and all `secondary clusters` send metrics to a central storage bucket. The `primary cluster` performs `cloud-billing` reconciliation for all clusters. See: [Multi-Cluster Federation](./federated-clusters.md) options.

`Cloud-billing` (aka `cloud-integration`) allows Kubecost to use actual billed costs for all resources instead of relying on onDemand rates. See [Advanced Configuration](https://docs.kubecost.com/#advanced-configuration) for more detail.

> **Note**: Kubecost Free version can now be installed on an unlimited number of individual clusters. Larger teams will benefit from one of the above subscriptions to better manage many clusters. See [pricing](https://www.kubecost.com/pricing) for more details.

## Enterprise Federation

There are two primary methods to aggregate all cluster information back to a single Kubecost UI:

- [Thanos Federation](./thanos-setup.md)
- [Kubecost ETL Federation](./federated-etl.md)

> **Note**: This feature requires an Enterprise license.

Both methods allow for greater efficiency by running the resource intensive workloads on a single primary-cluster, while running a subset of components on the remaining clusters.

For environments that already have a Prometheus instance, this ETL Federation may be preferred because the only dependency will be a single Kubecost pod for monitored cluster.

The below diagrams highlight the two architectures:

**Kubecost Thanos Federation**
![Thanos Overview](https://raw.githubusercontent.com/kubecost/docs/main/images/thanos-architecture.png)

----

**Kubecost ETL Federation**
![ETL Federation Overview](https://raw.githubusercontent.com/kubecost/docs/main/images/Kubecost-ETL-Federated-Architecture.png)
---

