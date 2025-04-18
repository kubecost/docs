# Multi-Cluster Diagnostics

{% hint style="info" %}
This feature is currently in beta. It is enabled by default.
{% endhint %}

Multi-Cluster Diagnostics offers a single view into the health of all the clusters you currently monitor with Kubecost.

Health checks include, but are not limited to:

1. Whether Kubecost is correctly emitting metrics
2. Whether Kubecost is being scraped by Prometheus
3. Whether Prometheus has scraped the required metrics
4. Whether Kubecost's ETL files are healthy

## Configuration

```yaml
# This is an abridged example. Full example in link below.
diagnostics:
  enabled: true
  primary:
    enabled: true  # Only enable this on your primary Kubecost cluster

# Ensure you have configured a unique CLUSTER_ID.
prometheus:
  server:
    global:
      external_labels:
        cluster_id: YOUR_CLUSTER_ID
kubecostProductConfigs:
  clusterName: YOUR_CLUSTER_ID

# Ensure you have configured a storage config secret.
kubecostModel:
  federatedStorageConfigSecret: federated-store
```

Additional configuration options can found in the [*values.yaml*](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v2.6/cost-analyzer/values.yaml) under `diagnostics:`.

## Architecture

The Multi-Cluster Diagnostics feature is a process run within the `kubecost-cost-analyzer` deployment. It has the option to be run as an independent deployment for higher availability via `.Values.diagnostics.deployment.enabled`.

When run in each Kubecost deployment, it monitors the health of Kubecost and sends that health data to the central object store at the `/diagnostics` filepath. The below diagram depicts these interactions. This diagram is specific to the requests required for diagnostics only. For additional diagrams, see our [multi-cluster guide](multi-cluster.md).

![Kubecost-Agent-Diagnostics](/images/diagrams/Agent-Diagnostics-Architecture.png)

## Health Check Definitions

The API response includes several health checks that validate different aspects of your Kubecost deployment. If you see repeated failures for any health check, there is potential for data loss. Please refer to the table below to resolve the issue.

| Health Check | Description |
|--------------|-------------|
| `kubecostEmittingMetric` | Validates that Kubecost is collecting and emitting metrics for container allocations, network egress, labels, and more. See the documentation [here](/architecture/user-metrics.md#kubecost-cost-model) for more details. If failing, try restarting the `kubecost-cost-analyzer` pod. Try port-forwarding to the pod and hitting `http://localhost:9003/metrics` to verify that metrics are being emitted. Reach out to Kubecost support for additional assistance. |
| `prometheusHasKubecostMetric` | Validates that Prometheus has scraped and stored Kubecost metrics. If failing, refer to the [Prometheus Troubleshooting Guide](/troubleshooting/prometheus.md) and try querying for the `node_total_hourly_cost` metric. Reach out to Kubecost support for additional assistance. |
| `prometheusHasCadvisorMetric` | Validates that Prometheus has scraped cAdvisor for metrics regarding container resource usage ([docs](/architecture/user-metrics.md#cadvisor)). If failing, refer to the [Prometheus Troubleshooting Guide](/troubleshooting/prometheus.md) and try querying for the `container_memory_working_set_bytes` metric. Reach out to Kubecost support for additional assistance. |
| `prometheusHasKSMMetric` | Validates that Prometheus has scraped metrics for metrics regarding resource requests, node capacity, labels, and more ([docs](/architecture/user-metrics.md#kube-state-metrics-ksm)). If failing, refer to the [Prometheus Troubleshooting Guide](/troubleshooting/prometheus.md) and try querying for the `kube_pod_container_resource_requests` metric. Reach out to Kubecost support for additional assistance. |
| `dailyAllocationEtlHealthy` | Validates that Kubecost has successfully built Allocation ETL files. These ETL files consist of Allocations data for the cluster, and are built by querying Prometheus metrics. If failing, refer to the [ETL Repair Guide](/troubleshooting/etl-repair.md) and try repairing the ETL files for the specific cluster. Reach out to Kubecost support for additional assistance. |
| `dailyAssetEtlHealthy` | Validates that Kubecost has successfully built Assets ETL files. These ETL files consist of Assets data for the cluster, and are built by querying Prometheus metrics. If failing, refer to the [ETL Repair Guide](/troubleshooting/etl-repair.md) and try repairing the ETL files for the specific cluster. Reach out to Kubecost support for additional assistance. |
| `kubecostPodsNotOOMKilled` | Validates that no pods in the namespace Kubecost is deployed to have OutOfMemoryKilled errors. If failing, check all pods in the namespace Kubecost is deployed to. Review logs of the failing pod. Reach out to Kubecost support for additional assistance. |
| `kubecostPodsNotPending` | Validates that no pods in the namespace Kubecost is deployed to are in a Pending state. If failing, check all pods in the namespace Kubecost is deployed to. Run a `kubectl describe` on all Deployments and StatefulSets to understand the controller events. Reach out to Kubecost support for additional assistance. |
| `costModelStorageStats` | Validates that PersistentVolume utilization is below 80%. If failing, increase the PersistentVolume size. |

## API Usage

The diagnostics API can be accessed on the `primary` via `/model/diagnostics/multicluster?window=1d`.

The `window` query parameter is required, which will return all diagnostics within the specified time window.

{% swagger method="get" path="/multi-cluster-diagnostics" baseUrl="http://<your-kubecost-address>/model" summary="Multi-cluster Diagnostics API" %}
{% swagger-description %}
The Multi-cluster Diagnostics API provides a single view into the health of all the clusters you currently monitor with Kubecost.
{% endswagger-description %}

{% swagger-parameter in="path" name="window" type="string" required="true" %}
Duration of time over which to query. Accepts words like `today`, `week`, `month`, `yesterday`, `lastweek`, `lastmonth`; durations like `30m`, `12h`, `7d`; comma-separated RFC3339 date pairs like `2021-01-02T15:04:05Z,2021-02-02T15:04:05Z`; comma-separated Unix timestamp (seconds) pairs like `1578002645,1580681045`.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
```json
{
    "code": 200,
    "data": {
        "overview": {
            "kubecostEmittingMetricDiagnosticPassed": true,
            "prometheusHasKubecostMetricDiagnosticPassed": true,
            "prometheusHasCadvisorMetricDiagnosticPassed": true,
            "prometheusHasKSMMetricDiagnosticPassed": true,
            "dailyAllocationEtlHealthyDiagnosticPassed": true,
            "dailyAssetEtlHealthyDiagnosticPassed": true,
            "kubecostPodsNotOOMKilledDiagnosticPassed": true,
            "kubecostPodsNotPendingDiagnosticPassed": false,
            "costModelStorageStatsDiagnosticPassed": true
        },
        "clusters": [
            {
                "clusterId": "cluster_one",
                "latestRun": "2024-03-01T22:42:32Z",
                "kubecostVersion": "prod-2.6.0",
                "kubecostEmittingMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "successful query to http://localhost:9003/metrics"
                },
                "prometheusHasKubecostMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "kubecost metric exists: absent_over_time(node_total_hourly_cost[5m])"
                },
                "prometheusHasCadvisorMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "cAdvisor metric exists: absent_over_time(container_memory_working_set_bytes{container='cost-model', container!='POD', instance!=''}[5m])"
                },
                "prometheusHasKSMMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "ksm metric exists: absent_over_time(kube_pod_container_resource_requests{resource='memory', unit='byte'}[5m])"
                },
                "dailyAllocationEtlHealthy": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "all daily allocation ETL are healthy: kubecost_allocation_data_status{resolution='daily', status='error'} \u003e 0"
                },
                "dailyAssetEtlHealthy": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "all asset ETL are healthy: kubecost_asset_data_status{resolution='daily', status='error'} \u003e 0"
                },
                "kubecostPodsNotOOMKilled": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "all pods in kubecost namespace sufficient memory"
                },
                "kubecostPodsNotPending": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "all pods in kubecost namespace running"
                },
                "costModelStorageStats": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "CostAnalyzer PV utilization lower than 80%. Total=31949.77MiB. Used=13.68MiB"
                }
            },
            {
                "clusterId": "cluster_two",
                "latestRun": "2024-03-01T22:40:17Z",
                "kubecostVersion": "prod-2.6.0",
                "kubecostEmittingMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "successful query to http://localhost:9003/metrics"
                },
                "prometheusHasKubecostMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "kubecost metric exists: absent_over_time(node_total_hourly_cost[5m])"
                },
                "prometheusHasCadvisorMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "cAdvisor metric exists: absent_over_time(container_memory_working_set_bytes{container='cost-model', container!='POD', instance!=''}[5m])"
                },
                "prometheusHasKSMMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "ksm metric exists: absent_over_time(kube_pod_container_resource_requests{resource='memory', unit='byte'}[5m])"
                },
                "dailyAllocationEtlHealthy": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "all daily allocation ETL are healthy: kubecost_allocation_data_status{resolution='daily', status='error'} \u003e 0"
                },
                "dailyAssetEtlHealthy": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "all asset ETL are healthy: kubecost_asset_data_status{resolution='daily', status='error'} \u003e 0"
                },
                "kubecostPodsNotOOMKilled": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "all pods in kubecost namespace sufficient memory"
                },
                "kubecostPodsNotPending": {
                    "diagnosticPassed": false,
                    "numFailures": 52,
                    "firstFailureDate": "2024-03-01T18:25:09Z",
                    "diagnosticOutput": "RunDiagnostic: checkKubecostPodsNotPending: queryPrometheusCheckResultEmpty: the following query returned a non-empty result sum(kube_pod_status_phase{namespace='kubecost-etl-fed', phase='Pending'}) by (pod,namespace) > 0"
                },
                "costModelStorageStats": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "CostAnalyzer PV utilization lower than 80%. Total=31949.77MiB. Used=13.68MiB"
                }
            },
            {
                "clusterId": "cluster_three",
                "latestRun": "2024-03-01T22:42:32Z",
                "kubecostVersion": "prod-2.6.0",
                "kubecostEmittingMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "successful query to http://localhost:9003/metrics"
                },
                "prometheusHasKubecostMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "kubecost metric exists: absent_over_time(node_total_hourly_cost[5m])"
                },
                "prometheusHasCadvisorMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "cAdvisor metric exists: absent_over_time(container_memory_working_set_bytes{container='cost-model', container!='POD', instance!=''}[5m])"
                },
                "prometheusHasKSMMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "ksm metric exists: absent_over_time(kube_pod_container_resource_requests{resource='memory', unit='byte'}[5m])"
                },
                "dailyAllocationEtlHealthy": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "all daily allocation ETL are healthy: kubecost_allocation_data_status{resolution='daily', status='error'} \u003e 0"
                },
                "dailyAssetEtlHealthy": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "all asset ETL are healthy: kubecost_asset_data_status{resolution='daily', status='error'} \u003e 0"
                },
                "kubecostPodsNotOOMKilled": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "all pods in kubecost namespace sufficient memory"
                },
                "kubecostPodsNotPending": {
                    "diagnosticPassed": false,
                    "numFailures": 52,
                    "firstFailureDate": "2024-03-01T18:24:42Z",
                    "diagnosticOutput": "RunDiagnostic: checkKubecostPodsNotPending: queryPrometheusCheckResultEmpty: the following query returned a non-empty result sum(kube_pod_status_phase{namespace='kubecost-etl-fed', phase='Pending'}) by (pod,namespace) > 0"
                },
                "costModelStorageStats": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "CostAnalyzer PV utilization lower than 80%. Total=31949.77MiB. Used=13.68MiB"
                }
            }
        ]
    }
}
```
{% endswagger-response %}
{% endswagger %}
