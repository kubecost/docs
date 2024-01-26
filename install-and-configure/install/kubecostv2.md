# Kubecost 2.x Install/Upgrade

## Single cluster users

If you have a single cluster installation of Kubecost (i.e. one primary Kubecost instance on each cluster), then you can follow the standard upgrade process for Kubecost 2.x.

If you are using Helm, it may look something like this:

```sh
```

Upon upgrading, you should see the following pods running:

```sh
```

## (Enterprise) Federated ETL users

As a FederatedETL user, there should be minimal changes. Be aware that Kubecost 2.x removes the Federator and instead introduces the Aggregator. When upgrading to Kubecost 2.x, the federator pod will not be deployed. No action is required.



It is important that `.Values.federatedETL.federatedCluster=true` in all your deployments. Each cluster is still responsible for building & pushing ETL files to the object store.

When upgrading to Kubecost 2.0, the Aggregator should be automatically deployed. No additional values need to be set, however additional details can be found [here](/install-and-configure/install/multi-cluster/federated-etl/aggregator.md).

## (Enterprise) Thanos users

This section applies to all users who use a multi-cluster Prometheus deployment. This includes architectures such as Thanos, Amazon Managed Prometheus, and Google Managed Prometheus.

As of Kubecost 2.0, Kubecost requires a central object store which all Kubecost instances can write to.

Note: A future release will add support for multi-cluster Prometheus without requiring external object-storage.

Importantly, Kubecost 2.x removes support for Thanos via its Helm chart. For details on how to migrate to Kubecost 2.x, please refer to the [migration guide](/install-and-configure/install/multi-cluster/federated-etl/thanos-migration-guide.md) and talk to your Kubecost representative.

## (Enterprise) Single Sign On (SSO)/RBAC users

Note that Kubecost 2.x has significant architectural changes that may impact RBAC.
This should be tested before giving end-users access to the UI.
Kubecost has tested various configurations and believe that 2.x will be 100% compatible with existing configurations.

To upgrade to Kubecost 2.x, please add the following helm value to your existing configuration:

```yaml
upgrade:
  toV2: true
```
