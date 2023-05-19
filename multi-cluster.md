# Multi-Cluster

There are two options that Kubecost supports for environments with multiple clusters:

1. `Kubecost Free` gives visibility into a single cluster at time. Each cluster performs its own `cloud-billing` reconciliation.
1. `Kubecost Enterprise` allows for a _**single-pane-of-glass**_ view into all aggregated cluster costs globally. Agents on all clusters ship metrics to a shared storage bucket. A `primary cluster` serves the Kubecost UI, API endpoints, and performs global `cloud-billing` reconciliation for all clusters.

`Cloud-billing` (aka `cloud-integration`) allows Kubecost to use actual billed costs for all resources instead of relying on on-demand rates. See [Advanced Configuration](https://docs.kubecost.com/install-and-configure/advanced-configuration) for more detail.

> **Note**: Kubecost Free version can now be installed on an unlimited number of individual clusters. Larger teams will benefit from Kubecost Enterprise to better manage many clusters. See [pricing](https://www.kubecost.com/pricing) for more details.

## Enterprise Federation

There are two primary methods to aggregate all cluster information back to a single Kubecost UI:

* [Thanos Federation](thanos-setup.md)
* [Kubecost ETL Federation](federated-etl.md)

> **Note**: This feature requires an Enterprise license.

Both methods allow for greater efficiency by running the resource intensive workloads on a single `primary-cluster`, and run an agent on all other monitored clusters.

For environments that already have a Prometheus instance, ETL Federation may be preferred because only a single Kubecost pod is required.

The below diagrams highlight the two architectures:

**Kubecost Thanos Federation**

![Thanos Overview](https://raw.githubusercontent.com/kubecost/docs/main/images/thanos-architecture.png)

**Kubecost ETL Federation**

![ETL Federation Overview](https://raw.githubusercontent.com/kubecost/docs/main/images/Kubecost-ETL-Federated-Architecture.png)
