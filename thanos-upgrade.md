Thanos Upgrade
==============

Kubecost 1.67.0+ uses Thanos 0.15.0. If you're upgrading to Kubecost 1.67.0+ from Kubecost < 1.67.0 and using Thanos, and using AWS s3 as your backing storage for Thanos, you'll need to make a small change to your Thanos secret in order to bump the Thanos version to 0.15.0 before you upgrade Kubecost.
Thanos 0.15.0 has over 10x performance improvements, so this is recommended.

Your _values-thanos.yaml_ needs to be updated to the new defaults: https://github.com/kubecost/cost-analyzer-helm-chart/commit/752b584a520f2ff089517341ab2eca2664980dab#diff-b5f07a55b9483e6b0fc339c7a03fa08b.
The PR bumps the image version, adds the [query-frontend](https://thanos.io/tip/components/query-frontend.md/) component, and increases concurrency. 

This is simplified if you're using our default _values-thanos.yaml_, which has the new configs already.

> **Note**: For the Thanos secret you're using, the "encrypt-sse" line needs to be removed. Everything else should stay the same.

For example, view this sample config:

```
type: S3
config:
  bucket: ${bucket_name}
  endpoint: "s3.amazonaws.com"
  region: ${your_bucket_region}
  access_key: ${your_access_key}
  insecure: false
  signature_version2: false
  #encrypt_sse: false <--- THIS LINE NEEDS TO BE DELETED
  secret_key: ${your_secret_here}
  put_user_metadata:
      "X-Amz-Acl": "bucket-owner-full-control"
  http_config:
    idle_conn_timeout: 90s
    response_header_timeout: 2m
    insecure_skip_verify: false
  trace:
    enable: true
  part_size: 134217728
```

The easiest way to do this is to delete the existing secret and upload a new one:

`kubectl delete secret -n kubecost kubecost-thanos`

Update your secret yaml file as above, and save it as _object-store.yaml_.

`kubectl create secret generic kubecost-thanos -n kubecost --from-file=./object-store.yaml`

Once this is done, you're ready to upgrade!



<!--- {"article":"4407601829655","section":"4402815636375","permissiongroup":"1500001277122"} --->
