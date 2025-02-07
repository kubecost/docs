# Thanos Federation (Deprecated)

{% hint style="warning" %}
As of Kubecost v2, support for Thanos is deprecated. Consider [transitioning to our Aggregator architecture](/install-and-configure/install/multi-cluster/federated-etl/thanos-migration-guide.md) if you plan to upgrade.
{% endhint %}

{% hint style="info" %}
This feature is only officially available on Kubecost Enterprise plans.
{% endhint %}

Thanos is a tool to aggregate Prometheus metrics to a central object storage (S3 compatible) bucket. Thanos is implemented as a sidecar on the Prometheus pod on all clusters. Thanos Federation is one of two primary methods to aggregate all cluster information back to a single view as described in our [Multi-Cluster](/install-and-configure/install/multi-cluster/multi-cluster.md#enterprise-federation) article.

The *preferred* method for multi-cluster is [ETL Federation](/install-and-configure/install/multi-cluster/federated-etl/federated-etl.md). The configuration guide below is for Kubecost Thanos Federation, which may not scale as well as ETL Federation in large environments.

This guide will cover how to enable Thanos on your primary cluster, and on any additional secondary clusters.

## Configuration

1. Follow steps [here](configuring-thanos.md) to enable all required Thanos components on a Kubecost primary cluster, including the Prometheus sidecar.
2. For each additional cluster, only the Thanos sidecar is needed.

Consider the following Thanos recommendations for secondaries:

    * Reuse your existing storage bucket and access credentials.
    * Do not deploy multiple instances of `thanos-compact`.
    * Optionally deploy `thanos-bucket` in each additional cluster, but it is not required.
    * Optionally disable `thanos.store` and `thanos.query` (Clusters with store/query disabled will only have access to their metrics but will still write to the global bucket.)

    Thanos modules can be disabled in [*thanos/values.yaml*](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/charts/thanos/values.yaml), or in [*values-thanos.yaml*](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values-thanos.yaml) if overriding these values from a values-thanos.yaml file supplied from the command line (`helm upgrade kubecost -f values.yaml -f values-thanos.yaml`), or by passing these parameters directly via Helm install or upgrade as follows:

    ```
    --set thanos.compact.enabled=false --set thanos.bucket.enabled=false
    ```

    You can also optionally disable `thanos.store`, `thanos.query` and `thanos.queryFrontend` with thanos/values.yaml or with these flags:

    {% code overflow="wrap" %}
    ```
    --set thanos.query.enabled=false --set thanos.store.enabled=false --set thanos.queryFrontend.enabled=false
    ```
    {% endcode %}
3. Ensure you provide a unique identifier for `prometheus.server.global.external_labels.cluster_id` to have additional clusters be visible in the Kubecost product, e.g. `cluster-two`.

{% hint style="info" %}
`cluster_id` can be replaced with another label (e.g. `cluster`) by modifying .Values.kubecostModel.promClusterIDLabel.
{% endhint %}

4. Follow the same verification steps available [here](/install-and-configure/install/multi-cluster/thanos-setup/configuring-thanos.md).

Sample configurations for each cloud provider can be found [here](https://github.com/kubecost/poc-common-configurations/).

## Architecture diagram

![Thanos Overview](/images/thanos-architecture.png)
