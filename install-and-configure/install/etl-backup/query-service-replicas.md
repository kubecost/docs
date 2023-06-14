# Query Service Replicas

{% hint style="info" %}
This feature is only supported on Kubecost Enterprise plans.
{% endhint %}

The query service replica (QSR) is a scale-out query service that reduces load on the cost-model pod. It allows for improved horizontal scaling by being able to handle queries for larger intervals, and multiple simultaneous queries.

## Overview

The query service will forward `/model/allocation` and `/model/assets` requests to the Query Services StatefulSet.

The diagram below demonstrates the backing architecture of this query service and its functionality.

<figure><img src="../../../.gitbook/assets/image (5).png" alt=""><figcaption></figcaption></figure>

## Data store

There are three methods to implement QSR. For environments that have Kubecost [Federated ETL](https://docs.kubecost.com/install-and-configure/install/multi-cluster/federated-etl) enabled, this store should be used.

Alternatively, an object-store containing the ETL dataset to be queried can be configured using a secret `kubecostDeployment.queryServiceConfigSecret`. The file name of the secret must be `object-store.yaml`. Examples can be found [here](https://docs.kubecost.com/install-and-configure/install/multi-cluster/thanos-setup/long-term-storage#step-1-create-object-store.yaml).

For all other environments, QSR will target the ETL backup store. As of Kubecost v1.100+, this is enabled by default if you enable Thanos. To learn more about ETL backups, see the [ETL Backup](https://docs.kubecost.com/install-and-configure/install/etl-backup) doc.

## Enabling QSR

Once the data store is configured, set `kubecostDeployment.queryServiceReplicas` to a non-zero value and perform a Helm upgrade with your updated values.

## Usage

Once QSR have been enabled, the new pods will automatically handle all API requests to `/model/allocation` and `/model/assets`.
