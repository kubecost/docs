# Kubecost Aggregator

Aggregator is a new backend for Kubecost. It is used in a [Federated ETL](federated-etl.md) configuration without Thanos, replacing the [Federator](federated-etl.md#other-components) component. Aggregator serves a critical subset of Kubecost APIs, but will eventually be the default model for Kubecost and serve all APIs. Currently, Aggregator supports all major monitoring and savings APIs, and also budgets and reporting.

{% hint style="info" %}
Existing documentation for Kubecost APIs will use endpoints for non-Aggregator environments unless otherwise specified, but will still be compatible after configuring Aggregator.
{% endhint %}

Aggregator is designed to accommodate queries of large-scale datasets by improving API load times and reducing UI errors. It is not designed to introduce new functionality; it is meant to improve functionality at scale.

Aggregator is currently free for all Enterprise users to configure, and is always able to be rolled back.

## Configuring Aggregator

### Prerequisites

* Aggregator can only be configured in a Federated ETL environment
* Must be using v1.107.0 of Kubecost or newer
* Your _values.yaml_ file must have set `kubecostDeployment.queryServiceReplicas` to its default value `0`.
* You must have your context set to your primary cluster. Kubecost Aggregator cannot be deployed on secondary clusters.

### Tutorial

Select from one of the two templates below and save the content as _aggregator.yaml_. This will be your configuration template required to set up Aggregator.

Basic configuration:

```
kubecostAggregator:
  replicas: 1
  enabled: true
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
  enabled: true
  cloudCost:
    enabled: true
  env:
    # governs parallelism of derivation step
    # more threads speeds derivation, but requires significantly more 
    # log level
    # default: info
    LOG_LEVEL: info
  aggregatorDbStorage:
    # governs storage size of aggregator DB storage
    # !!NOTE!! disk performance is _critically important_ to aggregator performance
    # ensure disk is specd high enough, and check for bottlenecks
    # default: 128Gi
    storageRequest: 128Gi
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

Once you’ve configured your _aggregator.yaml_, create a secret using the following command:

{% code overflow="wrap" %}
```
kubectl create secret generic federated-storage -n kubecost --from-file=aggregator.yaml
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
Upgrading your existing Kubecost using your configured _aggregator.yaml_ file above will reset all existing Helm values configured in your _values.yaml_. If you wish to preserve any of those changes, append your _values.yaml_ by adding the contents of your _aggregator.yaml_ file into it, then replacing `aggregator.yaml` with `values.yaml` in the upgrade command below:
{% endhint %}

```
helm upgrade --install "kubecost-primary" \
--namespace kubecost-primary \
--repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
-f aggregator.yaml
```

### Validating Aggregator pod is running successfully

When first enabled, the aggregator pod will ingest the last three years (if applicable) of ETL data from the federated-store. This may take several hours. Because the combined folder is ignored, the federator pod is not used here, but can still run if needed. You can run `kubectl get pods` and ensure the `aggregator` pod is running, but should still wait for all data to be ingested.
