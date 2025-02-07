# Google Cloud Managed Service for Prometheus

## Overview

Kubecost leverages the open-source Prometheus project as a time series database and post-processes the data in Prometheus to perform cost allocation calculations and provide optimization insights for your Kubernetes clusters. Prometheus is a single machine statically-resourced container, so depending on your cluster size or when your cluster scales out, your cluster could exceed the scraping capabilities of a single Prometheus server. In this doc, you will learn how Kubecost integrates with [Google Cloud Managed Service for Prometheus (GMP)](https://cloud.google.com/stackdriver/docs/managed-prometheus), a managed Prometheus-compatible monitoring service, to enable the customer to monitor Kubernetes costs at scale easily.

For this integration, GMP is required to be enabled for your GKE cluster with the managed collection. Next, Kubecost is installed in your GKE cluster and leverages GMP Prometheus binary to ingest metrics into GMP database seamlessly. In this setup, Kubecost deployment also automatically creates a Prometheus proxy that allows Kubecost to query the metrics from the GMP database for cost allocation calculation.

{% hint style="info" %}
This integration is currently in beta.
{% endhint %}

## Reference resources

* [Google Cloud Managed Service for Prometheus (GMP)](https://cloud.google.com/stackdriver/docs/managed-prometheus)
* [Get started with self-deployed collection](https://cloud.google.com/stackdriver/docs/managed-prometheus/setup-unmanaged)
* [Configure a query interface](https://cloud.google.com/stackdriver/docs/managed-prometheus/query)

## Instructions

### Prerequisites

* You have a GCP account/subscription.
* You have permission to manage GKE clusters and GCP monitoring services.
* You have an existing GKE cluster with GMP enabled. You can learn more [here](https://cloud.google.com/stackdriver/docs/managed-prometheus/setup-managed#enable-mgdcoll-gke).

### Installation

```yaml
# values.yaml
global:
  gmp:
    enabled: true
    gmpProxy:
      projectId: ${GCP_PROJECT_ID}
prometheus:
  server:
    # Replaces standard Prometheus image with GMP specific image
    image:
      repository: "gke.gcr.io/prometheus-engine/prometheus"
      tag: "v2.35.0-gmp.2-gke.0"
    global:
      external_labels:
        cluster_id: ${CLUSTER_NAME}
kubecostProductConfigs:
  clusterName: ${CLUSTER_NAME}
federatedETL:
  useMultiClusterDB: true
```

Once you've configured your `values.yaml` file, you can run the following command to install Kubecost on your GKE cluster and integrate with GMP:

```bash
helm upgrade -i kubecost cost-analyzer/ \
  --namespace kubecost --create-namespace \
  -f values.yaml
```

You can find additional configuration options in our main [*values.yaml*](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values.yaml) file.

### Verification

Run the following command to enable port-forwarding to expose the Kubecost dashboard:

```bash
kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090
```

To verify that the integration is set up, go to _Settings_ in the Kubecost UI, and check the Prometheus Status section.

From your [GCP Monitoring - Metrics explorer console](https://console.cloud.google.com/monitoring/metrics-explorer), You can run the following query to verify if Kubecost metrics are collected:

```txt
avg(node_cpu_hourly_cost) by (cluster_id)
```

## Troubleshooting

### Cluster efficiency displaying as 0%, or efficieny only displaying for most recent cluster

The below queries must return data for Kubecost to calculate costs correctly. For the queries to work, set the environment variables:

```bash
KUBECOST_NAMESPACE=kubecost
KUBECOST_DEPLOYMENT=kubecost-cost-analyzer
CLUSTER_ID=YOUR_CLUSTER_NAME
```

1. Verify connection to GMP and that the metric for `container_memory_working_set_bytes` is available:

If you have set `kubecostModel.promClusterIDLabel` in the Helm chart, you will need to change the query (`CLUSTER_ID`) to match the label.

```bash
kubectl exec -it -n $KUBECOST_NAMESPACE \
  deployments/$KUBECOST_DEPLOYMENT -c cost-analyzer-frontend \
  -- curl "0:9090/model/prometheusQuery?query=container_memory_working_set_bytes\{CLUSTER_ID=\"$CLUSTER_ID\"\}" \
 | jq
```

2. Verify Kubecost metrics are available in GMP:

```bash
kubectl exec -it -n $KUBECOST_NAMESPACE \
  deployments/$KUBECOST_DEPLOYMENT -c cost-analyzer-frontend \
  -- curl "0:9090/model/prometheusQuery?query=node_total_hourly_cost\{CLUSTER_ID=\"$CLUSTER_ID\"\}" \
 | jq
```

You should receive an output similar to:

```json
{
  "status": "success",
  "data": {
    "resultType": "vector",
    "result": [
      {
        "metric": {
          "__name__": "",
          "cluster": "",
          "id": "/",
          "instance": "",
          "job": "kubelet",
          "location": "",
          "node": "",
          "project_id": ""
        },
        "value": [
          1697627020,
          "2358820864"
        ]
      },
```

{% hint style="info" %}
If `id` returns as a blank value, you can set the following Helm value to force set `cluster` as the Prometheus cluster ID label:

```yaml
kubecostModel:
  promClusterIDLabel: cluster
```
{% endhint %}

If the above queries fail, check the following:

1. Check logs of the `sigv4proxy` container (may be the Kubecost deployment or Prometheus Server deployment depending on your setup):

```bash
kubectl logs deployments/$KUBECOST_DEPLOYMENT -c sigv4proxy --tail -1
```

In a working `sigv4proxy`, there will be very few logs.

Correctly working log output:

```log
time="2023-09-21T17:40:15Z" level=info msg="Stripping headers []" StripHeaders="[]"
time="2023-09-21T17:40:15Z" level=info msg="Listening on :8005" port=":8005"
```

2. Check logs in the `cost-model` container for Prometheus connection issues:

```bash
kubectl logs deployments/$KUBECOST_DEPLOYMENT -c cost-model --tail -1 | grep -i err
```

Example errors:

```log
ERR CostModel.ComputeAllocation: pod query 1 try 2 failed: avg(kube_pod_container_status_running...
Prometheus communication error: 502 (Bad Gateway) ...
```

Additionally, read our [Custom Prometheus integration troubleshooting guide](custom-prom.md#troubleshooting) if you run into any other errors while setting up the integration. For support from GCP, you can submit a support request at the [GCP support hub](https://cloud.google.com/support-hub).
