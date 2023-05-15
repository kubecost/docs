# Query Service Replicas

{% hint style="info" %}
This feature is only supported on Kubecost Enterprise plans.&#x20;
{% endhint %}

The query service replica (QSR) is a standalone query service that executes independently of Kubecost's metric emission and data model, and is able to access to Kubecost data. It allows for improved horizontal scaling by being able to handle queries for larger intervals, and multiple simultaneous queries.

## Overview

The query service will forward `/model/allocation` and `/model/assets` requests to a Deployment of Query Services and managed by a Load Balancer.

The diagram below demonstrates the backing architecture of this query service and its functionality.

<figure><img src="../../../.gitbook/assets/image (5).png" alt=""><figcaption></figcaption></figure>

## Prerequisites

In order to make use of QSRs, you must first have enabled ETL backups. As of v1.100+ of Kubecost, this is enabled by default if you enable Thanos. To learn more about ETL backups, see the [ETL Backup](https://docs.kubecost.com/install-and-configure/install/etl-backup) doc.

## Enabling QSR

After following the doc above and enabling ETL backup, you should already have set a value for the Helm flag `.Values.kubecostModel.etlBucketConfigSecret`.

Next, set `kubecostDeployment.queryServiceReplicas` to a non-zero value. Perform a Helm upgrade with your updated _values.yaml._

## Usage

Once ETL backups and the QSR have been enabled, the process will automatically apply to all Allocations or Assets queries. You can make these queries as usual using either the Kubecost UI dashboards or direct API endpoints.
