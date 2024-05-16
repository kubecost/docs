# Migration Guide from Thanos to Kubecost 2.0 (Aggregator)

This tutorial is intended to help our users migrate from the legacy Thanos federation architecture to [Kubecost v2.0's Aggregator](aggregator.md). There are a few requirements in order to successfully migrate to Kubecost v2.0. This new version of Kubecost includes a new backend Aggregator which handles the ETL data built from source metrics more efficiently. Kubecost v2.0 provides new features, optimizes UI performance, and enhances the user experience. This tutorial is meant to be performed before the user upgrades from an older version of Kubecost to v2.0.

Important notes for the migration process:

* For best experience, please upgrade to Kubecost v1.108.1 before following this document.
* Once Aggregator is enabled, all queries hit the Aggregator container and *not* cost-model via the reverse proxy.
* The ETL-Utils container only creates additional files in the object store. It does not delete any data/metrics.
* For larger environments, the StorageClass must have 1GBPS throughput.
* Having enough storage is critically important and will vary based on environment. Bias towards a larger value for `aggregatorDBStorage.storageRequest` at the beginning and cut it down if persistent low utilization is observed.

## Key changes

* Assets and Allocations are now paginated using `offset`/`limit` parameters
* New data available for querying every 2 hours (can be adjusted)
* Substantial query speed improvements even when pagination not in effect
* Data ingested into and queried from Aggregator component instead of directly from bingen files
* Distributed tracing integrated into core workflows
* No more pre-computed "AggStores"; this reduces the memory footprint of Kubecost
  * Request-level caching still in effect

## Aggregator architecture

![Aggregator diagram](/images/aggregator/aggregator-diagrams.png)

## Migration process

All of these steps should be performed on Kubecost v1.108.1 on the primary Kubecost cluster. Only after completing the steps in this guide should you upgrade all Kubecost clusters to v2.0. The goal of this doc is to gradually migrate off Thanos, which is no longer supported in the Kubecost v2.0+ Helm chart, towards Federated ETL, then finally Aggregator.

Please upgrade your primary cluster to v1.108.1 before completing any of the following steps. v1.108.1 ships with various utilities necessary to complete the upgrade to v2.0. You can upgrade to this specific version using this following command:

```sh
helm upgrade --install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost \
  --version 1.108.1
```

### Step 1: Use the existing Thanos object store or create a new dedicated object store

If you have an existing object store where you are storing Thanos data, you have the option to use the same object store for the new Federated ETL data, or you can create a new object store for the new Federated ETL data for Kubecost v2.0

The object store in question will be where the ETL backups are pushed to from the primary cluster's cost-model. If you are using a metric Federation tool which does not require an object store (such as AMP, GMP, etc.), or otherwise do not want to use an existing Thanos object store, you will have to create a new one.

If this is your first time setting up an object store, refer to these docs:

* [AWS](/install-and-configure/install/multi-cluster/long-term-storage-configuration/long-term-storage-aws.md)
* [Azure](/install-and-configure/install/multi-cluster/long-term-storage-configuration/long-term-storage-azure.md)
* [GCP](/install-and-configure/install/multi-cluster/long-term-storage-configuration/long-term-storage-gcp.md)

### Step 2: Enable ETL backups on the *primary cluster only*

Enabling [ETL backups](https://docs.kubecost.com/v/1.0x/install-and-configure/install/etl-backup) ensures Kubecost persists historical data in durable storage (outside of Thanos) and stores the data in a format consumable by the ETL Utils container. The ETL Utils container transforms that data and writes it to a separate location in the object store for consumption by Aggregator.

```yaml
kubecostModel:
  etlBucketConfigSecret: <YOUR_SECRET_NAME>
```

Once configured, you will see the ETL backup data begin to populate in the Thanos object store. See step below.

### Step 3: Validate that an `/etl` directory is present in the object store

There should be ETL data present in the following directories. CloudCosts will only have ETL data if at least one cloud integration is enabled.

* `/etl/bingen/allocations`
* `/etl/bingen/assets/`
* `/cloudcosts/`

### Step 4: Create a new federated-store secret on the primary cluster

This will point to the existing Thanos object store or the new object store created in Step 1. The secret should be identical to your *object-store.yaml*, with the exception that this new secret *must* be named *federated-store.yaml*.

{% hint style="warning" %}
The name of the .yaml file used to create the secret *must* be named *federated-store.yaml* or Aggregator will not start.
{% endhint %}

```sh
kubectl create secret generic federated-store --from-file=federated-store.yaml -n kubecost
```

### Step 5: Enable FederatedETL, ETL-Utils, and Aggregator on the primary cluster

{% hint style="warning" %}
*Do not* disable Thanos during this step. Thanos will be disabled in a later step.
{% endhint %}

Enabling FederatedETL will begin pushing your primary cluster's ETL data to the directory `/federated/CLUSTER_ID`. This setting will remain on once disabling Thanos at a later step.

Enabling ETL-Utils will create the directories `/federated/CLUSTER_ID` for every primary/secondary cluster based on the full set of data in the `/etl` directory.

Enabling [Aggregator](/install-and-configure/install/multi-cluster/federated-etl/aggregator.md) will begin processing the ETL data from the `/federated` directory. The aggregator will then serve all Kubecost queries.

{% hint style="warning" %}
The `federatedStorageConfigSecret`, `etlBucketConfigSecret`, and `thanosSourceBucketSecret` *MUST* all point to the same bucket. Otherwise the data migration will not suceed.
{% endhint %}

```yaml
kubecostModel:
  federatedStorageConfigSecret: federated-store
  etlBucketConfigSecret: <YOUR_SECRET_NAME>
etlUtils:
  enabled: true
  thanosSourceBucketSecret: kubecost-thanos
  resources: {}
  env:
    LOG_LEVEL: debug # debug isn't all that verbose and is recommended
kubecostAggregator:
  enabled: true
  replicas: 1
  extraEnv:
    - name: DB_BUCKET_REFRESH_INTERVAL
      value: 2h
```

### Step 6: Apply the changes and wait for data to populate in the UI of the primary cluster

Ensure all pods and containers are running:

```txt
kubecost-cost-analyzer-685fd8f677-k652h        4/4     Running   0          3h2m
kubecost-etl-utils-6cdd489596-5dl75            1/1     Running   0          6d20h
```

This step can take some time depending on how much data the Aggregator must process. A couple importants steps are happening in the background:

* The ETL Utils image is building the directory structure in the object store needed by Aggregator to pull the ETL data.
* SQL tables are building.

Ensure all data loads into the Kubecost UI before moving onto Step 7.

### Step 7: Upgrade your secondary clusters to build and push ETL data

For this step, the secondary clusters **don't** need to be upgraded to v2.0. However, you must be running a version of Kubecost that supports Federated ETL (greater than v1.99.0).

If you are not on a Federated ETL supported version, please upgrade to a supported version on your secondaries before completing this step.  We recommend v1.106.x, 1.107.x or 1.108.1 (see the command to upgrade to a specific version of Kubecost above).

Using the same *federated-store.yaml* created in Step 4, create this secret and add it to the *values.yaml* file for all secondary clusters:

```sh
kubectl create secret generic federated-store --from-file=federated-store.yaml -n kubecost
```

```yaml
federatedETL:
  federatedCluster: true
kubecostModel:
  federatedStorageConfigSecret: federated-store
  etlBucketConfigSecret: "" # make sure ETL backups are disabled on secondary clusters
  etl: true
  containerStatsEnabled: true
  warmCache: false
  warmSavingsCache: false
```

Optionally, you can remove the [Thanos sidecar](https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/v1.108.1/cost-analyzer/values-thanos.yaml) running on this secondary cluster. If left on, this secondary cluster will continue to push Prometheus metrics to the object store which can be used as a backup.

### Step 8: Remove Thanos configuration from the primary cluster

Remove [Thanos configurations](https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/v1.108.1/cost-analyzer/values-thanos.yaml) from your primary cluster since it is no longer included in the Helm chart in 2.0. Your Kubecost installation is now configured to query the Aggregator for multi-cluster data, instead of Thanos.

### Step 9: Upgrade primary cluster to v2.0

You can now upgrade the primary Kubecost cluster to v2.0 using your standard upgrade process. If upgrading via Helm, your upgrade command will look like:

```sh
helm upgrade kubecost cost-analyzer --repo https://kubecost.github.io/cost-analyzer/ \
  --namespace kubecost \
  -f values.yaml
```

### Step 10 (optional): Upgrade secondary clusters to Kubecost 2.0

{% hint style="info" %}
While not absolutely necessary to upgrade secondary clusters to 2.0 immediately, we recommend doing so as soon as possible.
{% endhint %}

You can upgrade the Secondary Kubecost clusters to Kubecost 2.0 using your standard upgrade process. Prior to upgrading set value below in your values.yaml if using helm.

```yaml
federatedETL:
  agentOnly: true
```

If upgrading via Helm, your upgrade command will look like:

```sh
helm upgrade kubecost cost-analyzer --repo https://kubecost.github.io/cost-analyzer/ \
  --namespace kubecost \
  -f values.yaml
```

## Troubeshooting

To help diagnose problems with Aggregator, check the Aggregator container logs for query failures or SQL table failures. If you have additional questions, contact Kubecost support at [support@kubecost.com](mailto:support@kubecost.com).
