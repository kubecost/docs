# Migration Guide from Thanos to Kubecost 2.0 (Aggregator)

This tutorial is intended to help our users migrate from the legacy Thanos federation architecture to [Kubecost v2.0's Aggregator](aggregator.md). There are a few requirements in order to successfully migrate to Kubecost 2.0. This new version of Kubecost includes a new backend Aggregator which handles the ETL data built from source metrics more efficiently. Kubecost 2.0 provides new features, optimizes UI performance, and enhances the user experience. This tutorial is meant to be performed before the user upgrades from an older version of Kubecost to v2.0.

Important notes for the migration process:

* Once Aggregator is enabled, all queries hit the Aggregator container and *not* cost-model via the reverse proxy.
* The ETL-Utils container only creates additional files in the object store. It does not delete any data/metrics.
* For larger environments, the StorageClass must have 1GBPS throughput.
* Having enough storage is critically important and will vary based on environment. Bias towards a larger value for `aggregatorDBStorage.storageRequest` at the beginning and cut it down if persistent low utilization is observed.  

## Key changes

* Assets and Allocations are now paginated using `offset`/`limit` parameters
* New data available for querying every 2 hours (can be adjusted)
* Substantial query speed improvements even when pagination not in effect
* Data ingested into and queried from Aggregator component instead of directly from bingen files
* Idle (sharing), Cluster Management sharing, and Network are computed a priori
* Distributed tracing integrated into core workflows
* No more pre-computed "AggStores"; this reduces the memory footprint of Kubecost  
  * Request-level caching still in effect

## Aggregator architecture

![aggregator-diagram](/images/aggregator/aggregator-diagram.png)

## Migration process

To migrate from Thanos multi-cluster federated architecture to Aggregator, users *must* complete the following steps:

### Step 1: Use the existing Thanos object store or create a new dedicated object store

This object store will be where the ETL backups will be pushed to from the primary cluster's cost-model. If you are using a metric Federation tool which does not require an object store, or otherwise do not want to use an existing Thanos object store, you will have to create a new one.

If this is your first time setting up an object store, refer to these docs:

* [AWS](/install-and-configure/install/multi-cluster/long-term-storage-configuration/long-term-storage-aws.md)
* [Azure](/install-and-configure/install/multi-cluster/long-term-storage-configuration/long-term-storage-azure.md)
* [GCP](/install-and-configure/install/multi-cluster/long-term-storage-configuration/long-term-storage-gcp.md)

### Step 2: Enable ETL backups on the *primary cluster only*

Enabling [ETL backups](/install-and-configure/install/etl-backup/etl-backup.md) ensures Kubecost persists historical data in durable storage (outside of Thanos) and stores the data in a format consumable by the ETL Utils container. The ETL Utils container transforms that data and writes it to a separate location in the object store for consumption by Aggregator.

```yaml
kubecostModel:
  etlBucketConfigSecret: <YOUR_SECRET_NAME>
```

### Step 3: Validate that an `/etl` directory is present in the object store

There should be ETL data present in the following directories. CloudCosts will only have ETL data if at least one cloud integration is enabled.

* `/etl/bingen/allocations`
* `/etl/bingen/assets/`
* `/cloudcosts/`

### Step 4: Create a new federated-store secret on the primary cluster

This will point to the existing Thanos object store or the new object store created in Step 1. The secret should be identical to your `object-store.yaml`, with the exception that this new secret *must* be named `federated-store.yaml`.

{% hint style="warning" %}
The name of the .yaml file used to create the secret *must* be named *federated-store.yaml* or Aggregator will not start.
{% endhint %}

```sh
kubectl create secret generic federated-store --from-file=federated-store.yaml -n kubecost
```

### Step 5: Set Aggregator and ETL Utils in *values.yaml* on the primary cluster

{% hint style="warning" %}
*Do not* disable Thanos during this step. This will not negatively impact the source data. Thanos will be disabled in a later step.
{% endhint %}

* [Enable Aggregator](https://docs.kubecost.com/install-and-configure/install/multi-cluster/federated-etl/aggregator) for the primary cluster. Your ETL Utils configuration should look like:

```yaml
etlUtils:
  enabled: true
  thanosSourceBucketSecret: kubecost-thanos
  fullImageName: gcr.io/kubecost1/cost-model-etl-utils:0.2
  resources: {}
kubecostModel:
  federatedStorageConfigSecret: federated-store
```

### Step 6: Apply the changes and wait for data to populate in the UI

Ensure all pods and containers are running:

```txt
kubecost-cost-analyzer-685fd8f677-k652h        4/4     Running   2 (12m ago)   3h2m
kubecost-forecasting-6cf4dd7b98-7z8f5          1/1     Running   0             66m
kubecost-etl-utils-6cdd489596-5dl75           1/1     Running   0          6d20h
```

This can take some time depending on how many unique containers are running in the environment and how much ETL data is in the object store. A couple importants steps are happening in the background which take time to complete.

* The ETL Utils image is building the directory structure in the object store needed by Aggregator to pull the ETL data. 
* SQL tables are building.

Ensure all data loads into the Kubecost UI before moving onto Step 7.

### Step 7: Upgrade your secondary clusters to build and push ETL data

Using the same *federated-store.yaml* created in Step 4, create this secret and add it to the *values.yaml* file for all secondary clusters.

```sh
kubectl create secret generic federated-store --from-file=federated-store.yaml -n kubecost
```

```yaml
federatedETL:
  federatedCluster: true
kubecostModel:
  containerStatsEnabled: true
  federatedStorageConfigSecret: federated-store
  etl: true
  warmCache: false
  warmSavingsCache: false
```

Optionally, you can remove the [Thanos sidecar](https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/v1.108.1/cost-analyzer/values-thanos.yaml) running on this secondary cluster. If left on, this secondary cluster will continue to push Prometheus metrics to the object store which can be used as a backup.

### Step 8: Remove Thanos configuration from the primary cluster

* Remove the [Thanos manifest](https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/v1.108.1/cost-analyzer/values-thanos.yaml)

* Remove Thanos values in the *values.yaml*

## Troubeshooting

* Check the Aggregator container logs for query failures or SQL table failures.
