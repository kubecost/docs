# Hitachi Content Platform (HCP) Multi-Cluster Storage Configuration

{% hint style="info" %}
Usage of a Federated Storage Bucket is only supported for Kubecost Enterprise plans.
{% endhint %}

Because HCP is [S3 compatible](https://knowledge.hitachivantara.com/Documents/Storage/HCP\_for\_Cloud\_Scale/1.0.0/Adminstering\_HCP\_for\_cloud\_scale/Getting\_started/02\_Support\_for\_Amazon\_S3\_API), it can be used as a drop-in replacement for S3.

To obtain the necessary S3 User Credentials, see [Hitachi's documentation](https://knowledge.hitachivantara.com/Documents/Storage/HCP\_for\_Cloud\_Scale/1.0.0/Adminstering\_HCP\_for\_cloud\_scale/Object\_storage\_management/01\_S3\_User\_Credentials#GUID-6DA3811F-FBC5-4848-B47D-B2297F0902B7).

Now create a .YAML file named `federated-store.yaml` with the following format:

```yaml
type: S3
config:
  bucket: "folder name" # Folder created in the HCP endpoint bucket, not the pre-existing bucket name.
  endpoint: "your.hcp-endpoint.com"
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
prefix: ""  # Optional. Specify a path within the bucket (e.g. "kubecost/etl").
```
