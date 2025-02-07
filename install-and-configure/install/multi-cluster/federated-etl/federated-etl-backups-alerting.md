# Federated ETL Backups and Alerting

{% hint style="info" %}
Federated ETL Architecture is a Kubecost Enterprise only feature.
{% endhint %}

This doc provides recommendations to improve the stability and recoverability of your Kubecost data when deploying in a Federated ETL architecture.

## Option 1: Increase Prometheus retention

Kubecost can rebuild its extract, transform, load (ETL) data using Prometheus metrics from each cluster. It is strongly recommended to retain local cluster Prometheus metrics that meet an organization's disaster recovery requirements.

```yaml
prometheus:
  server:
    retention: 21d
  # Ensure the volume is large enough to hold all metrics
  persistentVolume:
    size: 32Gi
    enabled: true
```

## Option 2: Metrics backup

For long term storage of Prometheus metrics, we recommend setting up a Thanos sidecar container to push Prometheus metrics to a cloud storage bucket.

```yaml
# This is an abridged example. Full example in link below.
prometheus:
  server:
    extraArgs:
      storage.tsdb.min-block-duration: 2h
      storage.tsdb.max-block-duration: 2h
    extraVolumes:
    - name: object-store-volume
      secret:
        secretName: kubecost-thanos
    sidecarContainers:
    - name: thanos-sidecar
      image: thanosio/thanos:v0.30.2
      args:
        - sidecar
        - --prometheus.url=http://127.0.0.1:9090
        - --objstore.config-file=/etc/config/object-store.yaml
      volumeMounts:
      - name: object-store-volume
        mountPath: /etc/config
      - name: storage-volume
        mountPath: /data
        subPath: ""
```

You can configure the Thanos sidecar following [this example](https://github.com/kubecost/poc-common-configurations/blob/c604c59286f96e8ca4be3b52d6e5ef6c0142be22/etl-federation/etl-fed-and-thanos-metrics/values-prometheus-thanos-sidecar.yaml) or [this example](https://github.com/kubecost/cost-analyzer-helm-chart/blob/522c51b34121294c6f4c2f1423022938cdb14622/cost-analyzer/values-thanos.yaml#L14-L64). Additionally, ensure you configure the following:

* [`object-store.yaml`](/install-and-configure/install/multi-cluster/thanos-setup/configuring-thanos.md) so the Thanos sidecar has permissions to read/write to the cloud storage bucket
* [`.Values.prometheus.server.global.external_labels.cluster_id`](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.101/cost-analyzer/values.yaml#L560-L561) so Kubecost is able to distinguish which metric belongs to which cluster in the Thanos bucket.

## Option 3: Bucket versioning

Use your cloud service provider's bucket versioning feature to take frequent snapshots of the bucket holding your Kubecost data (ETL files and Prometheus metrics).

* [AWS: Using versioning in S3 buckets](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html)
* [Azure: Blob versioning](https://learn.microsoft.com/en-us/azure/storage/blobs/versioning-overview)
* [GCP: Use Object Versioning](https://cloud.google.com/storage/docs/using-object-versioning)

## Option 4: Alerting

Configure Prometheus [Alerting rules](https://prometheus.io/docs/prometheus/latest/configuration/alerting\_rules/) or [Alertmanager](https://prometheus.io/docs/alerting/latest/alertmanager/) to get notified when you are losing metrics or when metrics deviate beyond a known standard.
