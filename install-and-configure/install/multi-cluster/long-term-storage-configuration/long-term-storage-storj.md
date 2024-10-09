# Storj Multi-Cluster Storage Configuration

{% hint style="info" %}
Usage of a Federated Storage Bucket is only supported for Kubecost Enterprise plans.
{% endhint %}

Because Storj is [S3 compatible](https://docs.storj.io/dcs/api-reference/s3-compatible-gateway/), it can be used as a drop-in replacement for S3.

After an S3 Compatible Access Grant has been created, create a .YAML file named `federated-store.yaml` with the following format:

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
prefix: ""  # Optional. Specify a path within the bucket (e.g. "kubecost/etl").
```
