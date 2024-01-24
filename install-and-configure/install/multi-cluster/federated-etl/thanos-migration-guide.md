# Migration Guide from Thanos to Kubecost 2.0 (Aggregator)

This tutorial is intended to help our users migrate from the legacy Thanos federation architecture to [Kubecost 2.0 (Aggregator)](aggregator.md). There are a few requirements in order to successfully migrate to Kubecost 2.0. This new version of Kubecost includes a new backend Aggregator which handles the ETL data built from source metrics more efficiently. Kubecost 2.0 will provide new features, optimize the Kubecost's UI performance, and enhance the user experience.

## Key changes

* Assets and Allocations are now paginated
   * Frontend/API users never have full set of information
   * Use `offset`/`limit` parameters to govern pagination
* New data available for querying every 2 hours (can be adjusted)
* Embedded DuckDB database serves queries
   * Data no longer queried directly from bingen files
   * Substantial query speed improvements even when pagination not in effect
* Data ingested into independent Aggregator component
* Idle (sharing), Cluster Management sharing, and Network are computed a priori
* Distributed tracing integrated into core workflows
* No more pre-computed "agg stores"
   * Request-level caching still in effect

<details>

<summary>Diagram of Aggregator:</summary>

![aggregator-diagram](/images/aggregator/aggregator-diagram.png)

</details>

## Migration path 

<details>

<summary>Diagram of Aggregator:</summary>

![migration-diagram](/images/aggregator/migration-diagram.png)

</details>

* All steps are done on the primary cluster except for step 8.
* Nothing needs to be done on the secondary clusters for the migration to be successful. The Thanos sidecar on the secondary clusters will have no impact on the migration or functionality.
* Once Aggregator is enabled, all queries hit the Aggregator container and NOT cost-model via the reverse proxy.
* ETL Utils does not destroy the Thanos data, it creates additional directories in the object store.
* For larger environments, the StorageClass must have 1GBPS throughput.
* Having enough storage is important and will vary based on environment.

## Prerequisites

To migrate from Thanos multi-cluster federated architecture to Aggregator, users *must* complete the following steps:

### Step 1: Use the existing Thanos object store or create a new dedicated object store

This object store is where the ETL backups will be pushed to from the primary cluster.

### Step 2: Enable [ETL Backups](https://docs.kubecost.com/install-and-configure/install/etl-backup#google-cloud-storage) on the *primary cluster only*. 

This will ensure we have all historical data in durable storage and it will create the directory the ETL Utils container needs in order to create the directory structure needed for Aggregator to pull the ETL from each respective cluster.

```
kubecostModel:
  etlBucketConfigSecret: <YOUR_SECRET_NAME>
```

### Step 3: Validate that an `/etl` directory is present in the object store

There should be ETL data present in the following directories. CloudCosts will only have ETL data if cloud integration is enabled.

* `/etl/bingen/allocations`
* `/etl/bingen/assets/`
* `/cloudcosts/`


### Step 4: Create a new secret for the federated store

This will point to the existing Thanos object store or the new one created in Step 1.

{% hint style="warning" %}
The name of the .yaml file used to create the secret *must* be named _federated-store.yaml_ or Aggregator will not start.
{% endhint %}


```
kubectl create secret generic federated-store --from-file=federated-store.yaml -n kubecost
```

### Step 5: Set Aggregator and ETL Utils in *values.yaml* on the primary cluster.

{% hint style="warning" %}
*Do not* disable Thanos during this step. This will not negatively impact the source data. Thanos will be disabled in a later step.
{% endhint %}

* [Enable Aggregator for the primary cluster](https://docs.kubecost.com/install-and-configure/install/multi-cluster/federated-etl/aggregator). 

Note:  

* ETL Utils
```
etlUtils:
  thanosSourceBucketSecret: kubecost-thanos
  affinity: {}
  enabled: true
  env:
    LOG_LEVEL: debug
  fullImageName: gcr.io/kubecost1/cost-model-etl-utils:0.2
  nodeSelector:
    kubernetes.io/arch: amd64
  resources: {}
  tolerations: {}
kubecostModel:
  federatedStorageConfigSecret: kubecost-thanos
```

### Step 6: Apply the changes and wait for data to populate in the UI. 

Ensure all pods and containers are running:

 ```
kubecost-cost-analyzer-685fd8f677-k652h        4/4     Running   2 (12m ago)   3h2m
kubecost-forecasting-6cf4dd7b98-7z8f5          1/1     Running   0             66m
kubecost-etl-utils-6cdd489596-5dl75           1/1     Running   0          6d20h
```

This can take some time depending on how many unique containers are running in the environment and how much ETL data is in the object store. A couple importants steps are happening in the background which take time to complete.

* The ETL Utils image is building the directory structure in the object store needed by Aggregator to pull the ETL data. 
* SQL tables are building.

Ensure all data loads into the UI before moving onto Step 7.

### Step 7: Remove Thanos sidecar from secondary clusters

* Use the same federated-store secret created in Step 4 and add the following to the _values.yaml_ for the secondary clusters:

```
federatedETL:
  useExistingS3Config: false
  primaryCluster: false
  federatedCluster: true
kubecostModel:
  containerStatsEnabled: true
  federatedStorageConfigSecret: federated-store
  warmCache: false
  warmSavingsCache: false
```

* Remove the [Thanos manifest](https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/v1.108.1/cost-analyzer/values-thanos.yaml)


### Step 8: Remove Thanos configuration from the primary cluster

* Remove the [Thanos manifest](https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/v1.108.1/cost-analyzer/values-thanos.yaml)

* Remove Thanos values in the values.yaml

## Troubeshooting

* Check the Aggregator container logs for query failures or SQL table failures.
