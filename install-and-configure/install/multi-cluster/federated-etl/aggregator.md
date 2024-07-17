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
* If you've enabled Cloud Integration, it _must_ be configured via the cloud integration secret. Other methods are now deprecated. See our [Multi-Cloud Integrations](/install-and-configure/install/cloud-integration/multi-cloud.md) doc for more details.
* This documentation is for Kubecost v2.0 and higher.

If you are upgrading to Kubecost v2.0 from the following environments, see our specialized migration guides instead:

* [Federated ETL](/install-and-configure/install/multi-cluster/federated-etl/federated-etl-migration-guide.md)
* [Thanos](/install-and-configure/install/multi-cluster/federated-etl/thanos-migration-guide.md)

### Basic configuration

{% hint style="info" %}
This configuration is estimated to be sufficient for environments monitoring < 20k unique containers or $50k cloud spend per day. You can check this metric on the `/diagnostics` page.
{% endhint %}

```yaml
kubecostAggregator:
  deployMethod: statefulset
  cloudCost:
    enabled: true
federatedETL:
  federatedCluster: true
kubecostModel:
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
```

### Aggregator Optimizations

For larger deployments of Kubecost, Aggregator can be tuned. The settings below are in addition to the basic configuration above.

{% hint style="info" %}
This configuration is estimated to be sufficient for environments monitoring < 60k unique containers per day. You can check this metric on the `/diagnostics` page.
{% endhint %}

{% hint style="warning" %}
Aggregator is a memory and disk-intensive process. Ensure that your cluster has enough resources to support the configuration below.

Because the Aggregator PV is relatively small, the least expensive performance gain will be to move the storage class to a faster SSD. The storageClass name varies by provider, the terms used are gp3/extreme/premium/etc.
{% endhint %}

```yaml
kubecostAggregator:
  logLevel: info

  # How much data to ingest from the federated store bucket, and how much data
  # to keep in the DB before rolling the data off.
  # 
  # Note: If increasing this value to backfill historical data, it will take
  # time to gradually ingest & process those historical ETL files. Consider
  # also increasing the resources available to the aggregator as well as the
  # dbConcurrentIngestionCount.
  # 
  # default: 91
  etlDailyStoreDurationDays: 91

  # How many threads the read database is configured with (i.e. Kubecost API /
  # UI queries). If increasing this value, it is recommended to increase the
  # aggregator's memory requests & limits.
  # default: 1
  dbReadThreads: 1

  # How many threads the write database is configured with (i.e. ingestion of
  # new data from S3). If increasing this value, it is recommended to increase
  # the aggregator's memory requests & limits.
  # default: 1
  dbWriteThreads: 1

  # How many threads to use when ingesting Asset/Allocation/CloudCost data
  # from the federated store bucket. In most cases the default is sufficient,
  # but can be increased if trying to backfill historical data.
  # default: 1
  dbConcurrentIngestionCount: 1

  # Memory limit applied to read database and write database connections. The
  # default of "no limit" is appropriate when first establishing a baseline of
  # resource usage required. It is eventually recommended to set these values
  # such that dbMemoryLimit + dbWriteMemoryLimit < the total memory available
  # to the aggregator pod.
  # default: 0GB is no limit
  dbMemoryLimit: 0GB
  dbWriteMemoryLimit: 0GB

  # If "true" can improve the time it takes to copy the write DB, at the expense
  # of additional memory usage.
  # default: "false"
  dbCopyFull: "false"

  # The number of partitions the datastore is split into for copying. The higher
  # this number, the lower the RAM usage but the longer it takes for new data to
  # show in the Kubecost UI.
  # default: 1
  numDBCopyPartitions: 1

  # stagingEmptyDirSizeLimit changes how large the "staging"
  # /var/configs/waterfowl emptyDir is. It only takes effect in StatefulSet
  # configurations of Aggregator, other configurations are unaffected.
  #
  # It should be set to approximately 8x the size of the largest bingen file in
  # object storage. For example, if your largest bingen file is a daily
  # Allocation file with size 300MiB, this value should be set to approximately
  # 2400Mi. In most environments, the default should suffice.
  stagingEmptyDirSizeLimit: 2Gi

  # Governs storage size of aggregator DB storage. Disk performance is important
  # to aggregator performance. Consider high IOPS for best performance.
  aggregatorDbStorage:
    storageClass: ""  # use default storage class
    storageRequest: 128Gi
  resources:
    requests:
      cpu: 4
      memory: 12Gi
    # It is recommended to first establish a baseline over several days to
    # determine a memory limit appropriate for your environment.
    limits:
      cpu: 6
      memory: 16Gi
```

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

### Understanding the state of the Aggregator

```txt
https://kubecost.myorganization.com/model/debug/orchestrator
```

This is a common endpoint for debugging the state of the Aggregator. It returns a JSON response with details such as:

* What is Aggregator's current state? If ingesting, it is downloading & processing ETL files into the DB. If deriving it is pre-computing commonly used queries into saved tables.
* What is the ingestion progress for each of the data types? (e.g. asset, allocation, cloud cost, etc.)
* How fresh is my read database? An epoch timestamp can be found in the `readDBPath`.
* How frequently is my newly ingested data being promoted into the read database? Reference `currentBucketRefreshInterval`.

### Resetting Aggregator StatefulSet data

When deploying the Aggregator as a StatefulSet, it is possible to perform a reset of the Aggregator data. The Aggregator itself doesn't store any data, and relies on object storage. As such, a reset involves removing that Aggregator's local storage, and allowing it to re-ingest data from the object store. The procedure is as follows:

1. Scale down the Aggregator StatefulSet to 0
2. When the Aggregator pod is gone, delete the `aggregator-db-storage-xxx-0` PVC
3. Scale the Aggregator StatefulSet back to 1. This will re-create the PVC, empty.
4. Wait for Kubecost to re-ingest data from the object store. This could take from several minutes to several hours, depending on your data size and retention settings.

### Checking the database for node metadata

Confirming whether node metadata exists in your database can be useful when troubleshooting missing data. Run the following command which will open a shell into the Aggregator pod:

```sh
kubectl exec -it KUBECOST-AGGREGATOR-POD-NAME sh
```

Point to the path where your database exists

```sh
cd /var/configs/waterfowl/duckdb/v0_9_2
ls -lah
```

Copy the database to a new file for testing to avoid modifications to the original data

```sh
cp kubecost-example.duckdb.read kubecost-example.duckdb.read.kubecost.copy
```

Open a DuckDB REPL pointed at the copied database

```sh
duckdb kubecost-example.duckdb.read.kubecost.copy
```

Run the following debugging queries to check if node data is available:

```sql
show tables;
describe node_1d;
select * from node_1d;
select providerid,windowstart,windowend,* from node_1d;

.maxrows 100;
```
