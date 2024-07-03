# Repair Kubecost ETLs

Kubecost's extract, transform, load (ETL) files are a computed cache built upon Prometheus metrics and cloud billing data, from which nearly all API requests made by the user and the Kubecost frontend currently rely upon. The ETL data is stored in a `PersistentVolume` mounted to the `kubecost-cost-analyzer` pod. In most [multicluster environments](/install-and-configure/install/multi-cluster/multi-cluster.md), the ETL data is also pushed to object storage.

## When should you repair ETL data

There are numerous reasons why you may need to repair ETL data. Please reach out to Kubecost Support for further guidance. The following conditions are cases in which repairing ETL data may help, but may not be the root cause of the issue:

- If Kubecost is not showing data for a specific time window
- If Kubecost's Assets data for a specific cluster is incorrect
- If Kubecost's Allocation data for a specific cluster is incorrect

In an enterprise multi-cluster environment, each individual Kubecost deployment builds its own ETL data before pushing it to the bucket. Therefore to repair data from an affected cluster, you must port-forward to that cluster's Kubecost deployment then run the repair command. After a repair has been completed on any cluster in your environment, the Kubecost Aggregator will detect that the ETL file has been recently modified, and ingest the new data into its database.

{% hint style="warning" %}
Remember that ETL files are computed based on Prometheus metrics. Before repairing ETL files, please confirm that your Prometheus server is still retaining metrics for the dates you are aiming to repair. `.Values.prometheus.server.retention`.
{% endhint %}

## 1. Repair Asset ETL

The Asset ETL builds upon the Prometheus metrics listed [here](/architecture/user-metrics.md). It's important to ensure that you are able to [query for Prometheus](prometheus.md) data for the specified `window` you use. Otherwise, an absence of metrics will result in an empty ETL.

{% hint style="info" %}
If the `window` parameter is within `.Values.kubecostModel.etlHourlyStoreDurationHours`, this endpoint will repair both the daily `[1d]` and hourly `[1h]` Asset ETL.
{% endhint %}

{% code overflow="wrap" %}
```bash
# Repair: /model/etl/asset/repair?window=
$ curl "https://kubecost.your.com/model/etl/asset/repair?window=2023-01-01T00:00:00Z,2023-01-04T00:00:00Z"
{"code":200,"data":"Repairing Asset ETL"}

# Check logs to watch this job run until completion
$ kubectl logs deploy/kubecost-cost-analyzer | grep "Asset\[1d\]"
INF ETL: Asset[1d]: ETLStore.Repair[cfDKJ]: repairing 2023-01-01 00:00:00 +0000 UTC, 2023-01-04 00:00:00 +0000 UTC
INF ETL: Asset[1d]: AggregatedStore.Run[fvkKR]: run: aggregated [2023-01-01T00:00:00+0000, 2023-01-02T00:00:00+0000) from 19 to 3 in 68.417µs
INF ETL: Asset[1d]: AggregatedStore.Run[fvkKR]: run: aggregated [2023-01-02T00:00:00+0000, 2023-01-03T00:00:00+0000) from 19 to 3 in 68.417µs
INF ETL: Asset[1d]: AggregatedStore.Run[fvkKR]: run: aggregated [2023-01-03T00:00:00+0000, 2023-01-04T00:00:00+0000) from 19 to 3 in 68.417µs
```
{% endcode %}

## 2. Repair Allocation ETL

The Allocation ETL builds upon all previous Asset data to compute cost and resource allocations for Kubernetes entities. Read our [Kubecost Diagnostics](diagnostics.md) doc for more info.

{% hint style="info" %}
If the `window` parameter is within `.Values.kubecostModel.etlHourlyStoreDurationHours`, this endpoint will repair both the daily `[1d]` and hourly `[1h]` Allocation ETL.
{% endhint %}

{% code overflow="wrap" %}
```bash
# Repair: /model/etl/allocation/repair?window=
$ curl "https://kubecost.your.com/model/etl/allocation/repair?window=2023-01-01T00:00:00Z,2023-01-04T00:00:00Z"
{"code":200,"data":"Repairing Allocation ETL"}

# Check logs to watch this job run until completion
$ kubectl logs deploy/kubecost-cost-analyzer | grep "Allocation\[1d\]"
INF ETL: Allocation[1d]: ETLStore.Repair[lSGre]: repairing 2023-01-01 00:00:00 +0000 UTC, 2023-01-04 00:00:00 +0000 UTC
INF Allocation[1d]: AggregatedStoreDriver[hvfrl]: run: aggregated [2023-01-01T00:00:00+0000, 2023-01-02T00:00:00+0000) from 283 to 70 in 4.917963ms
INF Allocation[1d]: AggregatedStoreDriver[hvfrl]: run: aggregated [2023-01-02T00:00:00+0000, 2023-01-03T00:00:00+0000) from 130 to 62 in 983.216µs
INF Allocation[1d]: AggregatedStoreDriver[hvfrl]: run: aggregated [2023-01-03T00:00:00+0000, 2023-01-04T00:00:00+0000) from 130 to 62 in 1.462092ms
```
{% endcode %}

## 3. Repair CloudCost ETL

The CloudCost ETL pulls information from your cloud billing integration. Ensure it's been configured properly, otherwise, no data will be retrieved. Review our [Cloud Billing Integrations](/install-and-configure/install/cloud-integration/README.md) doc for more info.

{% code overflow="wrap" %}
```bash
# Repair: /model/cloudCost/repair?window=
$ curl "https://kubecost.your.com/model/cloudCost/repair?window=2023-01-01T00:00:00Z,2023-01-04T00:00:00Z"
{"code":200,"data":"Rebuilding Cloud Usage For All Providers"}

# Check logs to watch this job run until completion
$ kubectl logs deploy/kubecost-cloud-analyzer | grep CloudCost
# or
$ kubectl logs deploy/kubecost-cloud-cost
```
{% endcode %}

## Troubleshooting

### Repairing ETL by port-forwarding

In this doc, we reference repairs using the `https://kubecost.your.com` URL. If that is not accessible to you, you can instead port-forward to the `kubecost-cost-analyzer` pod and use `localhost`.

Method 1:

{% code overflow="wrap" %}
```bash
# Terminal 1
kubectl port-forward deploy/kubecost-cost-analyzer 9090:9090

# Terminal 2
curl "localhost:9090/model/etl/asset/repair?window=2023-01-01T00:00:00Z,2023-01-04T00:00:00Z"
```
{% endcode %}

Method 2:

{% code overflow="wrap" %}
```bash
# Terminal 1
kubectl port-forward deploy/kubecost-cost-analyzer 9003:9003

# Terminal 2
curl "localhost:9003/etl/asset/repair?window=2023-01-01T00:00:00Z,2023-01-04T00:00:00Z"
```
{% endcode %}

### Error messages

If the ETL data looks incorrect, or you see one of the following error messages, there are several things to check:

{% code overflow="wrap" %}
```bash
[Error] ETL: CloudAsset[*****************]: Build[******]: 
MergeRange error: boundary error: requested [2022-03-26T00:00:00+0000, 2022-04-02T00:00:00+0000); supported [2022-03-29T00:00:00+0000, 2022-04-30T00:00:00+0000): 
ETL: Asset[1d] is 100.0% complete
```
{% endcode %}

{% code overflow="wrap" %}
```bash
WRN ETL: Asset[1h]: Repair: error: cannot repair [2022-11-05T00:00:00+0000, 2022-11-06T00:00:00+0000): coverage is [2022-12-01T21:00:00+0000, 2022-12-02T23:00:00+0000)
```
{% endcode %}

* Verify that Prometheus metrics exist consistently during the time window you wish to repair
* For installs using Prometheus verify retention is long enough to meet the requested repair window. `.Values.prometheus.server.retention`.
