Tuning Resource Consumption
===============

#### Kubecost can run on clusters with thousands of nodes when resource consumption is properly tuned. Here's a chart with some of the steps you can take to tune kubecost, along with descriptions of each.

![Memory Reduction Steps](https://user-images.githubusercontent.com/453512/171096603-0f0b600f-0452-4ae2-a001-e7c4a26e0ad5.png)


## On Secondaries: Disabling Cloud Assets and Running Kubecost in Agent Mode/With ETL and caching disabled
* Cloud Assets for all accounts can be pulled in on just primaries by pointing Kubecost to one or more management accounts. You can disable Cloud Assets on secondaries by setting `.Values.kubecostModel.etlCloudAsset: false`
* Secondaries can be configured strictly as metric emitters to save memory. 
* Learn more about how to best configure secondaries here: https://guide.kubecost.com/hc/en-us/articles/4423256582551-Kubecost-Secondary-Clusters

## Exclude Provider IDs in Cloud Assets
* Kubecost is capable of tracking each individual cloud billing line item; however on certain accounts this can be quite large.
* (AWS Only, GCP/Azure coming soon) If this is excluded, we don't cache granular data; instead we cache aggregate data and make an ad-hoc query to the cost and usage report to get granular data resulting in slow load times but less memory consumption.
* Learn more about how to configure this here: https://github.com/kubecost/docs/blob/main/cloud-integration.md#cloud-assets

## Lower Query Concurrency
* Lowering query concurrency for the Kubecost ETL build will mean ETL takes longer to build but lower memory consumption
* The default is 5
* This can be tuned with the Helm value "[--set kubecostModel.maxQueryConcurrency 1](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.93.2/cost-analyzer/values.yaml#L272)"

## Lower Query Resolution
* Lowering query resolution will reduce memory consumption but will cause short running pods to be sampled and rounded to the nearest interval for their runtimes
* The default is 300s
* This can be tuned with the Helm value "--set kubecostModel.etlResolutionSeconds 600"

## Longer Scrape Interval
* Fewer data points scraped from Prometheus means less data to collect and store, at the cost of Kubecost making estimations that possibly miss spikes of usage or short running pods
* The default is 60s
* This can be tuned [here](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.93.2/cost-analyzer/values.yaml#L389)

## Disable or stop scraping node exporter
* node-exporter is optional. Some health alerts will be disabled if node-exporter is disabled, but savings recommendations and core cost allocation will function as normal
* This can be disabled with the Helm value "[--set prometheus.server.nodeExporter.enabled false](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.93.2/cost-analyzer/values.yaml#L442)"

## Enable Filestore
* Filestore is an improvement over our legacy in-memory ETL store of Prometheus data. It was optional in versions up to v1.94.0, but will become the default afterward.
* This can be enabled on older versions with the Helm value "--set kubecostModel.etlFileStoreEnabled true"

<!--- {"article":"6446286863383","section":"1500002777682","permissiongroup":"1500001277122"} --->
