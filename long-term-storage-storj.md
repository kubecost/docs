Storj Long Term Storage
=====================

Storj is S3 compatible, meaning the existing Kubecost AWS S3 integration will fully function with Storj DCS. To get started, [create a new Storj bucket in the Admin Console](https://docs.storj.io/dcs/getting-started/quickstart-objectbrowser#po96y) The following example uses a bucket named `thanos-bucket`. Then, create an [S3 compatible Access Grant](https://docs.storj.io/dcs/access) and take note of the Access Key and Secret Key.

Now create a YAML file named `object-store.yaml` in the following format, using your bucket name and credentials:

```yaml
type: S3
config:
  bucket: "thanos-bucket"
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
```

> **Note**: Only by accessing the bucket using the specific key provided to Kubecost will any application (including the Storj Admin Console) be able to see the uploaded files.
