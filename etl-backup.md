ETL Backup
==========

Kubecost's ETL is a computed cache based on Prometheus's metrics, from which the user can perform all possible Kubecost queries. The ETL data is stored in a `PersistentVolume` mounted to the `kubecost-cost-analyzer` pod.

There are a number of reasons why you may want to backup this ETL data:

* to ensure a copy of your Kubecost data exists, so that you can restore the data if needed
* if you would like to reduce the amount of data stored in Prometheus (15 day retention window by default) or Thanos

## Option 1: Backup via Bash script

The simplest way to backup Kubecost's ETL is to copy the pod's ETL store to your local disk. You can then send that file to any other storage system of your choice. We provide a [script](https://github.com/kubecost/etl-backup) to do that.

To restore the backup, untar the results of the etl-backup script into the ETL directory pod.

```bash
kubectl cp -c cost-model <untarred-results-of-script> <kubecost-namespace>/<kubecost-pod-name>/var/configs/db/etl
```

There is also a Bash script available to restore the backup [here](https://github.com/kubecost/etl-backup/blob/main/upload-etl.sh).

## Option 2: Automated durable ETL backups and monitoring

We provide cloud storage backups for ETL backing storage. Backups are not the typical approach of "halt all reads/writes and dump the database." Instead, the backup system is a transparent feature that will always ensure that local ETL data is backed up, and if local data is missing, it can be retrieved from backup storage. This feature protects users from accidental data loss by ensuring that previously backed up data can be restored at runtime.

> **Note**: Durable backup storage functionality is only part of Kubecost Enterprise.

When the ETL pipeline collects data, it stores both daily and hourly (if configured) cost metrics on a configured storage. This defaults to a persistent volume based disk storage, but can be configured to use external durable storage on the following providers:

* AWS S3
* Azure Blob Storage
* Google Cloud Storage

### Step 1: Create storage configuration secret

This configuration secret follows the same layout documented for Thanos here: <https://thanos.io/v0.21/thanos/storage.md>

You will need to create a file named `object-store.yaml` using the chosen storage provider configuration (documented below), and run the following command to create the secret from this file:

```bash
kubectl create secret generic <YOUR_SECRET_NAME> -n kubecost --from-file=object-store.yaml
```

> **Note**: The file must be named `object-store.yaml`

**Existing Thanos users**

If you have already configured Thanos following [this documentation](https://github.com/kubecost/docs/blob/main/long-term-storage.md), you can reuse the previously created bucket configuration secret.

Setting `.Values.kubecostModel.etlBucketConfigSecret=kubecost-thanos` will enable the backup feature. This will backup all ETL data to the same bucket being used by Thanos.

**S3**

The configuration schema for S3 is documented here: [S3 Storage](https://thanos.io/v0.21/thanos/storage.md#s3). For reference, here's an example:

```yaml
type: S3
config:
  bucket: "my-bucket"
  endpoint: "s3.amazonaws.com"
  region: "us-west-2"
  access_key: "<AWS_ACCESS_KEY>"
  secret_key: "<AWS_SECRET_KEY>"
  insecure: false
  signature_version2: false
  put_user_metadata:
    "X-Amz-Acl": "bucket-owner-full-control"
```

**Google Cloud Storage**

The configuration schema for Google Cloud Storage is documented here: [Google Cloud Storage Storage](https://thanos.io/v0.21/thanos/storage.md/#gcs). For reference, here's an example:

```yaml
type: GCS
config:
  bucket: "my-bucket"
  service_account: |-
    {
      "type": "service_account",
      "project_id": "project",
      "private_key_id": "abcdefghijklmnopqrstuvwxyz12345678906666",
      "private_key": "-----BEGIN PRIVATE KEY-----\...\n-----END PRIVATE KEY-----\n",
      "client_email": "project@kubecost.iam.gserviceaccount.com",
      "client_id": "123456789012345678901",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/kubecost%40gitpods.iam.gserviceaccount.com"
    }    
```

**Azure**

The configuration schema for Azure is documented here: [Azure Storage](https://thanos.io/v0.21/thanos/storage.md/#azure). For reference, here's an example:

```yaml
type: AZURE
config:
  storage_account: "<STORAGE_ACCOUNT>"
  storage_account_key: "<STORAGE_ACCOUNT_KEY>"
  container: "my-bucket"
  endpoint: ""
```

### Step 2: Enable ETL backup in Helm values

If Kubecost was installed via Helm, ensure the following values are set.

```yaml
kubecostModel:
  etlFileStore: true
  etlBucketConfigSecret: <YOUR_SECRET_NAME>
```

### Compatibility

If you are using an existing disk storage option for your ETL data, enabling the durable backup feature will retroactively back up all previously stored data\*. This feature is also fully compatible with the existing S3 backup feature.

\* _If you are using a memory store for your ETL data with a local disk backup (`kubecostModel.etlFileStoreEnabled: false`), the backup feature will simply replace the local backup. In order to take advantage of the retroactive backup feature, you will need to update to file store (`kubecostModel.etlFileStoreEnabled: true`). This option is now enabled by default in the helm chart._

## Monitoring

Currently, this feature is still in development, but there is currently a status card available on the diagnostics page that will eventually show the status of the backup system:

![Diagnostic ETL Backup Status](https://raw.githubusercontent.com/kubecost/docs/main/images/diagnostics-etl-backup-status.png)

## Troubleshooting

In some scenarios like when using Memory store, setting `kubecostModel.etlHourlyStoreDurationHours` to a value of `48` hours or less will cause ETL backup files to become truncated. The current recomendation is to keep [etlHourlyStoreDurationHours](https://github.com/kubecost/cost-analyzer-helm-chart/blob/8fd5502925c28c56af38b0c4e66c4ec746761d50/cost-analyzer/values.yaml#L322) at its default of `49` hours.

Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/etl-backup.md)

<!--- {"article":"4407601811095","section":"4402815656599","permissiongroup":"1500001277122"} --->
