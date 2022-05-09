AWS Long Term Storage
=====================

__AWS/S3__

Start by creating a new S3 bucket with all public access blocked. No other bucket configuration changes should be required. The following example uses a bucket named `kc-thanos-store`.

Next, add an IAM policy to access this bucket ([steps](/aws-service-account-thanos.md)).

Now create a yaml file named `object-store.yaml` with contents similar to the following example. See region to endpoint mappings here: <https://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region>

```
type: S3
config:
  bucket: "kc-thanos-store"
  endpoint: "s3.amazonaws.com"
  region: "us-east-1"
  access_key: "AKIAXW6UVLRRTDSCCU4D"
  insecure: false
  signature_version2: false
  secret_key: "<your-secret-key>"
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
**Note:** given that this is yaml, it requires this specific indention.

Instead of using a service key, you can alternatively attach the policy to the Thanos pods service accounts. Your `object-store.yaml` should follow the format below when using this option, which does not contain the secret_key and access_key fields.

```
type: S3
config:
  bucket: "kc-thanos-store"
  endpoint: "s3.amazonaws.com"
  region: "us-east-1"
  insecure: false
  signature_version2: false
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

Then, follow the guide at [https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) to enable attaching IAM roles to pods.

You can define the IAM role to associate with a service account in your cluster by creating a service account in the same namespace as kubecost and adding an annotation to it of the form `eks.amazonaws.com/role-arn: arn:aws:iam::<AWS_ACCOUNT_ID>:role/<IAM_ROLE_NAME>`
as described here: [https://docs.aws.amazon.com/eks/latest/userguide/specify-service-account-role.html](https://docs.aws.amazon.com/eks/latest/userguide/specify-service-account-role.html)

Once that annotation has been created and set, you'll need to attach it to the Prometheus pod, the Thanos compact pod, and the Thanos store pod.
For prometheus, set .Values.prometheus.serviceAccounts.server.create to false, and .Values.prometheus.serviceAccounts.server.name to the name of your created service account
For thanos set `.Values.thanos.compact.serviceAccount`, and `.Values.thanos.store.serviceAccount` to the name of your created service account.



__Thanos Encryption With S3 and KMS__

You can encrypt the S3 bucket where Kubecost data is stored in AWS via S3 and KMS. However, because Thanos can store potentially millions of objects, it is suggested that you use bucket-level encryption instead of object-level encryption. More details available here:

https://thanos.io/tip/thanos/storage.md/#s3
https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html
https://docs.aws.amazon.com/AmazonS3/latest/userguide/configuring-bucket-key-object.html

Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/long-term-storage-aws.md)

<!--- {"article":"4407595952151","section":"4402829036567","permissiongroup":"1500001277122"} --->
