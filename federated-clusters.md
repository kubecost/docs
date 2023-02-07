Multi-Cluster Federation (Enterprise)
=====================================

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

