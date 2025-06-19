# Migration Guide from Thanos to Kubecost v2 (Aggregator)

This tutorial is intended to help our users migrate from the legacy Thanos federation architecture to [Kubecost v2's Aggregator](aggregator.md). There are a few requirements in order to successfully migrate to Kubecost v2. This new version of Kubecost includes a new backend Aggregator which handles the ETL data built from source metrics more efficiently. Kubecost v2 provides new features, optimizes UI performance, and enhances the user experience. This tutorial is meant to be performed before the user upgrades from an older version of Kubecost to v2.

Important notes for the migration process:

* Once Aggregator is enabled, all queries hit the Aggregator container and *not* cost-model via the reverse proxy.
* The ETL-Utils container only creates additional files in the object store. It does not delete any data/metrics.
* For larger environments, the StorageClass must have 1 GBPS throughput.
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

![Aggregator diagram](/images/diagrams/aggregator-diagrams.png)

## Migration process

All of these steps should be performed prior to upgrading to Kubecost 2.0+. The goal of this doc is to gradually migrate off Thanos, which is no longer supported in the Kubecost v2 Helm chart. If you want to continue running Thanos, the Helm chart must be installed from a third party prior to executing the upgrade.

### Step 1: Use the existing Thanos object store or create a new dedicated object store

If you have an existing object store where you are storing Thanos data, you have the option to use the same object store for the new Federated ETL data, or you can create a new object store for the new Federated ETL data for Kubecost v2

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

### Step 3: If data older than 90 days is required, perform this step. If 90 days worth of historical data meets the requirement, skip to step 4.

`maxSourceResolution` MUST be set to 1d and `etlDailyStoreDurationDays` must be set to the number of days of historical data needed. Below is an example of what needs to be set on the primary to get 365 days of daily ETL data.

**Important Note**: Setting the following configuration will increase RAM utilization significantly on the cost-model container. It is recommended to use a dedicated node group/node for this process.

```yaml
kubecostModel:
  maxQueryConcurrency: 5 # lower if memory is a concern
  maxSourceResolution: 1d
  etlBucketConfigSecret: kubecost-thanos
  etlDailyStoreDurationDays: 365
```

Validate this process completed by confirming the object store has ~365 worth of non-empty ETL files in the `/etl` directory that was created in step 2. Empty file sizes are 86B. The name of the etl files are the epoch timestamps for the ETLs. Use the [Epoch Time Converter](https://www.epochconverter.com/) to validate data goes back a year.

After confirming data older than 90 days is available, revert the changes above to reduce RAM consumption. 

### Step 4: Validate that an `/etl` directory is present in the object store

There should be ETL data present in the following directories. CloudCosts will only have ETL data if at least one cloud integration is enabled.

* `/etl/bingen/allocations`
* `/etl/bingen/assets/`
* `/cloudcosts/`

### Step 5: Create a new federated-store secret on the primary cluster

This will point to the existing Thanos object store or the new object store created in Step 1. The secret should be identical to your *object-store.yaml*, with the exception that this new secret *must* be named *federated-store.yaml*.

The name of the .yaml file used to create the secret *must* be named *federated-store.yaml* or Aggregator will not start.

```sh
kubectl create secret generic federated-store --from-file=federated-store.yaml -n kubecost
```

### Step 6: Enable FederatedETL, ETL-Utils, and Aggregator on the primary cluster

Enabling FederatedETL will begin pushing your primary cluster's ETL data to the directory `/federated/CLUSTER_ID`. This setting will be enabled when upgrading to v2.

Enabling ETL-Utils will create the directories `/federated/CLUSTER_ID` for every primary/secondary cluster based on the full set of data in the `/etl` directory.

Enabling [Aggregator](/install-and-configure/install/multi-cluster/federated-etl/aggregator.md) will begin processing the ETL data from the `/federated` directory. The aggregator will then serve all Kubecost queries. Be sure to look at the [Aggregator Optimizations Doc](/install-and-configure/install/multi-cluster/federated-etl/aggregator.md) if Kubecost is ingesting data for ~20,000+ containers. It is difficult to recommend the amount of resources needed due to the uniqueness of each environment and several other variables.

The `federatedStorageConfigSecret`, `etlBucketConfigSecret`, and `thanosSourceBucketSecret` *MUST* all point to the same bucket. Otherwise the data migration will not succeed. Additionally, the cloud-integration *MUST* be configured and referenced following [this method](/install-and-configure/install/cloud-integration/multi-cloud.md#step-2-create-cloud-integration-secret) or the cloud integration will fail.

```yaml
kubecostProductConfigs:
  cloudIntegrationSecret: cloud-integration
kubecostModel:
  federatedStorageConfigSecret: federated-store
  etlBucketConfigSecret: <YOUR_SECRET_NAME>
etlUtils:
  enabled: true
  thanosSourceBucketSecret: kubecost-thanos
  resources: {}
  env:
    # "debug" is not all that verbose and is recommended
    LOG_LEVEL: debug
    # How many days worth of ETL files to translate from `/etl` to `/federated`
    ETL_DAILY_STORE_DURATION_DAYS: 365
kubecostAggregator:
  deployMethod: statefulset
  replicas: 1
```

### Step 7: Apply the changes and wait for data to populate in the UI of the primary cluster

Ensure all pods and containers are running:

```txt
kubecost-cost-analyzer-685fd8f677-k652h        4/4     Running   0          3h2m
kubecost-etl-utils-6cdd489596-5dl75            1/1     Running   0          6d20h
```

This step can take some time depending on how much data the Aggregator must process. A couple important steps are happening in the background:

* The ETL Utils image is building the directory structure in the object store needed by Aggregator to pull the ETL data.
* SQL tables are building.

Ensure all data loads into the Kubecost UI before moving onto Step 8.

### Step 8: Upgrade your secondary clusters to build and push ETL data

For this step, the secondary clusters **don't** need to be upgraded to v2. However, you must be running a version of Kubecost that supports Federated ETL (greater than v1.99.0).

If you are not on a Federated ETL supported version, please upgrade to a supported version on your secondaries before completing this step.  We recommend v2 or v1.108.1, (see the command to upgrade to a specific version of Kubecost above).

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

### Step 9: Upgrade primary cluster to v2

You can now upgrade the primary Kubecost cluster to v2 using your standard upgrade process. If upgrading via Helm, your upgrade command will look like:

```sh
helm upgrade kubecost kubecost --repo https://kubecost.github.io/cost-analyzer/ \
  --namespace kubecost \
  -f values.yaml
```

### Step 10 (optional): Upgrade secondary clusters to Kubecost 2.0+

{% hint style="info" %}
While not absolutely necessary to upgrade secondary clusters to 2.0+ immediately, we recommend doing so as soon as possible.
{% endhint %}

You can upgrade the Secondary Kubecost clusters to Kubecost 2.0+ using your standard upgrade process. Prior to upgrading set value below in your values.yaml if using helm.

```yaml
federatedETL:
  agentOnly: true
```

If upgrading via Helm, your upgrade command will look like:

```sh
helm upgrade kubecost kubecost --repo https://kubecost.github.io/cost-analyzer/ \
  --namespace kubecost \
  -f values.yaml
```

## Troubleshooting

To help diagnose problems with Aggregator, check the Aggregator container logs for query failures or SQL table failures. If you have additional questions, contact Kubecost support at [support@kubecost.com](mailto:support@kubecost.com).

See additional troubleshooting procedures below.

### ETL Utils OutOfMemory error

If you see an `OutOfMemory` error on the ETL Utils Deployment, try adjusting the following configurations:

```yaml
etlUtils:
  resources:
    # Ensure ETLUtils has enough resources available on the node. It will need
    # to process all files in the `/etl` directory of your bucket.
    requests:
      memory: 10Gi
  # Use the most recent version of the Kubecost image. For example:
  # "gcr.io/kubecost1/cost-model:prod-2.3.0"
  fullImageName: gcr.io/kubecost1/cost-model:prod-x.x.x
  env:
    LOG_LEVEL: debug
    # Set to 1 to use less memory. Default is 2.
    ETL_UTIL_THREADS: 1
```
