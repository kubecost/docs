# Query Service Replicas

{% hint style="info" %}
This feature is only supported on Kubecost Enterprise plans.
{% endhint %}

The query service replica (QSR) is a scale-out query service that reduces load on the cost-model pod. It allows for improved horizontal scaling by being able to handle queries for larger intervals, and multiple simultaneous queries.

## Overview

The query service will forward `/model/allocation` and `/model/assets` requests to the Query Services StatefulSet.

The diagram below demonstrates the backing architecture of this query service and its functionality.

<figure><img src="../../../.gitbook/assets/image (5).png" alt=""><figcaption></figcaption></figure>

## Prerequisites

There are two methods to implement QSR. For environments that have Kubecost [Federated ETL](https://docs.kubecost.com/install-and-configure/install/multi-cluster/federated-etl) enabled, the Federated ETL object-store must be used. Federated ETL is, itself, a backup mechanism.

For all other environments, QSR will target the ETL backups. As of Kubecost v1.100+, this is enabled by default if you enable Thanos. To learn more about ETL backups, see the [ETL Backup](https://docs.kubecost.com/install-and-configure/install/etl-backup) doc.

## Enabling QSR

Once Federated ETL or ETL Backups are configured, set `kubecostDeployment.queryServiceReplicas` to a non-zero value. Perform a Helm upgrade with your updated _values.yaml._

## Usage

Once QSR have been enabled, the new pods will automatically handle all API requests to `/model/allocation` and `/model/assets`.
