# AWS Multi-Cluster Storage Configuration

{% hint style="info" %}
Usage of a Federated Storage Bucket is only supported for Kubecost Enterprise plans.
{% endhint %}

In order to provide a single-pane-of-glass view across many clusters, Kubecost uses a shared storage bucket which all clusters push to. There are multiple methods to provide Kubecost access to an S3 bucket. This guide has two examples:

1. Using a user or role's access keys
2. Attaching an AWS Identity and Access Management (IAM) role to the service account used by Kubecost

Both methods require an S3 bucket. Our example bucket is named `kubecost-federated-storage-bucket`. This is a simple S3 bucket with all public access blocked. No other bucket configuration changes should be required.

## Method 1: Using access keys

Create a file named `federated-store.yaml` with contents similar to the following example. See region to endpoint mappings [here](https://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region).

```yaml
type: S3
config:
  bucket: "kubecost-federated-storage-bucket"
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

## Method 2: Attach IAM role to Service Account

Create a file named `federated-store.yaml` with contents similar to the following example. Note, that it does not contain the `access_key` and `secret_key` fields.

```yaml
type: S3
config:
  bucket: "kubecost-federated-storage-bucket"
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

Then, follow [this AWS guide](https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html) to enable attaching IAM roles to pods. Once the role & policy have been created, configure your Helm `values.yaml` to include the following annotation:

```yaml
serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<AWS_ACCOUNT_ID>:role/<IAM_ROLE_NAME>
```

## AWS IAM Policy details

The user or role which has access to Kubecost's federated storage bucket should have the permissions defined in this policy at a minimum.

```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "Statement",
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetObject",
                "s3:DeleteObject",
                "s3:PutObject",
                "s3:PutObjectAcl"
            ],
            "Resource": [
                "arn:aws:s3:::<your-bucket-name>/*",
                "arn:aws:s3:::<your-bucket-name>"
            ]
        }
    ]
}
```

## Troubleshooting

### "operation error STS: AssumeRole"

```console
(2024-04-08T00:00:00+0000): GetCloudCost: error getting Athena columns: QueryAthenaPaginated: start query error: operation error Athena: StartQueryExecution, get identity: get credentials: failed to refresh cached credentials, operation error STS: AssumeRole, https response error StatusCode: 403, RequestID: 0459fd9b-451d-4bd0-8289-aaf90f146f37, api error AccessDenied: User: arn:aws:sts::YOUR_ACCOUNT_ID:assumed-role/aws-prod-eks-node-group/i-05c1fa9d0eb168e35 is not authorized to perform: sts:AssumeRole on resource: arn:aws:iam::YOUR_PRIMARY_ACCOUNT_ID:role/KubecostRole-YOUR_ACCOUNT_ID
(2024-04-04T00:00:00+0000): GetCloudCost: error getting Athena columns: QueryAthenaPaginated: start query error: operation error Athena: StartQueryExecution, get identity: get credentials: failed to refresh cached credentials, operation error STS: AssumeRole, https response error StatusCode: 403, RequestID: 6494b54b-1a9e-47ea-941d-e316cb0bc778, api error AccessDenied: User: arn:aws:sts::YOUR_ACCOUNT_ID:assumed-role/aws-prod-eks-node-group/i-05c1fa9d0eb168e35 is not authorized to perform: sts:AssumeRole on resource: arn:aws:iam::YOUR_PRIMARY_ACCOUNT_ID:role/KubecostRole-YOUR_ACCOUNT_ID
```

If running into an error similar to the one above, please refer to [this AWS doc](https://docs.aws.amazon.com/IAM/latest/UserGuide/troubleshoot_roles.html) to troubleshoot assuming IAM roles.
