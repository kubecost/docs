# Agent Diagnostics

{% hint style="info" %}
Kubecost Diagnostics is performed by an independent pod that sends health data to the shared object-store used by [Federated-ETL or Thanos](multi-cluster.md).
{% endhint %}

## Diagnostics Overview

The diagnostics pod is enabled by default when Federated-ETL or Thanos is enabled.

The aggregated diagnostics can be accessed through the Kubecost UI or API.

The health checks include:
1. Kubecost is emitting metrics
2. Kubecost is being scraped by Prometheus
3. Prometheus has required metrics
4. Kubecost has healthy ETL files

All of these items are required for Kubecost to accurately report costs.

## Usage

{% hint style="info" %}
As of Kubecost 1.108.0, this utility is not exposed in the UI. This will be added in the next version.
{% endhint %}

Today, the API can be accessed from the Kubecost Primary UI via the shortcut json endpoint: `/model/mcd` (Multi-Cluster-Diagnostics)

## Diagnostics configuration

The diagnostics pod can be configured with the following Helm values:

```yaml
diagnostics:
  enabled: true
  ## How frequently to run & push diagnostics. Defaults to 5 minutes.
  pollingInterval: "300s"
  ## Creates a new Diagnostic file in the bucket for every run.
  keepDiagnosticHistory: false
  ## Pushes the cluster's Kubecost Helm Values to the bucket once upon startup.
  ## This may contain sensitive information and is roughly 30kb per cluster.
  collectHelmValues: false
  ## The primary aggregates all diagnostic data and serves HTTP queries.
  isDiagnosticsPrimary:
    enabled: false
```

Additional configuration options can found in the [*values.yaml*](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values.yaml) under `diagnostics:`.

## Diagnostics architecture

{% hint style="info" %}
In the below diagram, the arrows originate from the the pod initiating the request and point to the resource that receives the request.
This diagram is specific to the requests required for diagnostics only. For additional diagrams, see the [multi-cluster guide](multi-cluster.md).
{% endhint %}

![Kubecost-Agent-Diagnostics](/images/daigrams/Agent-Diagnostics-Architecture.png)

## Diagnostics API

The diagnostics API can be accessed through `/model/multi-cluster-diagnostics?window=2d` (or `/model/mcd` for short)

The `window` query parameter is required, which will return all diagnostics within the specified time window.

<details>

<summary>Example output</summary>

```json
{
    "code": 200,
    "data": {
        "overview": {
            "kubecostEmittingMetricDiagnosticPassed": true,
            "prometheusHasKubecostMetricDiagnosticPassed": false,
            "prometheusHasCadvisorMetricDiagnosticPassed": false,
            "prometheusHasKSMMetricDiagnosticPassed": false,
            "dailyAllocationEtlHealthyDiagnosticPassed": false,
            "dailyAssetEtlHealthyDiagnosticPassed": false,
            "kubecostPodsNotOOMKilledDiagnosticPassed": false,
            "kubecostPodsNotPendingDiagnosticPassed": false
        },
        "clusters": {
            "production-us-west1": {
                "latestRun": "2023-11-17T01:54:29Z",
                "kubecostEmittingMetric": {
                    "diagnosticPassed": true,
                    "numFailures": 0,
                    "firstFailureDate": "",
                    "diagnosticOutput": "checkKubecostEmittingMetrics: http://localhost:9003/metrics"
                },
                "prometheusHasKubecostMetric": {
                    "diagnosticPassed": false,
                    "numFailures": 1,
                    "firstFailureDate": "2023-11-17T01:56:10Z",
                    "diagnosticOutput": "RunDiagnostic: checkPrometheusHasKubecostMetric: queryPrometheus: Get \"http://localhost:9003/prometheusQuery?query=absent_over_time%28node_total_hourly_cost%5B5m%5D%29\": read tcp [::1]:55137->[::1]:9003: read: connection reset by peer"
                },
                "prometheusHasCadvisorMetric": {
                    "diagnosticPassed": false,
                    "numFailures": 1,
                    "firstFailureDate": "2023-11-17T01:56:10Z",
                    "diagnosticOutput": "RunDiagnostic: checkPrometheusHasCadvisorMetric: queryPrometheus: Get \"http://localhost:9003/prometheusQuery?query=absent_over_time%28container_memory_working_set_bytes%7Bcontainer%3D%27cost-model%27%2C+container%21%3D%27POD%27%2C+instance%21%3D%27%27%7D%5B5m%5D%29\": read tcp [::1]:55142->[::1]:9003: read: connection reset by peer"
                },
                "prometheusHasKSMMetric": {
                    "diagnosticPassed": false,
                    "numFailures": 1,
                    "firstFailureDate": "2023-11-17T01:56:10Z",
                    "diagnosticOutput": "RunDiagnostic: checkPrometheusHasKSMMetric: queryPrometheus: Get \"http://localhost:9003/prometheusQuery?query=absent_over_time%28kube_pod_container_resource_requests%7Bresource%3D%27memory%27%2C+unit%3D%27byte%27%7D%5B5m%5D%29\": read tcp [::1]:55146->[::1]:9003: read: connection reset by peer"
                },
                "dailyAllocationEtlHealthy": {
                    "diagnosticPassed": false,
                    "numFailures": 1,
                    "firstFailureDate": "2023-11-17T01:56:10Z",
                    "diagnosticOutput": "RunDiagnostic: checkDailyAllocationEtlHealth: queryPrometheus: Get \"http://localhost:9003/prometheusQuery?query=kubecost_allocation_data_status%7Bresolution%3D%27daily%27%2C+status%3D%27error%27%7D+%3E+0\": dial tcp [::1]:9003: connect: connection refused"
                },
                "dailyAssetEtlHealthy": {
                    "diagnosticPassed": false,
                    "numFailures": 1,
                    "firstFailureDate": "2023-11-17T01:56:10Z",
                    "diagnosticOutput": "RunDiagnostic: checkDailyAssetEtlHealth: queryPrometheus: Get \"http://localhost:9003/prometheusQuery?query=kubecost_asset_data_status%7Bresolution%3D%27daily%27%2C+status%3D%27error%27%7D+%3E+0\": dial tcp [::1]:9003: connect: connection refused"
                },
                "kubecostPodsNotOOMKilled": {
                    "diagnosticPassed": false,
                    "numFailures": 1,
                    "firstFailureDate": "2023-11-17T01:56:10Z",
                    "diagnosticOutput": "RunDiagnostic: checkKubecostPodNotOOMKilled: queryPrometheus: Get \"http://localhost:9003/prometheusQuery?query=kube_pod_container_status_terminated_reason%7Bnamespace%3D%27kubecost%27%2C+reason%3D%27OOMKilled%27%7D+%3E+0\": dial tcp [::1]:9003: connect: connection refused"
                },
                "kubecostPodsNotPending": {
                    "diagnosticPassed": false,
                    "numFailures": 1,
                    "firstFailureDate": "2023-11-17T01:56:10Z",
                    "diagnosticOutput": "RunDiagnostic: checkKubecostPodsNotPending: queryPrometheus: Get \"http://localhost:9003/prometheusQuery?query=sum%28kube_pod_status_phase%7Bnamespace%3D%27kubecost%27%2C+phase%3D%27Pending%27%7D%29+by+%28pod%2Cnamespace%29+%3E+0\": dial tcp [::1]:9003: connect: connection refused"
                }
            }
        }
    }
}
```

</details>
