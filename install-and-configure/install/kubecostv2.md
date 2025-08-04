# Kubecost v2 Install/Upgrade

Kubecost v2 introduced massive functionality changes including changes to the backend architecture. This may require additional changes be made to your environment before upgrading from an older version of Kubecost to 2.0+. This article reviews several different common configurations and explains any necessary steps to take.

{% hint style="danger" %}
After upgrading to v2, it's possible saved reports may not properly display in the Kubecost UI. Follow [this solution](/using-kubecost/navigating-the-kubecost-ui/reports.md#saved-reports-not-appearing-in-kubecost-ui-after-upgrading-to-v2) if you experience this problem.
{% endhint %}

## Single cluster users

If you have a single cluster installation of Kubecost (i.e. one primary Kubecost instance on each cluster), then you can follow the standard upgrade process for Kubecost 2.0+.

If you are using Helm, it may look something like this:

```bash
helm upgrade kubecost --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
    --namespace kubecost \
    -f values.yaml
```

Upon upgrading, you should see the following pods running:

```bash
$ kubectl get pods -n kubecost
NAME                                          READY   STATUS    RESTARTS   AGE
kubecost-cost-analyzer-866d7964fc-8jxr2       4/4     Running   0          108s
kubecost-grafana-cf6c67ff8-tsbcn              2/2     Running   0          108s
kubecost-prometheus-server-697c5f5675-mc4tm   1/1     Running   0          108s
```

## Enterprise federated ETL users

As a federated ETL user, there should be minimal changes. Be aware that Kubecost 2.0+ removes the Federator and instead introduces the Aggregator. When upgrading to Kubecost 2.0+, the federator pod will not be deployed. No action is required.

{% hint style="warning" %}
Ensure you have set the Helm flag `.Values.federatedETL.federatedCluster=true` in all your deployments. Each cluster is still responsible for building & pushing ETL files to the object store.
{% endhint %}

When upgrading to Kubecost v2, the Aggregator should be automatically deployed. It is recommended to upgrade your primary cluster first, then secondary clusters. This is documented in our [Federated ETL migration guide](/install-and-configure/install/multi-cluster/federated-etl/federated-etl-migration-guide.md) when upgrading.

## Enterprise Thanos users

This section applies to all users who use a multi-cluster Prometheus deployment. This includes architectures such as Thanos, Amazon Managed Prometheus, and Google Managed Prometheus.

As of Kubecost v2, Kubecost requires a central object store which all Kubecost instances can write to.

{% hint style="warning" %}
A future release will add support for multi-cluster Prometheus without requiring external object-storage.
{% endhint %}

Importantly, Kubecost 2.0+ removes support for Thanos via its Helm chart. For details on how to migrate to Kubecost 2.0+, please refer to the [Thanos migration guide](/install-and-configure/install/multi-cluster/federated-etl/thanos-migration-guide.md) and talk to your Kubecost representative.

## Enterprise SSO/RBAC users

Kubecost 2.0+ has significant architectural changes that may impact RBAC. This should be tested before giving end-users access to the UI. Kubecost has tested various configurations and believe that 2.0+ will be 100% compatible with existing configurations.

To upgrade to Kubecost 2.0+, please add the following helm value to your existing configuration:

```yaml
upgrade:
  toV2: true
```

## Troubleshooting

If you encounter any issues during the upgrade process, please refer to the section below, our [Aggregator troubleshooting guide](/install-and-configure/install/multi-cluster/federated-etl/aggregator.md#troubleshooting-aggregator), our [general troubleshooting guide](/troubleshooting/troubleshoot-install.md), or reach out to <support@kubecost.com>.

### Running Aggregator in v1.107 or v1.108

```txt
ERROR:
An existing Aggregator StatefulSet was found in your namespace.
Before upgrading to Kubecost 2.0+, please `kubectl delete` this Statefulset.
```

If you were running the Aggregator in v1.107 or v1.108, you will need to manually run `kubectl delete sts/kubecost-aggregator` before upgrading to v2. This is due to a breaking change in the StatefulSet template, specifically a removal of one of the Aggregator's PVs, which Helm does not allow an upgrade.

### Cloud integration working in v1, but not in v2

First, ensure you have upgraded Kubecost to the latest version of v2. Patches have been released to fix miscellaneous cloud integration issues. You can learn more about what's been fixed in our [release notes](https://github.com/kubecost/cost-analyzer-helm-chart/releases).

Next, ensure that you are configuring the cloud integration via the `cloud-integration` secret and `.Values.kubecostProductConfigs.cloudIntegrationSecret` Helm value. This is now the only supported way of configuring your cloud integration
