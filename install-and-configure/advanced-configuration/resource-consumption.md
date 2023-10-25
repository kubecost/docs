# Tuning Resource Consumption

Kubecost can run on clusters with thousands of nodes when resource consumption is properly tuned. Here's a chart with some of the steps you can take to tune Kubecost, along with descriptions of each.

![Memory Reduction Steps](/images/resource-consumption.png)

## Secondary clusters: Disabling Cloud Assets and running Kubecost in Agent Mode/With ETL and caching disabled

* Cloud Assets for all accounts can be pulled in on your primary cluster by pointing Kubecost to one or more management accounts. You can disable Cloud Assets on secondary clusters by setting the following Helm value:
  * `--set kubecostModel.etlCloudAsset=false`
* Secondaries can be configured strictly as metric emitters to save memory.
* Learn more about how to best configure secondary clusters [here](/install-and-configure/install/multi-cluster/secondary-clusters.md).

## Exclude provider IDs in Cloud Assets

* Kubecost is capable of tracking each individual cloud billing line item; however on certain accounts this can be quite large.
* (AWS Only, GCP/Azure coming soon) If this is excluded, we don't cache granular data; instead we cache aggregate data and make an ad-hoc query to the cost and usage report to get granular data resulting in slow load times but less memory consumption.
* Learn more about how to configure this [here](/install-and-configure/install/cloud-integration/README.md#cloud-assets).

## Lower query concurrency

* Lowering query concurrency for the Kubecost ETL build will mean ETL takes longer to build but lower memory consumption
* The default value is: `5`
* This can be tuned with the [Helm value](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.93.2/cost-analyzer/values.yaml#L272):
  * `--set kubecostModel.maxQueryConcurrency=1`

## Lower query duration

* Lowering query duration results in Kubecost querying for smaller windows when building ETL data. This can lead to slower ETL build times, but lower memory peaks because of the smaller datasets.
* The default values is: `1440`
* This can be tuned with the [Helm value](https://github.com/kubecost/cost-analyzer-helm-chart/blob/fa0b00de5a186e658ccb66792bcdc3b77c4170e9/cost-analyzer/templates/cost-analyzer-deployment-template.yaml#L817):
  * `--set kubecostModel.maxPrometheusQueryDurationMinutes=300`

## Lower query resolution

* Lowering query resolution will reduce memory consumption but will cause short running pods to be sampled and rounded to the nearest interval for their runtime
* The default value is: `300s`
* This can be tuned with the Helm value:
  * `--set kubecostModel.etlResolutionSeconds=600`

## Longer scrape interval

* Fewer data points scraped from Prometheus means less data to collect and store, at the cost of Kubecost making estimations that possibly miss spikes of usage or short running pods
* The default value is: `60s`
* This can be tuned in our [Helm values](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.93.2/cost-analyzer/values.yaml#L389) for the Prometheus scrape job.

## Disable or stop scraping node exporter

* Node-exporter is optional. Some health alerts will be disabled if node-exporter is disabled, but savings recommendations and core cost allocation will function as normal
* This can be disabled with the following [Helm values](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.93.2/cost-analyzer/values.yaml#L442):
  * `--set prometheus.server.nodeExporter.enabled=false`
  * `--set prometheus.serviceAccounts.nodeExporter.create=false`

## Enable Filestore

* Filestore is an improvement over our legacy in-memory ETL store of Prometheus data. It was optional in versions up to v1.94.0, but will become the default afterward.
* This can be enabled on older versions with the [Helm value](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.94.3/cost-analyzer/values.yaml#L271):
  * `--set kubecostModel.etlFileStoreEnabled=true`

## Soft memory limit field

* Optionally enabling impactful memory thresholds can ensure the Go runtime GC throttles at more aggressive frequencies at or approaching the soft limit.
* There is not a one-size fits all value here, and users looking to tune the parameters should be aware that lower values may reduce overall performance if setting the value too low. If users set the the `resources.requests` memory values appropriately, using the same value for `softMemoryLimit` will instruct the Go runtime to keep its heap acquisition and release within the same bounds as the expectations of the pod memory use.
* This can be tuned with the Helm value:
  * `--set kubecostModel.softMemoryLimit=<Units><B, KiB, MiB, GiB>`
* More info on this environment variable can be found [here](https://tip.golang.org/doc/gc-guide).
