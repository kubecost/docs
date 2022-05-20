#### Kubecost can run on clusters with thousands of nodes when resource consumption is properly tuned. Here's a chart with some of the steps you can take to tune kubecost, along with descriptions of each.

![Memory Reduction Steps (3)](https://user-images.githubusercontent.com/453512/169488783-53687dfc-a687-48a6-8f1a-a52ef493594e.png)

## On Secondaries: Disabling Cloud Assets and Running Kubecost in Agent Mode/With ETL and caching disabled
* Cloud Assets for all accounts can be pulled in on just primaries by pointing kubecost to one or more management accounts.
* Secondaries can be configured strictly as metric emitters to save memory. 
* Learn more about how to best configure secondaries here: https://guide.kubecost.com/hc/en-us/articles/4423256582551-Kubecost-Secondary-Clusters

## Exclude Provider IDs in Cloud Assets
* Kubecost is capable of tracking each individual cloud billing line item; however on certain accounts this can be quite large.
* (AWS Only, GCP/Azure coming soon) If this is excluded, we don't cache granular data; instead we cache aggregate data and make an ad-hoc query to the cost and usage report to get granular data resulting in slow load times but less memory consumption.
* Learn more about how to configure this here: https://github.com/kubecost/docs/blob/main/cloud-integration.md#cloud-assets

## Lower Query Concurrency
* Lowering query concurrency for the Kubecost ETL build will mean ETL takes longer to build but lower memory consumption
* The default is 5
* This can be tuned with eg "--set kubecostModel.maxQueryConcurrency 1"

## Lower Query Resolution
* Lowering query resolution will reduce memory consumption but will cause short running pods to be sampled and rounded to the nearest interval for their runtimes
* The default is 300s
* This can be tuned with eg "--set kubecostModel.etlResolutionSeconds 600"

## Lower Scrape Interval
* Fewer data points scraped from prometheus means less data to collect and store, at the cost of Kubecost making estimations or possibly missing spikes of usage.
* The default is 60s
* This can be tuned here: https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values.yaml#L389

## Disable or stop scraping node exporter
* node-exporter is optional. Some health alerts will be disabled if node-exporter is disabled, but savings recommendations and core cost allocation will function as normal
* This can be disabled with eg "--set prometheus.server.nodeExporter.enabled false"

## Enable Filestore
* Filestore is an improvement over our legacy in-memory ETL store of prometheus data. It was optional in versions up to v1.94.0, but will become the default there.
* This can be enabled on older versions with eg "--set kubecostModel.etlFileStoreEnabled true" 
