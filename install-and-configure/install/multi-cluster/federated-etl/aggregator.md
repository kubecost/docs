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

* Multi-cluster Aggregator can only be configured in a federated ETL environment
* This documentation is for Kubecost v2.0 and higher.
* To upgrade from a Thanos multi-cluster environment to Aggregator, see our [transition doc](/install-and-configure/install/multi-cluster/federated-etl/thanos-migration-guide.md).

### Tutorial

Select from one of the two templates below and save the content as _federated-store.yaml_. This will be your configuration template required to set up Aggregator.

{% hint style="warning" %}
The name of the .yaml file used to create the secret must be named _federated-store.yaml_ or Aggregator will not start.
{% endhint %}

Basic configuration:

```
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

Advanced configuration (for larger deployments):

```
kubecostAggregator:
  replicas: 1
  deployMethod: statefulset
  cloudCost:
    enabled: true
  env:
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
federatedETL:
  federatedCluster: true
kubecostModel:
  containerStatsEnabled: true
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

There is no baseline for what is considered a larger deployment, which will be dependent on load times in your Kubecost environment.

Once you’ve configured your _federated-store_.yaml_, create a secret using the following command:

{% code overflow="wrap" %}
```
kubectl create secret generic federated-storage -n kubecost --from-file=federated-store.yaml
```
{% endcode %}

Next, you will need to create an additional `cloud-integration` secret. Follow this tutorial on [creating cloud integration secrets](../../cloud-integration/multi-cloud.md#step-2-create-cloud-integration-secret) to generate your _cloud-integration.json_ file, then run the following command:

{% code overflow="wrap" %}
```
kubectl create secret generic cloud-integration -n kubecost --from-file=cloud-integration.json
```
{% endcode %}

Finally, upgrade your existing Kubecost installation. This command will install Kubecost if it does not already exist:

{% hint style="warning" %}
Upgrading your existing Kubecost using your configured _federated-store_.yaml_ file above will reset all existing Helm values configured in your _values.yaml_. If you wish to preserve any of those changes, append your _values.yaml_ by adding the contents of your _federated-store.yaml_ file into it, then replacing `federated-store.yaml` with `values.yaml` in the upgrade command below:
{% endhint %}

```
helm upgrade --install "kubecost-primary" \
--namespace kubecost-primary \
--repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
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
