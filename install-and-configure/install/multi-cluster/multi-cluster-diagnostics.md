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
  isDiagnosticsPrimary:
    enabled: true  # Only enable this on your primary cluster

# Ensure you have configured a unique CLUSTER_ID.
prometheus:
  server:
    global:
      external_labels:
        cluster_id: YOUR_CLUSTER_ID

# Ensure you have configured a storage config secret. Using `.Values.thanos.storeSecretName` would also work here.
kubecostModel:
  federatedStorageConfigSecret: federated-store
```

Additional configuration options can found in the [*values.yaml*](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values.yaml) under `diagnostics:`.

## Architecture

The multi-cluster diagnostics feature is run as an independent deployment (i.e. `deployment/kubecost-diagnostics`). Each diagnostics deployment monitors the health of Kubecost and sends that health data to the central object store at the `/diagnostics` filepath.

The below diagram depicts these interactions. This diagram is specific to the requests required for diagnostics only. For additional diagrams, see our  [multi-cluster guide](multi-cluster.md).

![Kubecost-Agent-Diagnostics](/images/diagrams/Agent-Diagnostics-Architecture.png)

## API usage

The diagnostics API can be accessed through `/model/multi-cluster-diagnostics?window=2d` (or `/model/mcd` for short)

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
        "clusters": {
            "cluster_one": {
                "latestRun": "2023-12-12T22:42:32Z",
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
            "cluster_two": {
                "latestRun": "2023-12-12T22:40:17Z",
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
                    "firstFailureDate": "2023-12-12T18:25:09Z",
                    "diagnosticOutput": "RunDiagnostic: checkKubecostPodsNotPending: queryPrometheusCheckResultEmpty: the following query returned a non-empty result sum(kube_pod_status_phase{namespace='kubecost-etl-fed', phase='Pending'}) by (pod,namespace) > 0"
                }
            },
            "cluster_three": {
                "latestRun": "2023-12-12T22:40:15Z",
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
                    "firstFailureDate": "2023-12-12T18:24:42Z",
                    "diagnosticOutput": "RunDiagnostic: checkKubecostPodsNotPending: queryPrometheusCheckResultEmpty: the following query returned a non-empty result sum(kube_pod_status_phase{namespace='kubecost-etl-fed', phase='Pending'}) by (pod,namespace) > 0"
                }
            }
        }
    }
}
```
{% endswagger-response %}
{% endswagger %}
