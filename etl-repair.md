# Repair Kubecost ETLs

> **Note**: Configuring [ETL Backups](./etl-backup.md) can prevent situations where you would need to repair large amounts of missing ETL data.

Kubecost's ETL is a computed cache built upon Prometheus metrics and cloud billing data, from which nearly all API requests made by the user and the Kubecost frontend currently rely upon.

The ETL data is stored in a `PersistentVolume` mounted to the `kubecost-cost-analyzer` pod. In the event that you lose or are looking to rebuild the ETL data, the following endpoints should be used.

Because each ETL pipeline builds upon the previous, you need to repair them in the following order:

## 1. Repair Asset ETL

The Asset ETL builds upon the Prometheus metrics listed [here](./user-metrics.md). It's important to ensure that you are able to [query for Prometheus or Thanos](./prometheus.md) data for the specified `window` you use. Otherwise, an absence of metrics will result in an empty ETL. Further details about this API [here](./diagnostics.md).

> **Note**: If the `window` parameter is within `.Values.kubecostModel.etlHourlyStoreDurationHours`, this endpoint will repair both the daily `[1d]` and hourly `[1h]` Asset ETL.

```bash
# Repair
# /model/etl/asset/repair?window=
$ curl "https://kubecost.your.com/model/etl/asset/repair?window=2023-01-01T00:00:00Z,2023-01-04T00:00:00Z"
{"code":200,"data":"Repairing Asset ETL"}

# Check logs to watch this job run until completion
$ kubectl logs deploy/kubecost-cost-analyzer | grep Asset
INF ETL: Asset[1d]: ETLStore.Repair[cfDKJ]: repairing 2023-01-01 00:00:00 +0000 UTC, 2023-01-04 00:00:00 +0000 UTC
INF ETL: Asset[1d]: AggregatedStore.Run[fvkKR]: run: aggregated [2023-01-01T00:00:00+0000, 2023-01-02T00:00:00+0000) from 19 to 3 in 68.417µs
INF ETL: Asset[1d]: AggregatedStore.Run[fvkKR]: run: aggregated [2023-01-02T00:00:00+0000, 2023-01-03T00:00:00+0000) from 19 to 3 in 68.417µs
INF ETL: Asset[1d]: AggregatedStore.Run[fvkKR]: run: aggregated [2023-01-03T00:00:00+0000, 2023-01-04T00:00:00+0000) from 19 to 3 in 68.417µs
```

## 2. Repair CloudUsage ETL

The CloudUsage ETL pulls information from your cloud billing integration. Ensure it's been configured properly, otherwise no data will be retrieved. Further details about this API [here](./cloud-integration.md).

```bash
# Repair
# /model/etl/cloudUsage/repair?window=
$ curl "https://kubecost.your.com/model/etl/cloudUsage/repair?window=2023-01-01T00:00:00Z,2023-01-04T00:00:00Z"
{"code":200,"data":"Cloud Usage Repair process has begun for [2023-01-01T00:00:00+0000, 2023-01-04T00:00:00+0000) for all providers"}

# Check logs to watch this job run until completion
$ kubectl logs deploy/kubecost-cost-analyzer | grep CloudUsage
```

## 3. Run Reconciliation Pipeline

The Reconciliation Pipeline reconciles the existing Asset ETL with the newly gathered data in the CloudUsage ETL, further ensuring parity between Kubecost and your cloud bill. Further details about this API [here](./cloud-integration.md).

```bash
# Repair
# /model/etl/asset/reconciliation/repair?window=
$ curl "https://kubecost.your.com/model/etl/asset/reconciliation/repair?window=2023-01-01T00:00:00Z,2023-01-04T00:00:00Z"
{"code":200,"data":"Reconciliation Repair process has begun for [2023-01-01T00:00:00+0000, 2023-01-04T00:00:00+0000) for all providers"}

# Check logs to watch this job run until completion
$ kubectl logs deploy/kubecost-cost-analyzer | grep Reconciliation
```

## 4. Repair Allocation ETL

The Allocation ETL builds upon all previous data to compute cost and resource allocations for Kubernetes entites. Further details about this API [here](./diagnostics.md).

> **Note**: If the `window` parameter is within `.Values.kubecostModel.etlHourlyStoreDurationHours`, this endpoint will repair both the daily `[1d]` and hourly `[1h]` Allocation ETL.

```bash
# Repair
# /model/etl/allocation/repair?window=
$ curl "https://kubecost.your.com/model/etl/allocation/repair?window=2023-01-01T00:00:00Z,2023-01-04T00:00:00Z"
{"code":200,"data":"Repairing Allocation ETL"}

# Check logs to watch this job run until completion
$ kubectl logs deploy/kubecost-cost-analyzer | grep Allocation
INF ETL: Allocation[1d]: ETLStore.Repair[rptgQ]: repairing 2023-01-01 00:00:00 +0000 UTC, 2023-01-04 00:00:00 +0000 UTC
INF ETL: Allocation[ETL[allocations][1d]]: Repair[rptgQ]: starting [2023-01-01T00:00:00+0000, 2023-01-02T00:00:00+0000)
INF ETL: Allocation[ETL[allocations][1d]]: Repair[rptgQ]: starting [2023-01-02T00:00:00+0000, 2023-01-03T00:00:00+0000)
INF ETL: Allocation[ETL[allocations][1d]]: Repair[rptgQ]: starting [2023-01-03T00:00:00+0000, 2023-01-04T00:00:00+0000)
```

## Troubleshooting

If the ETL data looks incorrect, or you see one of the following error messages, there are several things to check:

```txt
[Error] ETL: CloudAsset[*****************]: Build[******]: 
MergeRange error: boundary error: requested [2022-03-26T00:00:00+0000, 2022-04-02T00:00:00+0000); supported [2022-03-29T00:00:00+0000, 2022-04-30T00:00:00+0000): 
ETL: Asset[1d] is 100.0% complete
```

```txt
WRN ETL: Asset[1h]: Repair: error: cannot repair [2022-11-05T00:00:00+0000, 2022-11-06T00:00:00+0000): coverage is [2022-12-01T21:00:00+0000, 2022-12-02T23:00:00+0000)
```

* Verify that Prometheus or Thanos metrics exist consistently during the time window you wish to repair
* For installs using Prometheus verify retention is long enough to meet the requested repair window. By default `.Values.prometheus.server.retention` is set to 15 days.
* For multi-cluster deployments verify the Thanos Store `--min-time` is long enough to meet the requested repair window. This is set with `.Values.thanos.store.extraArgs`.
