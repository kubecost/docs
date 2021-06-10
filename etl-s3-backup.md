# ETL S3 Backup
When the ETL pipeline collects data, it stores both daily and hourly (if configured) binary on a configured storage. This defaults to a PV based disk storage, but can be configured to use S3 instead using the following steps:

### Create a Secret for S3 Storage
This secret should follow the configuration layout documented for Thanos here: https://thanos.io/v0.21/thanos/storage.md/#s3. For reference, here's the schema:
```yaml
type: S3
config:
  bucket: ""
  endpoint: ""
  region: ""
  access_key: ""
  insecure: false
  signature_version2: false
  secret_key: ""
  put_user_metadata: {}
  http_config:
    idle_conn_timeout: 1m30s
    response_header_timeout: 2m
    insecure_skip_verify: false
    tls_handshake_timeout: 10s
    expect_continue_timeout: 1s
    max_idle_conns: 100
    max_idle_conns_per_host: 100
    max_conns_per_host: 0
  trace:
    enable: false
  list_objects_version: ""
  part_size: 67108864
  sse_config:
    type: ""
    kms_key_id: ""
    kms_encryption_context: {}
    encryption_key: ""
```
At a minimum, you will need to provide a value for the bucket, endpoint, access_key, and secret_key keys. The rest of the keys are optional.

Save this file as `object-store.yaml` and use the following console command to create the secret from the file:
```bash
kubectl create secret generic <secret_name> -n kubecost --from-file=object-store.yaml
```

### Enable S3 Backup in Helm Values

When installing with helm, use the `--set kubecostModel.etlBucketConfigSecret=<secret_name>` flag and substitute the name of the secret you just created. 

Note that enabling this flag will override the disk storage setting. Also, since the storage is a new location, the ETL will require a full rebuild.
