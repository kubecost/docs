# Kubecost Aggregator

Aggregator is the primary query backend for Kubecost. It is enabled in all
configurations of Kubecost. In a default installation, it runs within the
cost-analyzer pod, but in a multi-cluster installation of Kubecost, some settings
must be changed. Multi-cluster Kubecost uses the [Federated
ETL](federated-etl.md) configuration without Thanos (replacing the
[Federator](federated-etl.md#other-components) component).

{% hint style="info" %}
Existing documentation for Kubecost APIs will use endpoints for non-Aggregator environments unless otherwise specified, but will still be compatible after configuring Aggregator.
{% endhint %}

## Configuring Aggregator

### Prerequisites

* Multi-cluster Aggregator can only be configured in a Federated ETL environment
* All clusters in your Federated ETL environment must be configured to build & push ETL files to the object store via `.Values.federatedETL.federatedCluster` and `.Values.kubecostModel.federatedStorageConfigSecret`. See our [Federated ETL](federated-etl.md) doc for more details.
* If you've enabled Cloud Integration, it _must_ be configured via the cloud integration secret. Other methods are now deprecated. See our [Cloud Integration](/install-and-configure/install/cloud-integration/multi-cloud.md) doc for more details.
* This documentation is for Kubecost v2.0 and higher.
* To upgrade from a Thanos multi-cluster environment to Aggregator, see our [transition doc](/install-and-configure/install/multi-cluster/federated-etl/thanos-migration-guide.md).

### Basic configuration

```yaml
kubecostAggregator:
  replicas: 1
  deployMethod: statefulset
  cloudCost:
    enabled: true
federatedETL:
  federatedCluster: true
kubecostModel:
  containerStatsEnabled: true
  cloudCost:
    enabled: false
  federatedStorageConfigSecret: federated-store
kubecostProductConfigs:
  clusterName: YOUR_CLUSTER_NAME
  cloudIntegrationSecret: cloud-integration
  productKey:
    enabled: true
    key: YOUR_KEY
prometheus:
  server:
    global:
      external_labels:
        cluster_id: YOUR_CLUSTER_NAME
# when using managed identity/irsa, set the service account accordingly:
serviceAccount:
  create: false
  name: kubecost-irsa-sa
```

### Aggregator Optimizations

For larger deployments of Kubecost, Aggregator can be tuned.

{% hint style="warning" %}
Aggregator is a memory and disk-intensive process. Ensure that your cluster has enough resources to support the configuration below.

Because the Aggregator PV is relatively small, the least expensive performance gain will be to move the storage class to a faster SSD. The storageClass name varies by provider, the terms used are gp3/extreme/premium/etc.
{% endhint %}

{% hint style="warning" %}
{% endhint %}

The settings below are in addition to the basic configuration above.

```yaml
kubecostAggregator:
  env:
    # This interval defines how long the Aggregator spends ingesting ETL data
    # from the federated store bucket into SQL tables, before cancelling its job
    # and starting over to pull newer data from the bucket. If set too low for
    # large scale users, this may inadvertantly cause the Aggregator to spend
    # longer time ingesting data. If set too high, there will be a delay in data
    # between the Kubecost Agents and the Aggregator.
    # default: 10m
    DB_BUCKET_REFRESH_INTERVAL: 1h
    # governs parallelism of derivation step
    # more threads speeds derivation, but requires significantly more
    # log level
    # default: info
    LOG_LEVEL: info
    # Increases window of data ingested from federated store.
    # default: 91
    ETL_DAILY_STORE_DURATION_DAYS: "91"
  aggregatorDbStorage:
    # governs storage size of aggregator DB storage
    # !!NOTE!! disk performance is _critically important_ to aggregator performance
    # ensure disk is specd high enough, and check for bottlenecks
    # default: 128Gi
    storageRequest: 512Gi
  resources:
    requests:
      cpu: 1000m
      memory: 1Gi
    limits:
      # cpu: 2000m
      memory: 16Gi
```

There is no baseline for what is considered a larger deployment, which will be dependent on load times in your Kubecost environment.

### Running the upgrade

If you have not already, create the required Kubernetes secrets. Refer to the [Federated ETL doc](/install-and-configure/install/multi-cluster/federated-etl/federated-etl.md) and [Cloud Integration doc](/install-and-configure/install/cloud-integration/multi-cloud.md) for more details.

{% code overflow="wrap" %}
```sh
kubectl create secret generic federated-store -n kubecost --from-file=federated-store.yaml
```
{% endcode %}

{% code overflow="wrap" %}
```sh
kubectl create secret generic cloud-integration -n kubecost --from-file=cloud-integration.json
```
{% endcode %}

Finally, upgrade your existing Kubecost installation. This command will install Kubecost if it does not already exist.

{% hint style="warning" %}
If you are upgrading from an existing installation, make sure to append your existing `values.yaml` configurations to the ones described above.
{% endhint %}

```sh
helm upgrade --install "kubecost" \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost \
  -f aggregator.yaml
```

### Validating Aggregator pod is running successfully

When first enabled, the aggregator pod will ingest the last 90 days (if
applicable) of ETL data from the federated-store. Because the combined folder is
ignored, the legacy Federator pod is not used here, but can still run if needed.
As `ETL_DAILY_STORE_DURATION_DAYS` increases, the amount of time it will take
for Aggregator to make data available will increase. You can run `kubectl get
pods` and ensure the `aggregator` pod is running, but should still wait for all
data to be ingested.

## Troubleshooting Aggregator

### Resetting Aggregator StatefulSet data

When deploying the Aggregator as a StatefulSet, it is possible to perform a reset of the Aggregator data. The Aggregator itself doesn't store any data, and relies on object storage. As such, a reset involves removing that Aggregator's local storage, and allowing it to re-ingest data from the object store. The procedure is as follows:

1. Scale down the Aggregator StatefulSet to 0
2. When the Aggregator pod is gone, delete the `aggregator-db-storage-xxx-0` PVC
3. Scale the Aggregator StatefulSet back to 1. This will re-create the PVC, empty.
4. Wait for Kubecost to re-ingest data from the object store. This could take from several minutes to several hours, depending on your data size and retention settings.

### Aggregator not displaying any data to frontend after several hours

One reason you may not see data in the frontend yet is because the Aggregator is processing all your ETL files in the federated store bucket into SQL tables.

If you are seeing a lot of the following logs, it could be an indicator that your `.Values.kubecostAggregator.env.DB_BUCKET_REFRESH_INTERVAL` may be set too low, causing the Aggregator to continuously restart its data ingestion process:

```txt
INF asset worker context cancelled: context canceled
INF allocation worker context cancelled: context canceled
```

To fix, try continuously increasing the environment variable's value, until the errors no longer appear. We recommend starting with `1h`. More details about the environment variable described above.

```yaml
kubecostAggregator:
  env:
    DB_BUCKET_REFRESH_INTERVAL: 1h
```
