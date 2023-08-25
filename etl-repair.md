# Repair Kubecost ETLs

Kubecost's extract, transform, load (ETL) process is a computed cache built upon Prometheus metrics and cloud billing data, from which nearly all API requests made by the user and the Kubecost frontend currently rely upon.

The ETL data is stored in a `PersistentVolume` mounted to the `kubecost-cost-analyzer` pod. In the event that you lose or are looking to rebuild the ETL data, the following endpoints should be used.

{% hint style="info" %}
Configuring [ETL Backups](etl-backup.md) can prevent situations where you would need to repair large amounts of missing ETL data. This is not required in [Federated ETL](federated-etl.md) environments.
{% endhint %}

## 1. Repair Asset ETL

The Asset ETL builds upon the Prometheus metrics listed [here](user-metrics.md). It's important to ensure that you are able to [query for Prometheus or Thanos](prometheus.md) data for the specified `window` you use. Otherwise, an absence of metrics will result in an empty ETL. Learn more about this API in our [CloudCost Diagnostic APIs](https://docs.kubecost.com/apis/apis-overview/cloudcost-diagnostic-apis) doc.

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

The Allocation ETL builds upon all previous Asset data to compute cost and resource allocations for Kubernetes entities. Read our [Kubecost Diagnostics](https://docs.kubecost.com/troubleshooting/diagnostics) doc for more info.

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

## 3. Repair CloudUsage ETL

The CloudUsage ETL pulls information from your cloud billing integration. Ensure it's been configured properly, otherwise, no data will be retrieved. Review our [Cloud Billing Integrations](https://docs.kubecost.com/install-and-configure/install/cloud-integration) doc for more info.

{% code overflow="wrap" %}
```bash
# Repair: /model/etl/cloudUsage/repair?window=
$ curl "https://kubecost.your.com/model/etl/cloudUsage/repair?window=2023-01-01T00:00:00Z,2023-01-04T00:00:00Z"
{"code":200,"data":"Cloud Usage Repair process has begun for [2023-01-01T00:00:00+0000, 2023-01-04T00:00:00+0000) for all providers"}

# Check logs to watch this job run until completion
$ kubectl logs deploy/kubecost-cost-analyzer | grep CloudUsage
```
{% endcode %}

## 4. Run Reconciliation Pipeline

The Reconciliation Pipeline reconciles the existing ETL with the newly gathered data in the CloudUsage ETL, further ensuring parity between Kubecost and your cloud bill.

{% code overflow="wrap" %}
```bash
# Repair: /model/etl/asset/reconciliation/repair?window=
$ curl "https://kubecost.your.com/model/etl/asset/reconciliation/repair?window=2023-01-01T00:00:00Z,2023-01-04T00:00:00Z"
{"code":200,"data":"Reconciliation Repair process has begun for [2023-01-01T00:00:00+0000, 2023-01-04T00:00:00+0000) for all providers"}

# Check logs to watch this job run until completion
$ kubectl logs deploy/kubecost-cost-analyzer | grep Reconciliation
```
{% endcode %}

## Repairs in Federated ETL environments

In a Federated ETL environment, each individual Kubecost deployment builds its own ETL data before pushing it to the bucket. Therefore the repair commands above must be run on each affected cluster.

After a repair has been completed on any cluster in your environment, the Kubecost Federator will detect the new data, re-federate the ETL data, then place the merged data into the `/federated/combined` directory in the bucket. The Federator runs 5 minutes after startup, and every 30 minutes afterwards.

{% code overflow="wrap" %}
```bash
$ kubectl logs deploy/kubecost-federator | grep '\[assets\]\[1d\]' 
INF Federator[assets][1d]: Running Federator on 2 clusters: [kubecost-fedetl-agent kubecost-fedetl-primary]
INF Federator[assets][1d]: Checking for modified files for cluster 'kubecost-fedetl-agent'...
INF Federator[assets][1d]: Checking for modified files for cluster 'kubecost-fedetl-primary'...
INF Federator[assets][1d]: Successfully merged files for '1690761600-1690848000' from federated clusters

$ kubectl logs deploy/kubecost-federator | grep '\[allocations\]\[1d\]'
INF Federator[allocations][1d]: Running Federator on 2 clusters: [kubecost-fedetl-agent kubecost-fedetl-primary]
INF Federator[allocations][1d]: Checking for modified files for cluster 'kubecost-fedetl-agent'...
INF Federator[allocations][1d]: Checking for modified files for cluster 'kubecost-fedetl-primary'...
INF Federator[allocations][1d]: loading file '1690761600-1690848000' for cluster kubecost-fedetl-agent
INF Federator[allocations][1d]: loading file '1690761600-1690848000' for cluster kubecost-fedetl-primary
INF Federator[allocations][1d]: Successfully merged files for '1690761600-1690848000' from federated clusters
```
{% endcode %}

## Troubleshooting

If the ETL data looks incorrect, or you see one of the following error messages, there are several things to check:

{% code overflow="wrap" %}
```
[Error] ETL: CloudAsset[*****************]: Build[******]: 
MergeRange error: boundary error: requested [2022-03-26T00:00:00+0000, 2022-04-02T00:00:00+0000); supported [2022-03-29T00:00:00+0000, 2022-04-30T00:00:00+0000): 
ETL: Asset[1d] is 100.0% complete
```
{% endcode %}

{% code overflow="wrap" %}
```
WRN ETL: Asset[1h]: Repair: error: cannot repair [2022-11-05T00:00:00+0000, 2022-11-06T00:00:00+0000): coverage is [2022-12-01T21:00:00+0000, 2022-12-02T23:00:00+0000)
```
{% endcode %}

* Verify that Prometheus or Thanos metrics exist consistently during the time window you wish to repair
* For installs using Prometheus verify retention is long enough to meet the requested repair window. By default `.Values.prometheus.server.retention` is set to 15 days.
* For multi-cluster deployments verify the Thanos Store `--min-time` is long enough to meet the requested repair window. This is set with `.Values.thanos.store.extraArgs`.

### Federation failing for Asset and Allocation data in v1.104

In v1.104 of Kubecost, you may experience incorrect data display if running the [Federated ETL](/federated-etl.md). Specifically you may see that your asset prices are correct but heavily consist of "Adjustments", and that your allocation's idle costs are incorrect. To fix this, perform the following recovery steps:

1. Identify the data range for your affected data. This will be used later.
2. Disable reconciliation by setting the Helm flag:

   ```yaml
   kubecostModel:
     etlAssetReconciliationEnabled: false
   ```

3. [Upgrade to a fixed version of Kubecost](https://docs.kubecost.com/install-and-configure/install#updating-kubecost). For best results, upgrade to the most recent version.
4. For both Assets and Allocations, repair the affected dates on the primary cluster. This will only repair data from the primary cluster, not any secondary clusters. If repairing dates beyond your primary cluster's Prometheus retention, there may be data loss for your primary cluster. Refer to the instructions above for `/model/etl/asset/repair` and `/model/etl/allocation/repair`.
5. After Asset and Allocation data has been repaired, restart the Federator pod. This will force the Federator to re-federate the data upon 5 minutes of startup. Confirm the procedure has worked by validating some of the following:
   1. Query the last 7 days of data and observe reasonable unadjusted data.
   2. Review the Federator's logs. Example shown above.
   3. Check the following directories in your storage bucket, to see that the files for impacted dates have been recently modified. If your data has not been re-federated, you may need to manually delete the files for impacted dates and perform Step 4 again.
      1. `/federated/combined/etl/bingen/allocations/1d`
      2. `/federated/combined/etl/bingen/assets/1d`
6. Reenable reconciliation by setting the Helm flag:

   ```yaml
   kubecostModel:
     etlAssetReconciliationEnabled: true
   ```
