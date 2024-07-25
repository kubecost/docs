# Tuning Resource Consumption

## Cost Model

**Reduced ETL builds.** Reducing the ETL build window can reduce the amount of data Kubecost is requested to process, which can reduce resource consumption.

{% hint style="warning" %}
`etlHourlyStoreDurationHours` can be set to `0` if hourly cost granularity is not required in your environment. Note, that some features on the Savings page default to using hourly data, but can be toggled to use daily data.
{% endhint %}

```yaml
kubecostModel:
  etlDailyStoreDurationDays: 7
  etlHourlyStoreDurationHours: 0
```

**Lower query concurrency**. Lowering query concurrency for the Kubecost ETL build will mean ETL takes longer to build, but consumes less memory. The default value is: `5`. This can be adjusted with the [Helm value](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.93.2/cost-analyzer/values.yaml#L272):

```yaml
kubecostModel:
  maxQueryConcurrency: 1
```

**Lower query duration**. Lowering query duration results in Kubecost querying for smaller windows when building ETL data. This can lead to slower ETL build times, but lower memory peaks because of the smaller datasets. The default values is: `1440` This can be tuned with the [Helm value](https://github.com/kubecost/cost-analyzer-helm-chart/blob/fa0b00de5a186e658ccb66792bcdc3b77c4170e9/cost-analyzer/templates/cost-analyzer-deployment-template.yaml#L817):

```yaml
kubecostModel:
  maxPrometheusQueryDurationMinutes: 300
```

**Lower query resolution.** Lowering query resolution will reduce memory consumption but will cause short running pods to be sampled and rounded to the nearest interval for their runtime. The default value is: `300s`. This can be tuned with the Helm value:

```yaml
kubecostModel:
  etlResolutionSeconds: 600
```

**Soft memory limit.**  Optionally enabling impactful memory thresholds can ensure the Go runtime garbage collector throttles at more aggressive frequencies at or approaching the soft limit. There is not a one-size fits all value here, and users looking to tune the parameters should be aware that lower values may reduce overall performance if setting the value too low. If users set the the `resources.requests` memory values appropriately, using the same value for `softMemoryLimit` will instruct the Go runtime to keep its heap acquisition and release within the same bounds as the expectations of the pod memory use. More info on this environment variable can be found in [A Guide to the Go Garbage Collector](https://tip.golang.org/doc/gc-guide).

```yaml
kubecostModel:
  softMemoryLimit: 10GiB
```

## Aggregator

Please refer to the [Aggregator docs](/install-and-configure/install/multi-cluster/federated-etl/aggregator.md) for more detaild configuration and troubleshooting information.

**Lower retention period.** How much data to ingest from the federated store bucket, and how much data to keep in the DB before rolling the data off. Reducing these numbers will reduce load on aggregator. By default these are set to `91` and `49` respectively.

{% hint style="warning" %}
`etlHourlyStoreDurationHours` can be set to `0` if hourly cost granularity is not required in your environment. Note, that some features on the Savings page default to using hourly data, but can be toggled to use daily data.
{% endhint %}

```yaml
kubecostAggregator:
  etlDailyStoreDurationDays: 61
  etlHourlyStoreDurationHours: 0
```

**Lower concurrency.** By default these should all be set to `1`.

```yaml
kubecostAggregator:
  dbReadThreads: 1
  dbWriteThreads: 1
  dbConcurrentIngestionCount: 1
```

**Set rough memory limits.** By default these are set to `0GB` which means no limit. Once a baseline memory usage is established, it can be helpful to set these limits such that `dbMemoryLimit + dbWriteMemoryLimit <= memoryAvailableToAggregatorPod`.

{% hint style="warning" %}
Setting these values too aggressively low can result in OutOfMemory errors.
{% endhint %}

```yaml
kubecostAggregator:
  dbMemoryLimit: 0GB
  dbWriteMemoryLimit: 0GB
```

## Prometheus

**Lower scrape interval**. Fewer data points scraped from Prometheus means less data to collect and store, at the cost of Kubecost making estimations that possibly miss spikes of usage or short running pods. The default value is: `60s`. This can be tuned in the Helm values for the Prometheus scrape job.

```yaml
prometheus:
  server:
    global:
      scrape_interval: 5m
```

**Retention**. Kubecost and its accompanying Prometheus collect a reduced set of metrics that allow for lower resource/storage usage than a standard Prometheus deployment:

```yaml
prometheus:
  server:
    retention: 2d
```
