AWS Multi-Cluster Storage Configuration
=======================================

## Sections

* [Overview of AWS/S3 Federation](#overview)
* [Kubernetes Secret Method](#secret)
* [Attach IAM role to Service Account Method](#attach-role)
* [Thanos Encryption With S3 and KMS](#encyption)
* [Troubleshooting](#troubleshooting)
* [Additional Help](#help)

## <a name="cloud-integration"></a>AWS/S3 Federation

Kubecost user a shared storage bucket to store metrics from all clusters (aka `durable storage`) in order to provide a single-pane-of-glass for viewing cost across many clusters. Multi-cluster is an enterprise feature of Kubecost.

There are multiple methods to provide Kubecost access to an S3 bucket. This guide has two examples:

1. Using a Kubernetes secret
1. Attaching an IAM role to the service account used by Prometheus

Either method will need an S3 bucket, our example bucket is named `kc-thanos-store`.

This is a simple S3 bucket with all public access blocked. No other bucket configuration changes should be required.

Once created, add an IAM policy to access this bucket ([steps](/aws-service-account-thanos.md)).

## Kubernetes Secret Method

To use the Kubernetes secret method for allowing access, create a yaml file named `object-store.yaml` with contents similar to the following example. See region to endpoint mappings here: <https://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region>

```
type: S3
config:
  bucket: "kc-thanos-store"
  endpoint: "s3.amazonaws.com"
  region: "us-east-1"
  access_key: "AKIAXW6UVLRRTDSCCU4D"
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
**Note:** given that this is yaml, it requires this specific indention.

## <a name="attach-role"></a>Attach IAM role to Service Account Method

Instead of using a secret key in a file, many will want to use this method.

Attach the policy to the Thanos pods service accounts. Your `object-store.yaml` should follow the format below when using this option, which does not contain the secret_key and access_key fields.

```
type: S3
config:
  bucket: "kc-thanos-store"
  endpoint: "s3.amazonaws.com"
  region: "us-east-1"
  # access_key: "AKIAXW6UVLRRTDSCCU4D"
  # secret_key: "<your-secret-key>"
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

## <a name="encryption"></a>Thanos Encryption With S3 and KMS

You can encrypt the S3 bucket where Kubecost data is stored in AWS via S3 and KMS. However, because Thanos can store potentially millions of objects, it is suggested that you use bucket-level encryption instead of object-level encryption. More details available here:

https://thanos.io/tip/thanos/storage.md/#s3
https://docs.aws.amazon.com/AmazonS3/latest/userguide/bucket-key.html
https://docs.aws.amazon.com/AmazonS3/latest/userguide/configuring-bucket-key-object.html

## <a name="troubleshooting"></a>Troubleshooting

Thanos sends data to the bucket every 2 hours. Once 2 hours has passed, logs should indicate if data has been sent successfully or not.

You can monitor the logs with:
```bash
kubectl logs --namespace kubecost -l app=prometheus -l component=server --prefix=true --container thanos-sidecar --tail=-1 | grep uploaded
```

Should return results like this:

```log
[pod/kubecost-prometheus-server-xxx/thanos-sidecar] level=debug ts=2022-06-09T13:00:10.084904136Z caller=objstore.go:206 msg="uploaded file" from=/data/thanos/upload/01G548SSBYSMSSE3G8TP2E6YD1/chunks/000001 dst=01G548SSBYSMSSE3G8TP2E6YD1/chunks/000001 bucket="tracing: kc-thanos-store"
```

As an aside, you can validate the prometheus metrics are all configured with correct cluster names with:

```bash
kubectl logs --namespace kubecost -l app=prometheus -l component=server --prefix=true --container thanos-sidecar --tail=-1 | grep external_labels
```

To troubleshoot the IAM Role Attached to the serviceaccount, you can create a pod using the same service account used by the thanos-sidecar (default is `kubecost-prometheus-server`):

`s3-pod.yaml`
```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: s3-pod
  name: s3-pod
spec:
  serviceAccountName: kubecost-prometheus-server
  containers:
  - image: amazon/aws-cli
    name: my-aws-cli
    command: ['sleep', '500']
```

```bash
kubectl apply -f s3-pod.yaml
kubectl exec -i -t s3-pod -- aws s3 ls s3://kc-thanos-store
```
This should return a list of objects (or at least not give a permission error).

## <a name="help"></a>Additional Help
Please let us know if you run into any issues, we are here to help.

[Slack community](https://join.slack.com/t/kubecost/shared_invite/enQtNTA2MjQ1NDUyODE5LWFjYzIzNWE4MDkzMmUyZGU4NjkwMzMyMjIyM2E0NGNmYjExZjBiNjk1YzY5ZDI0ZTNhZDg4NjlkMGRkYzFlZTU) - check out #support for any help you may need & drop your introduction in the #general channel

Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/long-term-storage-aws.md)

<!--- {"article":"4407595952151","section":"4402829036567","permissiongroup":"1500001277122"} --->
