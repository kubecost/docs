Secondary Clusters Guide
========================

Secondary clusters are "agent only" clusters that send their metrics to a central storage-bucket (aka durable storage) that is accessed by the primary cluster to provide a ___single-pane-of-glass___ view into all aggregated cluster costs globally. This aggregated cluster view is exclusive to `Kubecost Enterprise`.

> Note: The UI on secondary clusters will appear broken. It meant for troubleshooting only.

This guide explains settings that can be tuned in order to run the minimum Kubecost components to run Kubecost more efficiently.

## Kubecost Global

Disable product caching and reduce query concurrency with the following parameters:

```
--set kubecostModel.warmCache=false
--set kubecostModel.warmSavingsCache=false
--set kubecostModel.etl=false
--set kubecostModel.etlCloudAsset
--set kubecostModel.maxQueryConcurrency=1
```

## Grafana

Grafana is not needed on secondary clusters.

```
--set global.grafana.enabled=false
--set global.grafana.proxy=false
```

## Prometheus

Kubecost and it’s accompanying Prometheus collect a reduced set of metrics that allow for lower resource/storage usage than a standard Prometheus deployment.

The following configuration options further reduce resource consumption when not using the Kubecost frontend:

```sh
--set prometheus.server.retention=2d
```

Potentially reduce retention even further, metrics are sent to the storage-bucket every 2 hours.

You can tune prometheus.server.persistentVolume.size depending on scale, or outright disable persistent storage.

## Thanos

Disable Thanos components. These are only used for troubleshooting on secondary clusters. See this guide for [troubleshooting via kubectl logs](https://guide.kubecost.com/hc/en-us/articles/4407595964695-Long-Term-Storage#troubleshooting).

> Note: Secondary clusters write to the global storage-bucket via the thanos-sidecar on the prometheus-server pod.

```sh
--set thanos.compact.enabled=false
--set thanos.bucket.enabled=false
--set thanos.query.enabled=false
--set thanos.queryFrontend.enabled=false
--set thanos.store.enabled=false
```

## Node-Exporter

You can disable node-exporter and the service account if cluster/node rightsizing recommendations are not required.

> Note: node-export must be disabled if there is an existing daemonset.<br>
> <https://guide.kubecost.com/hc/en-us/articles/4407601830679-Troubleshoot-Install#a-name-node-exporter-a-issue-failedscheduling-kubecost-prometheus-node-exporter>

## Helm Values

For reference, this is a list of the most common settings for efficient secondary clusters:

`secondary-clusters.yaml`
```yaml
kubecostModel:
  warmCache: false
  warmSavingsCache: false
  etl: false
  etlCloudAsset: false
  maxQueryConcurrency: 1
global:
  grafana:
    enabled: false
    proxy: false
prometheus:
  server:
    global:
      external_labels:
        # cluster_id should be unique for all clusters and the same value as .kubecostProductConfigs.clusterName
        cluster_id: clusterName
    retention: 2d
  # nodeExporter:
  #   enabled: false
  # serviceAccounts:
  #   nodeExporter:
  #     create: false
thanos:
  compact:
    enabled: false
  bucket:
    enabled: false
  query:
    enabled: false
  queryFrontend:
    enabled: false
  store:
    enabled: false
```

## Additional Resources

You can find complete installation guides and sample files on our repo:
<https://github.com/kubecost/poc-common-configurations>

Additional considerations are here: <https://guide.kubecost.com/hc/en-us/articles/6446286863383-Tuning-Resource-Consumption>

There are potentially other configuration options based on the specifics of different deployment requirements. Reach out to us below if you have any questions.

## <a name="help"></a>Additional Help
Please let us know if you run into any issues, we are here to help!

[Slack community](https://join.slack.com/t/kubecost/shared_invite/enQtNTA2MjQ1NDUyODE5LWFjYzIzNWE4MDkzMmUyZGU4NjkwMzMyMjIyM2E0NGNmYjExZjBiNjk1YzY5ZDI0ZTNhZDg4NjlkMGRkYzFlZTU) - check out #support for any help you may need & drop your introduction in the #general channel

Email: <team@kubecost.com>

---
Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/secondary-clusters.md)


<!--- {"article":"4423256582551","section":"4402829033367","permissiongroup":"1500001277122"} --->
