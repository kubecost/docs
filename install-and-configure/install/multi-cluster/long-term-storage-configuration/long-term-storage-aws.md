AWS Multi-Cluster Storage Configuration
=======================================

## AWS/S3 Federation
<a name="overview"></a>
Kubecost uses a shared storage bucket to store metrics from clusters, known as durable storage, in order to provide a single-pane-of-glass for viewing cost across many clusters. Multi-cluster is an enterprise feature of Kubecost.

There are multiple methods to provide Kubecost access to an S3 bucket. This guide has two examples:

1. Using a Kubernetes secret
2. Attaching an AWS Identity and Access Management (IAM) role to the service account used by Prometheus

Both methods require an S3 bucket. Our example bucket is named `kc-thanos-store`.

This is a simple S3 bucket with all public access blocked. No other bucket configuration changes should be required.

Once created, add an IAM policy to access this bucket. This is covered in our [AWS Thanos IAM Policy](/aws-service-account-thanos.md) doc.

## Method 1: Kubernetes Secret Method
<a name="secret"></a>
To use the Kubernetes secret method for allowing access, create a .yaml file named `object-store.yaml` with contents similar to the following example. See region to endpoint mappings [here](https://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region).

```
type: S3
config:
  bucket: "kc-thanos-store"
  endpoint: "s3.amazonaws.com"
  region: "us-east-1"
  access_key: "<your-access-key>"
  secret_key: "<your-secret-key>"
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

{% hint style="info" %}
Because this is a .yaml file, it requires the specific displayed indention.
{% endhint %}

## Method 2: Attach IAM role to Service Account Method
<a name="attach-role"></a>
Instead of using a secret key in a file, many will want to use this method.

Attach the policy to the Thanos pods service accounts. Your `object-store.yaml` should follow the format below when using this option, which does not contain the secret_key and access_key fields.

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

Then, follow [this AWS guide](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) to enable attaching IAM roles to pods.

You can define the IAM role to associate with a service account in your cluster by creating a service account in the same namespace as Kubecost and adding an annotation to it of the form `eks.amazonaws.com/role-arn: arn:aws:iam::<AWS_ACCOUNT_ID>:role/<IAM_ROLE_NAME>`
as described [here](https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html).

Once that annotation has been created, configure the following:

```yaml
.Values.prometheus.serviceAccounts.server.create: false
.Values.prometheus.serviceAccounts.server.name: serviceAccount # to the name of your created service account
.Values.thanos.compact.serviceAccount: serviceAccount
.Values.thanos.store.serviceAccount: serviceAccount
```

## Thanos Encryption With S3 and KMS
<a name="encryption"></a>
You can encrypt the S3 bucket where Kubecost data is stored in AWS via S3 and KMS. However, because Thanos can store potentially millions of objects, it is suggested that you use bucket-level encryption instead of object-level encryption. More details available in these external docs:

* [Thanos S3 storage doc](https://thanos.io/tip/thanos/storage.md/#s3)
* [Reducing the cost of SSE-KMS with Amazon S3 Bucket Keys](https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html)
* [Configuring an S3 Bucket Key at the Object Level](https://docs.aws.amazon.com/AmazonS3/latest/userguide/configuring-bucket-key-object.html)

## Troubleshooting

Visit the [Configuring Thanos](/install-and-configure/install/multi-cluster/thanos-setup/configuring-thanos.md#troubleshooting) doc for troubleshooting help.
