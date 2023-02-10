Thanos Federation
=================

> **Note**: This feature is only officially supported on Kubecost Enterprise plans.

There are two primary methods to aggregate all cluster information back to a single Kubecost UI described in [Federated Clusters Overview](./federated-clusters.md).

Below is the configuration guide using **Kubecost Thanos Federation**.

# Configuration

1. Follow steps [here](/long-term-storage.md#option-b-out-of-cluster-storage-thanos) to enable Thanos durable storage on a Master cluster.

2. Repeat the process in Step 1 for each additional secondary cluster, with the following Thanos recommendations:
   * Reuse your existing storage bucket and access credentials.
   * Do not deploy multiple instances of `thanos-compact`.
   * Optionally deploy `thanos-bucket` in each additional cluster, but it is not required.
   * Optionally disable `thanos.store` and `thanos.query` (Clusters with store/query disabled will only have access to their metrics but will still write to the global bucket.)

    Thanos modules can be disabled in [thanos/values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/charts/thanos/values.yaml),
    or in [values-thanos.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values-thanos.yaml) if overriding these values from a values-thanos.yaml file supplied from command line (`helm upgrade kubecost -f values.yaml -f values-thanos.yaml`),
    or by passing these parameters directly via helm install or upgrade as follows:

    ```
    --set thanos.compact.enabled=false --set thanos.bucket.enabled=false
    ```

    You can also optionally disable `thanos.store`, `thanos.query` and `thanos.queryFrontend` with thanos/values.yaml or with these flags:

    ```
    --set thanos.query.enabled=false --set thanos.store.enabled=false --set thanos.queryFrontend.enabled=false
    ```

3. Ensure you provide a unique identifier for `prometheus.server.global.external_labels.cluster_id` to have additional clusters be visible in the Kubecost product, e.g. `cluster-two`.

    > **Note**: `cluster_id` can be replaced with another label (e.g. `cluster`) by modifying .Values.kubecostModel.promClusterIDLabel.

4. Follow the same verification steps available [here](/long-term-storage.md#verify-thanos).

Sample configurations for each cloud provider can be found here: [https://github.com/kubecost/poc-common-configurations/](https://github.com/kubecost/poc-common-configurations/)

![Thanos Overview](https://raw.githubusercontent.com/kubecost/docs/main/images/thanos-architecture.png)
