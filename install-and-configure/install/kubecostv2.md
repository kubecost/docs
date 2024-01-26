# Kubecost 2.0 Install/Upgrade

## Single cluster users

If you have a single cluster installation of Kubecost (i.e. one primary Kubecost instance on each cluster), then you can follow the standard upgrade process for Kubecost 2.0.

If you are using Helm, it may look something like this:

```sh
```

Upon upgrading, you should see the following pods running:

```sh
```

## (Enterprise) Federated ETL users

As a FederatedETL user, the following changes to your *values.yaml* will need to be made to primary clusters:

```yaml
federatedETL:
  federatedCluster: true
  primaryCluster: false
  federator:
    enabled: false
kubecostAggregator:
  deployMethod: "statefulset"
```

And the following changes will need to be made to your secondary clusters:

```yaml
federatedETL:
  federatedCluster: true
  primaryCluster: false
  federator:
    enabled: false
kubecostAggregator:
  deployMethod: "disabled"
```

Crucially, Kubecost 2.0 deprecates the Federator and instead introduces the Aggregator. It's still important that `.Values.federatedETL.federatedCluster=true` in all your deployments. Each cluster is still responsible for building & pushing ETL files to the object store. Visit the [Aggregator docs](/install-and-configure/install/multi-cluster/federated-etl/aggregator.md) to learn more.

## (Enterprise) Thanos users

This section applies to all users who use a multi-cluster Prometheus deployment. This includes architectures such as Thanos, Amazon Managed Prometheus, and Google Managed Prometheus.

Kubecost 2.0 will require a central object store be set up which all Kubecost instances can write to. Additionally, Kubecost 2.0 removes support for Thanos via its Helm chart. For details on how to migrate to Kubecost 2.0, please refer to the [migration guide](/install-and-configure/install/multi-cluster/federated-etl/thanos-migration-guide.md) and talk to your Kubecost representative.
