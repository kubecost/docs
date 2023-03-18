# Federated ETL - Backups and Alerting

This doc provides recommendations to improve the stability and recoverability of your Kubecost data when deploying in a Federated ETL architecture.

> **Note**: The Federated ETL Architecture requires an Enterprise license.

## 1. Increase Prometheus retention

Kubecost can rebuild its data (ETLs) using the Prometheus metrics from each cluster. It is strongly recommended to retain local cluster Prometheus metrics that meet an organization's disaster recovery requirements.

```yaml
prometheus:
  server:
    extraArgs:
      storage.tsdb.retention: 2w
```

## 2. Metrics backup

For long term storage of Prometheus metrics, we recommend setting up a Thanos sidecar to push Prometheus metrics to a cloud storage bucket.

## 3. Bucket versioning

Use your cloud service provider's bucket versioning feature to take frequent snapshots of the bucket holding your Kubecost data (ETLs and Prometheus metrics)

* [AWS - Using versioning in S3 buckets](https://docs.aws.amazon.com/AmazonS3/latest/userguide/Versioning.html)
* [Azure - Blob versioning](https://learn.microsoft.com/en-us/azure/storage/blobs/versioning-overview)
* [GCP - Use Object Versioning](https://cloud.google.com/storage/docs/using-object-versioning)

## 4. Alerting

