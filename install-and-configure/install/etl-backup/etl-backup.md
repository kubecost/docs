# ETL Backup

{% hint style="warning" %}
We do not recommend enabling ETL Backup in conjunction with [Federated ETL](/install-and-configure/install/multi-cluster/federated-etl/federated-etl.md).
{% endhint %}

Kubecost's extract, transform, load (ETL) data is a computed cache based on Prometheus's metrics, from which the user can perform all possible Kubecost queries. The ETL data is stored in a persistent volume mounted to the `kubecost-cost-analyzer` pod.

There are a number of reasons why you may want to backup this ETL data:

* To ensure a copy of your Kubecost data exists, so you can restore the data if needed
* To reduce the amount of historical data stored in Prometheus, and instead retain historical ETL data

## Option 1: Automated durable ETL backups and monitoring

Kubecost provides cloud storage backups for ETL backing storage. Backups are not the typical approach of "halt all reads/writes and dump the database." Instead, the backup system is a transparent feature that will always ensure that local ETL data is backed up, and if local data is missing, it can be retrieved from backup storage. This feature protects users from accidental data loss by ensuring that previously backed-up data can be restored at runtime.

{% hint style="info" %}
Durable backup storage functionality is supported with a Kubecost Enterprise plan.
{% endhint %}

When the ETL pipeline collects data, it stores daily and hourly (if configured) cost metrics on a configured storage. This defaults to a PV-based disk storage, but can be configured to use external durable storage on the following providers:

* AWS S3
* Azure Blob Storage
* Google Cloud Storage

### Step 1: Create storage configuration secret

This configuration secret follows the same layout documented for Thanos [here](https://thanos.io/v0.21/thanos/storage.md).

You will need to create a file named _object-store.yaml_ using the chosen storage provider configuration (documented below), and run the following command to create the secret from this file:

{% code overflow="wrap" %}
```bash
kubectl create secret generic <YOUR_SECRET_NAME> -n kubecost --from-file=object-store.yaml
```
{% endcode %}

The file must be named _object-store.yaml_.

<details>

<summary>Existing Thanos users</summary>

If you have already followed our [Configuring Thanos](/install-and-configure/install/multi-cluster/thanos-setup/configuring-thanos.md) guide, you can reuse the previously created bucket configuration secret.

Setting `.Values.kubecostModel.etlBucketConfigSecret=kubecost-thanos` will enable the backup feature. This will back up all ETL data to the same bucket being used by Thanos.

</details>

<details>

<summary>S3</summary>

The configuration schema for S3 can be found in this [Thanos documentation](https://thanos.io/v0.21/thanos/storage.md#s3). For reference, here's an example:

{% code overflow="wrap" %}
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
prefix: ""  # Optional. Specify a path within the bucket (e.g. "kubecost/etlbackup").
```
{% endcode %}

</details>

<details>

<summary>Google Cloud Storage</summary>

The configuration schema for Google Cloud Storage can be found in this [Thanos documentation](https://thanos.io/v0.21/thanos/storage.md/#gcs). For reference, here's an example:

{% code overflow="wrap" %}
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
prefix: ""  # Optional. Specify a path within the bucket (e.g. "kubecost/etlbackup").
```
{% endcode %}

</details>

<details>

<summary>Azure</summary>

The configuration schema for Azure can be found in this [Thanos documentation](https://thanos.io/v0.21/thanos/storage.md/#azure). For reference, here's an example:

{% code overflow="wrap" %}
```yaml
type: AZURE
config:
  storage_account: "<STORAGE_ACCOUNT>"
  storage_account_key: "<STORAGE_ACCOUNT_KEY>"
  container: "my-bucket"
  endpoint: ""
prefix: ""  # Optional. Specify a path within the bucket (e.g. "kubecost/etlbackup").
```
{% endcode %}

</details>

#### S3 compatible tooling

<details>

<summary>Storj</summary>

Because Storj is [S3 compatible](https://docs.storj.io/dcs/api-reference/s3-compatible-gateway/), it can be used as a drop-in replacement for S3. After an S3 Compatible Access Grant has been created, an example configuration would be:

{% code overflow="wrap" %}
```yaml
type: S3
config:
  bucket: "my-bucket"
  endpoint: "gateway.storjshare.io"
  access_key: "<STORJ_ACCESS_KEY>"
  secret_key: "<STORJ_SECRET_KEY>"
  insecure: false
  signature_version2: false
  http_config:
    idle_conn_timeout: 90s
    response_header_timeout: 2m
    insecure_skip_verify: false
  trace:
    enable: true
  part_size: 134217728
prefix: ""  # Optional. Specify a path within the bucket (e.g. "kubecost/etlbackup").
```
{% endcode %}

</details>

<details>

<summary>Hitachi Content Platform (HCP)</summary>

Because HCP is [S3 compatible](https://knowledge.hitachivantara.com/Documents/Storage/HCP\_for\_Cloud\_Scale/1.0.0/Adminstering\_HCP\_for\_cloud\_scale/Getting\_started/02\_Support\_for\_Amazon\_S3\_API), it can be used as a drop-in replacement for S3. To obtain the necessary S3 User Credentials, see [Hitachi's documentation](https://knowledge.hitachivantara.com/Documents/Storage/HCP\_for\_Cloud\_Scale/1.0.0/Adminstering\_HCP\_for\_cloud\_scale/Object\_storage\_management/01\_S3\_User\_Credentials#GUID-6DA3811F-FBC5-4848-B47D-B2297F0902B7). Afterwards, follow the example below to configure the secret.

For `bucket`, the value should be the folder created in the HCP endpoint bucket, not the pre-existing bucket name.&#x20;

{% code overflow="wrap" %}
```
type: S3
config:
  bucket: "folder name"
  endpoint: "gateway.storjshare.io"
  access_key: "<HITACHI_ACCESS_KEY>"
  secret_key: "<HITACHI_SECRET_KEY>"
  insecure: false
  signature_version2: false
  http_config:
    idle_conn_timeout: 90s
    response_header_timeout: 2m
    insecure_skip_verify: false
  trace:
    enable: true
  part_size: 134217728
prefix: ""  # Optional. Specify a path within the bucket (e.g. "kubecost/etlbackup").
```
{% endcode %}

</details>

### Step 2: Enable ETL backup in Helm values

If Kubecost was installed via Helm, ensure the following value is set.

```yaml
kubecostModel:
  etlBucketConfigSecret: <YOUR_SECRET_NAME>
```

### Compatibility

If you are using an existing disk storage option for your ETL data, enabling the durable backup feature will retroactively back up all previously stored data\*. This feature is also fully compatible with the existing S3 backup feature.

{% hint style="info" %}
If you are using a memory store for your ETL data with a local disk backup (`kubecostModel.etlFileStoreEnabled: false`), the backup feature will simply replace the local backup. In order to take advantage of the retroactive backup feature, you will need to update to file store (`kubecostModel.etlFileStoreEnabled: true`). This option is now enabled by default in the Helm chart.
{% endhint %}

## Option 2: Manual backup via Bash script

The simplest way to backup Kubecost's ETL is to copy the pod's ETL store to your local disk. You can then send that file to any other storage system of your choice. We provide a [script](https://github.com/kubecost/etl-backup) to do that.

To restore the backup, untar the results of the ETL backup script into the ETL directory pod.

{% code overflow="wrap" %}
```bash
kubectl cp -c cost-model <untarred-results-of-script>/bingen <kubecost-namespace>/<kubecost-pod-name>:/var/configs/db/etl
```
{% endcode %}

There is also a Bash script available to restore the backup in [Kubecost's etl-backup repo](https://github.com/kubecost/etl-backup/blob/main/upload-etl.sh).

## Monitoring

Currently, this feature is still in development, but there is currently a status card available on the Diagnostics page that will eventually show the status of the backup system:

![Diagnostic ETL Backup Status](/images/diagnostics-etl-backup-status.png)

## Troubleshooting

In some scenarios like when using Memory store, setting `kubecostModel.etlHourlyStoreDurationHours` to a value of `48` hours or less will cause ETL backup files to become truncated. The current recommendation is to keep [etlHourlyStoreDurationHours](https://github.com/kubecost/cost-analyzer-helm-chart/blob/8fd5502925c28c56af38b0c4e66c4ec746761d50/cost-analyzer/values.yaml#L322) at its default of `49` hours.
