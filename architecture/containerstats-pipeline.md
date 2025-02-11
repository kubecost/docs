# ContainerStats Pipeline

The ContainerStats pipeline builds statistical representations of individual containers' resource usage over time. The pipeline is part of the `cost-model` container.

## Helm configuration

The ContainerStats pipeline is enabled by default. To disable it, set the following flag to `false`:

```yaml
kubecostModel:
  containerStatsEnabled: false
```

Ensure you allow roughly two hours for the pipeline to run before issuing a query which leverages this pipeline.

## Behavior

The pipeline builds 24 hour "windows" of data. It only builds complete windows, e.g. if now is `2003-08-23T08:30:00Z`, the pipeline will only build up to the window from `2003-08-22T00:00:00Z` to `2003-08-23T00:00:00Z`.

The pipeline will return an error response if a requested time range of data contains any windows (24 hour chunks) are _expected_ (should be in the store) but not _available_ (the pipeline has not yet built and loaded a complete set of data into the store).

## Usage in Kubecost APIs

### Request right-sizing recommendation (v2)

The primary user of ContainerStats pipeline data is the [request right-sizing recommendation API (v2)](/apis/savings-apis/api-request-right-sizing-v2.md). ContainerStats data is used for quantile-based recommendations.

### Debugging

There is an API for introspecting pipeline data available at `/model/containerstats/quantiles`. It does not have a stable schema and is not supported as an official product feature. It is only intended for limited debugging.

## Logs

All ContainerStats-related log messages should contain `ContainerStats` or `ContainerStatsSet`. The pipeline logs a few things at `INFO` level to show that the pipeline is running successfully. Much greater detail is available at the `DEBUG` level. See [the official instructions](https://github.com/kubecost/cost-analyzer-helm-chart#adjusting-log-output) to learn how to change the log level.

## Configuration

The ContainerStats pipeline's behavior is controller by a few different environment variables.

| Environment variable                        | Helm chart value                                  | Description                                                                                                                                                                                                                                                                                    |
| ------------------------------------------- | ------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `CONTAINER_STATS_ENABLED`                   | `kubecostModel.containerStatsEnabled`             | Enables the pipeline.                                                                                                                                                                                                                                                                          |
| Prometheus/Thanos configuration             |                                                   | The pipeline inherits most of the existing Prometheus/Thanos configuration because it leverages the same client(s) used by the Asset and Allocation pipelines. Specific deviations will be mentioned.                                                                                          |
| `ETL_MAX_PROMETHEUS_QUERY_DURATION_MINUTES` | `kubecostModel.maxPrometheusQueryDurationMinutes` | The pipeline will obey this, but may fail to initialize if this is set below the minimum value supported by the pipeline (10 minutes).                                                                                                                                                         |
| "Storage" configuration                      |                                                   | The pipeline inherits most of the existing "store" configuration used by other pipelines like Asset and Allocation. This includes, but is not limited to: store duration, store type (file, federated, etc.), leader election, storage pathing, storage directory, bucket storage, and backup. |
