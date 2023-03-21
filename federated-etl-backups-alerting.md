# Federated ETL Backups and Alerting

This doc provides recommendations to improve the stability and recoverability of your Kubecost data when deploying in a Federated ETL architecture.

  > **Note**: The Federated ETL Architecture is only supported on Kubecost Enterprise plans.

## Option 1: Increase Prometheus retention

Kubecost can rebuild its data (ETLs) using the Prometheus metrics from each cluster. It is strongly recommended to retain local cluster Prometheus metrics that meet an organization's disaster recovery requirements.

```yaml
prometheus:
  server:
    retention: 21d
```

## Option 2: Metrics backup

For long term storage of Prometheus metrics, we recommend setting up a Thanos sidecar container to push Prometheus metrics to a cloud storage bucket.

```yaml
prometheus:
  extraArgs:
    storage.tsdb.min-block-duration: 2h
    storage.tsdb.max-block-duration: 2h
  server:
    sidecarContainers:
    - name: thanos-sidecar
      image: thanosio/thanos:latest
      args:
        - sidecar
        - --prometheus.url=http://127.0.0.1:9090
        - --objstore.config-file=/etc/config/object-store.yaml
```

If deploying Kubecost's bundled Prometheus, you can configure the thanos-sidecar following [this example](https://github.com/kubecost/cost-analyzer-helm-chart/blob/522c51b34121294c6f4c2f1423022938cdb14622/cost-analyzer/values-thanos.yaml#L23-L64). Additionally, ensure you [configure the `object-store.yaml`](./long-term-storage.md) so the thanos-sidecar has the necessary permissions to read/write to the cloud storage bucket.

## Option 3: Bucket versioning

Use your cloud service provider's bucket versioning feature to take frequent snapshots of the bucket holding your Kubecost data (ETL files and Prometheus metrics).

* [AWS: Using versioning in S3 buckets](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html)
* [Azure: Blob versioning](https://learn.microsoft.com/en-us/azure/storage/blobs/versioning-overview)
* [GCP: Use Object Versioning](https://cloud.google.com/storage/docs/using-object-versioning)

## Option 4: Alerting

Configure Prometheus [Alerting rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting_rules/) or [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) to get notified when you are losing metrics or when metrics deviate beyond a known standard.
