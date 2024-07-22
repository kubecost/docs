# Tuning Resource Consumption

## Lower query concurrency

Lowering query concurrency for the Kubecost ETL build will mean ETL takes longer to build, but consumes less memory. The default value is: `5`. This can be adjusted with the [Helm value](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.93.2/cost-analyzer/values.yaml#L272):

`--set kubecostModel.maxQueryConcurrency=1`

## Lower query duration

Lowering query duration results in Kubecost querying for smaller windows when building ETL data. This can lead to slower ETL build times, but lower memory peaks because of the smaller datasets. The default values is: `1440` This can be tuned with the [Helm value](https://github.com/kubecost/cost-analyzer-helm-chart/blob/fa0b00de5a186e658ccb66792bcdc3b77c4170e9/cost-analyzer/templates/cost-analyzer-deployment-template.yaml#L817):

`--set kubecostModel.maxPrometheusQueryDurationMinutes=300`

## Lower query resolution

Lowering query resolution will reduce memory consumption but will cause short running pods to be sampled and rounded to the nearest interval for their runtime. The default value is: `300s`. This can be tuned with the Helm value:

`--set kubecostModel.etlResolutionSeconds=600`

## Lengthen scrape interval

Fewer data points scraped from Prometheus means less data to collect and store, at the cost of Kubecost making estimations that possibly miss spikes of usage or short running pods. The default value is: `60s`. This can be tuned in the Helm values for the Prometheus scrape job.

## Keep node exporter disabled

The Node Exporter is disabled by default, and is an optional feature. Some health alerts will be disabled if the Node Exporter is disabled, but savings recommendations and core cost allocation will function normally. You can enable the Node Exporter with the following Helm values:

```
--set prometheus.server.nodeExporter.enabled=true
--set prometheus.serviceAccounts.nodeExporter.create=true
```

## Soft memory limit field

Optionally enabling impactful memory thresholds can ensure the Go runtime garbage collector throttles at more aggressive frequencies at or approaching the soft limit. There is not a one-size fits all value here, and users looking to tune the parameters should be aware that lower values may reduce overall performance if setting the value too low. If users set the the `resources.requests` memory values appropriately, using the same value for `softMemoryLimit` will instruct the Go runtime to keep its heap acquisition and release within the same bounds as the expectations of the pod memory use. This can be tuned with the Helm value:

`--set kubecostModel.softMemoryLimit=<Units><B, KiB, MiB, GiB>`

More info on this environment variable can be found in [A Guide to the Go Garbage Collector](https://tip.golang.org/doc/gc-guide).
