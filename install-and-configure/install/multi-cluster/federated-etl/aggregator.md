# Kubecost Aggregator

{% hint style="info" %}
Kubecost Aggregator is a beta feature.
{% endhint %}

Aggregator is a new, experimental backend for Kubecost. It is used in a [Federated ETL](/install-and-configure/install/multi-cluster/federated-etl/federated-etl.md) configuration without Thanos, replacing the [Federator](/install-and-configure/install/multi-cluster/federated-etl/federated-etl.md#other-components) component.
Aggregator serves a critical subset of Kubecost APIs, but will eventually be the default model for Kubecost and serve all APIs. Currently, Aggregator supports all major monitoring and savings APIs, and also budgets and reporting.

{% hint style="info" %}
Existing documentation for Kubecost APIs will use endpoints for non-Aggregator environments unless otherwise specified, but will still be compatible after configuring Aggregator.
{% endhint %}

Aggregator is designed to accommodate queries of large-scale datasets, including reduced load times and potential errors in the UI. It is not designed to introduce new functionality; it is meant to improve functionality at scale.

Aggregator is free for all users to configure, and is always able to be rolled back.

## Configuring Aggregator

### Prerequisites

* Aggregator can only be configured in a Federated ETL environment
* Must be using v1.107.0 of Kubecost or newer
* Your *values.yaml* file must have set `kubecostDeployment.queryServiceReplicas` to its default value `0`. 

### Tutorial

Select from one of the two templates below and save the content as *aggregator.yaml*. This will be your configuration template required to set up Aggregator.

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
    # disk space for WAL storage
    # default: 6
    NUM_DERIVER_THREADS: 6
    # log level
    # default: info
    LOG_LEVEL: debug
  aggregatorDbStorage:
    # governs storage size of aggregator DB storage
    # !!NOTE!! disk performance is _critically important_ to aggregator performance
    # ensure disk is specd high enough, and check for bottlenecks
    # default: 128Gi
    storageRequest: 128Gi
  # tracing, starts embedded jaeger pod
  # port forward to 16686 on the pod to access jaeger UI 
  # provides instrumented traces used for troubleshooting performance issues
  jaeger:
    enabled: true
    image: jaegertracing/all-in-one
    imageVersion: latest
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

Once you’ve configured your *aggregator.yaml*, create secrets using the following commands:

{% code overflow="wrap" %}
```
kubectl create secret generic cloud-integration -n kubecost --from-file=aggregator.yaml
```
{% endcode %}

{% code overflow="wrap" %}
```
kubectl create secret generic federated-storage -n kubecost --from-file=aggregator.yaml
```
{% endcode %}

Finally, upgrade your existing Kubecost installation. This command will install Kubecost if it does not already exist:

{% hint style="warning" %}
Upgrading your existing Kubecost using your configured *aggregator.yaml* file above will reset all existing Helm values configured in your *values.yaml*. If you wish to preserve any of those changes, append your *values.yaml* by adding the contents of your *aggregator.yaml* file into it, then replacing `aggregator.yaml` with `values.yaml` in the upgrade command below:
{% endhint %}

```
helm upgrade --install "kubecost-primary" \
--namespace kubecost-primary \
--repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
-f aggregator.yaml
```

### Validating Aggregator pod is running successfully

When first enabled, the aggregator pod will ingest the last 90 days of ETL data from the federated-store. This may take several hours. Because the combined folder is ignored, the federator pod is not used here, but can still run if needed. You can run `kubectl get pods` and ensure the `aggregator` pod is running, but should still wait for all data to be ingested.
