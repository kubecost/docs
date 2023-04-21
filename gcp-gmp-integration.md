# Google Cloud Managed Service for Prometheus (GMP)

## Overview

Kubecost leverages the open-source Prometheus project as a time series database and post-processes the data in Prometheus to perform cost allocation calculations and provide optimization insights for your Kubernetes clusters. Prometheus is a single machine statically-resourced container, so depending on your cluster size or when your cluster scales out, your cluster could exceed the scraping capabilities of a single Prometheus server. In this doc, you will learn how Kubecost integrates with [Google Cloud Managed Service for Prometheus (GMP)](https://cloud.google.com/stackdriver/docs/managed-prometheus), a managed Prometheus-compatible monitoring service, to enable the customer to monitor Kubernetes easily cost at scale.

For this integration, GMP is required to be enabled for your GKE cluster with the managed collection. Next, Kubecost is installed in your GKE cluster and leverages GMP Prometheus binary to ingest metrics into GMP database seamlessly. In this setup, Kubecost deployment also automatically creates a Prometheus proxy that allows Kubecost to query the metrics from the GMP database for cost allocation calculation.

{% hint style="info" %}
This integration is currently in beta.
{% endhint %}

## Reference Resources

* [Google Cloud Managed Service for Prometheus (GMP)](https://cloud.google.com/stackdriver/docs/managed-prometheus)
* [Get started with self-deployed collection](https://cloud.google.com/stackdriver/docs/managed-prometheus/setup-unmanaged)
* [Configure a query interface](https://cloud.google.com/stackdriver/docs/managed-prometheus/query)

## Instructions

### Prerequisites

* You have a GCP account/subscription.
* You have permission to manage GKE clusters and GCP monitoring services.
* You have an existing GKE cluster with GMP enabled. You can learn more [here](https://cloud.google.com/stackdriver/docs/managed-prometheus/setup-managed#enable-mgdcoll-gke).

### Installations

You can use the following command to install Kubecost on your GKE cluster and integrate with GMP:

```bash
export GCP_PROJECT_ID="YOUR_GCP_PROJECT_ID"
export CLUSTER_NAME="YOUR_GKE_CLUSTER_NAME"
helm upgrade -i kubecost cost-analyzer/ \
--namespace kubecost --create-namespace \
--set prometheus.server.image.repository="gke.gcr.io/prometheus-engine/prometheus" \
--set prometheus.server.image.tag="v2.35.0-gmp.2-gke.0" \
--set global.gmp.enabled="true" \
--set global.gmp.gmpProxy.projectId="${GCP_PROJECT_ID}" \
--set prometheus.server.global.external_labels.cluster_id="${CLUSTER_NAME}" \
--set kubecostProductConfigs.clusterName="${CLUSTER_NAME}"
```
In this installation command, these additional flags are added to have Kubecost work with GMP:

- `prometheus.server.image.repository` and `prometheus.server.image.tag` replace the standard Prometheus image with GMP specific image.
- `global.gmp.enabled` and `global.gmp.gmpProxy.projectId` are for enabling the GMP integration.
- `prometheus.server.global.external_labels.cluster_id` and `kubecostProductConfigs.clusterName` helps to set the name for your Kubecost setup.

You can find additional configurations at our main [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values.yaml) file.

Your Kubecost setup now writes and collects data from GMP. Data should be ready for viewing within 15 minutes.

### Verification

Run the following command to enable port-forwarding to expose the Kubecost dashboard:

```bash
kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090
```

To verify that the integration is set up, go to _Settings_ in the Kubecost UI, and check the Prometheus Status section.

From your [GCP Monitoring - Metrics explorer console](https://console.cloud.google.com/monitoring/metrics-explorer), You can run the following query to verify if Kubecost metrics are collected:

```
avg(node_cpu_hourly_cost) by (cluster_id)
```

Read our [Custom Prometheus integration troubleshooting guide](custom-prom.md#troubleshooting) if you run into any errors while setting up the integration. For support from GCP, you can submit a support request at [GCP support hub](https://cloud.google.com/support-hub).
