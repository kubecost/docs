Multi-Cluster Options
=====================

There are three options that Kubecost supports for environments with multiple clusters:

1. `Kubecost Free` gives visibility into a single-cluster-at-time. Each cluster performs its own `cloud-billing` reconciliation.
2. `Kubecost Business` gives visibility into a single-cluster-at-time and uses a [context switcher](/context-switcher.md) to move between each cluster. Each cluster performs its own `cloud-billing` reconciliation.
3. `Kubecost Enterprise` allows for a ___single-pane-of-glass___ view into all aggregated cluster costs globally. A `primary cluster` serves the Kubecost UI and API endpoints and all `secondary clusters` send metrics to a central storage bucket. The `primary cluster` performs `cloud-billing` reconciliation for all clusters. See: [Multi-Cluster Federation](./federated-clusters.md) options.

`Cloud-billing` (aka cloud-integration) allows Kubecost to use actual billed costs for all resources instead of relying on onDemand rates. See [Advanced Configuration](https://docs.kubecost.com/#advanced-configuration) for more detail.

> **Note**: Kubecost Free version can now be installed on an unlimited number of individual clusters. Larger teams will benefit from one of the above subscriptions to better manage many clusters. See [pricing](https://www.kubecost.com/pricing) for more details.
