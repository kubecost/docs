# Query Service Replicas

{% hint style="warning" %}
Query service replicas are no longer supported as of Kubecost v2.0+.
{% endhint %}

{% hint style="info" %}
This feature is only supported on Kubecost Enterprise plans.
{% endhint %}

The query service replica (QSR) is a scale-out query service that reduces load on the cost-model pod. It allows for improved horizontal scaling by being able to handle queries for larger intervals, and multiple simultaneous queries.

## Overview

The query service will forward `/model/allocation` and `/model/assets` requests to the Query Services StatefulSet.

The diagram below demonstrates the backing architecture of this query service and its functionality.

![Query service architecture](/.gitbook/assets/qsr-arch.png)

## Requirements

### ETL data source

There are three options that can be used for the source ETL Files:

1. For environments that have Kubecost [Federated ETL](/install-and-configure/install/multi-cluster/federated-etl/federated-etl.md) enabled, this store will be used, no additional configuration is required.
2. For single cluster environments, QSR can target the ETL backup store. To learn more about ETL backups, see the [ETL Backup](/install-and-configure/install/etl-backup/etl-backup.md) doc.
3. Alternatively, an object-store containing the ETL dataset to be queried can be configured using a secret `kubecostDeployment.queryServiceConfigSecret`. The file name of the secret must be `object-store.yaml`. Examples can be found in our [Configuring Thanos](/install-and-configure/install/multi-cluster/thanos-setup/configuring-thanos.md#step-1-create-object-storeyaml) doc.

### Persistent volume on Kubecost primary instance

QSR uses persistent volume storage to avoid excessive S3 transfers. Data is retrieved from S3 hourly as new ETL files are created and stored in these PVs. The `databaseVolumeSize` should be larger than the size of the data in the S3 bucket.

When the pods start, data from the object-store is synced and this can take a significant time in large environments. During the sync, parts of the Kubecost UI will appear broken or have missing data. You can follow the pod logs to see when the sync is complete.

The default of 100Gi is enough storage for 1M pods and 90 days of retention. This can be adjusted:

```yaml
kubecostDeployment:
  queryServiceReplicas: 2
  queryService:
    # default storage class
    storageClass: ""
    databaseVolumeSize: 100Gi
    configVolumeSize: 1G
```

## Enabling QSR

Once the data store is configured, set `kubecostDeployment.queryServiceReplicas` to a non-zero value and perform a Helm upgrade.

## Usage

Once QSR has been enabled, the new pods will automatically handle all API requests to `/model/allocation` and `/model/assets`.