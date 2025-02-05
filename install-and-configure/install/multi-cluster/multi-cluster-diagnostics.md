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

Additional configuration options can found in the [*values.yaml*](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values.yaml) under `diagnostics:`.

## Architecture

The Multi-Cluster Diagnostics feature is a process run within the `kubecost-cost-analyzer` deployment. It has the option to be run as an independent deployment for higher availability via `.Values.diagnostics.deployment.enabled`.

When run in each Kubecost deployment, it monitors the health of Kubecost and sends that health data to the central object store at the `/diagnostics` filepath. The below diagram depicts these interactions. This diagram is specific to the requests required for diagnostics only. For additional diagrams, see our [multi-cluster guide](multi-cluster.md).

![Kubecost-Agent-Diagnostics](/images/diagrams/Agent-Diagnostics-Architecture.png)

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
            "kubecostPodsNotPendingDiagnosticPassed": false
        },
        "clusters": [
            {
                "clusterId": "cluster_one",
                "latestRun": "2024-03-01T22:42:32Z",
                "kubecostVersion": "v2.1",
                "kubecostEmittingMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "prometheusHasKubecostMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "prometheusHasCadvisorMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "prometheusHasKSMMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "dailyAllocationEtlHealthy": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "dailyAssetEtlHealthy": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "kubecostPodsNotOOMKilled": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "kubecostPodsNotPending": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                }
            },
            {
                "clusterId": "cluster_two",
                "latestRun": "2024-03-01T22:40:17Z",
                "kubecostVersion": "v2.1",
                "kubecostEmittingMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "prometheusHasKubecostMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "prometheusHasCadvisorMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "prometheusHasKSMMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "dailyAllocationEtlHealthy": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "dailyAssetEtlHealthy": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "kubecostPodsNotOOMKilled": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "kubecostPodsNotPending": {
                    "diagnosticPassed": false,
                    "numFailures": 52,
                    "firstFailureDate": "2024-03-01T18:25:09Z",
                    "diagnosticOutput": "RunDiagnostic: checkKubecostPodsNotPending: queryPrometheusCheckResultEmpty: the following query returned a non-empty result sum(kube_pod_status_phase{namespace='kubecost-etl-fed', phase='Pending'}) by (pod,namespace) > 0"
                }
            },
            {
                "clusterId": "cluster_three",
                "latestRun": "2024-03-01T22:42:32Z",
                "kubecostVersion": "v2.1",
                "kubecostEmittingMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "prometheusHasKubecostMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "prometheusHasCadvisorMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "prometheusHasKSMMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "dailyAllocationEtlHealthy": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "dailyAssetEtlHealthy": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "kubecostPodsNotOOMKilled": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": ""
                },
                "kubecostPodsNotPending": {
                    "diagnosticPassed": false,
                    "numFailures": 52,
                    "firstFailureDate": "2024-03-01T18:24:42Z",
                    "diagnosticOutput": "RunDiagnostic: checkKubecostPodsNotPending: queryPrometheusCheckResultEmpty: the following query returned a non-empty result sum(kube_pod_status_phase{namespace='kubecost-etl-fed', phase='Pending'}) by (pod,namespace) > 0"
                }
            }
        ]
    }
}
```
{% endswagger-response %}
{% endswagger %}

## API Response Health Checks

The API response includes several health checks that validate different aspects of your Kubecost deployment:

| Health Check | Description |
|--------------|-------------|
| `kubecostEmittingMetric` | Validates that Kubecost is collecting and emitting metrics for container allocations, network egress, labels, and more ([docs](/architecture/user-metrics.md#kubecost-cost-model)) |
| `prometheusHasKubecostMetric` | Validates that Prometheus has scraped and stored Kubecost metrics |
| `prometheusHasCadvisorMetric` | Validates that Prometheus has scraped cAdvisor for metrics regarding container resource usage ([docs](/architecture/user-metrics.md#cadvisor)) |
| `prometheusHasKSMMetric` | Validates that Prometheus has scraped metrics for metrics regarding resource requests, node capacity, labels, and more ([docs](/architecture/user-metrics.md#kube-state-metrics-ksm)) |
| `dailyAllocationEtlHealthy` | Validates that Kubecost has successfully built Allocation ETL files. These ETL files consist of Allocations data for the cluster. |
| `dailyAssetEtlHealthy` | Validates that Kubecost has successfully built Assets ETL files. These ETL files consist of Assets data for the cluster. |
| `kubecostPodsNotOOMKilled` | Validates that no pods in the namespace Kubecost is deployed to have OutOfMemoryKilled errors |
| `kubecostPodsNotPending` | Validates that no pods in the namespace Kubecost is deployed to are in a Pending state |
| `costModelStorageStats` | Validates that PersistentVolume utilization is below 80% |
