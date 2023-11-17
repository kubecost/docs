# Agent Diagnostics

{% hint style="info" %}
Kubecost Diagnostics is performed by an independent pod that sends health data to the shared object-store used by [Federated-ETL or Thanos](multi-cluster.md).
{% endhint %}

## Diagnostics Overview

The diagnostics pod is enabled by default when Federated-ETL or Thanos is enabled.

The aggregated diagnostics can be accessed through the Kubecost UI or API.

The health checks include:
1. whether Kubecost is emitting metrics
2. whether Kubecost is being scraped by Prometheus
3. whether Kubecost has healthy ETL files

## Diagnostics Configuration


The diagnostics pod can be configured with the following Helm values:

```yaml
diagnostics:
  enabled: true
  ## How frequently to run & push diagnostics. Defaults to 5 minutes.
  pollingInterval: "300"
  ## Creates a new Diagnostic file in the bucket for every run
  keepDiagnosticHistory: true
  ## Pushes the cluster's Kubecost Helm Values to the bucket. This will consume additional storage and network transfers
  collectHelmValues: false
```

Additional configuration options can found in the [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values.yaml) under `diagnostics:`.



## Diagnostics Architecture

![Kubecost-Agent-Diagnostics](/images/daigrams/Agent-Diagnostics-Architecture.png)

## Diagnostics API

The diagnostics API can be accessed through `/model/multi-cluster-diagnostics`

The `window` query parameter is required, which will return all diagnostics within the specified time window.

Example output:

```json
```