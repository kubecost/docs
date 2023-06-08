# AWS Spot Instances

## Considerations before configuring Spot pricing

Kubecost uses public pricing from the cloud providers until the actual cloud bill is available. This is almost always ready in 48 hours. Most users will likely prefer to configure [AWS cloud-integrations](aws-cloud-integrations.md) and skip the below setup.

For users with most of their costs from spot nodes, the guide below can increase short-term (<48 hour) node costs. Note that all other costs will still be based on public pricing, which is why the below guide should be considered optional.

## Configuring the Spot data feed in Kubecost

With Kubecost, Spot pricing- data can be pulled hourly by integrating directly with the AWS Spot feed.

First, to enable the AWS Spot data feed, follow AWS' [Spot Instance data feed](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-data-feeds.html) doc.

While configuring, note the settings used as these values will be needed for the Kubecost configuration.

There are multiple options: this can either be set from the Kubecost UI or via `.Values.kubecostProductConfigs` in the Helm chart. Note that if you set any `kubecostProductConfigs` from the Helm chart, all changes via the front end will be deleted on pod restart.

* `projectID` the Account ID of the AWS Account on which the Spot nodes are running.
* `awsSpotDataRegion` region of your Spot data bucket
* `awsSpotDataBucket` the configured bucket for the Spot data feed
* `awsSpotDataPrefix` optional configured prefix for your Spot data feed bucket
* `spotLabel` optional Kubernetes node label name designating whether a node is a Spot node. Used to provide pricing estimates until exact Spot data becomes available from the CUR
* `spotLabelValue` optional Kubernetes node label value designating a Spot node. Used to provide pricing estimates until exact Spot data becomes available from the CUR. For example, if your Spot nodes carry a label `lifecycle:spot`, then the `spotLabel` would be `lifecycle` and the `spotLabelValue` would be `spot`

In the UI, you can access these fields via the _Settings_ page, then scrolling to Cloud Cost Settings. Next to Spot Instance Configuration, select _Update,_ then fill out all fields.

Spot data feeds are an account level setting, not a payer level. Every AWS Account will have its own Spot data feed. Spot data feed is not currently available in AWS GovCloud.

{% hint style="info" %}
For Spot data written to an S3 bucket only accessed by Kubecost, it is safe to delete objects after three days of retention.
{% endhint %}

## Configuring IAM

Kubecost requires read access to the Spot data feed bucket. The following IAM policy can be used to grant Kubecost read access to the Spot data feed bucket.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Sid": "SpotDataFeed",
        "Effect": "Allow",
        "Action": [
          "s3:ListAllMyBuckets",
          "s3:ListBucket",
          "s3:HeadBucket",
          "s3:HeadObject",
          "s3:List*",
          "s3:Get*"
        ],
        "Resource": "arn:aws:s3:::${SpotDataFeedBucketName}*"
    }
  ]
}
```

To attach the IAM policy to the Kubecost service account, you can use IRSA or the account's service key.

### Option 1: IRSA (IAM Roles for Service Accounts)

```bash
eksctl create iamserviceaccount \
    --name kubecost-cost-analyzer \
    --namespace kubecost \
    --cluster $CLUSTER_NAME --region $REGION_NAME \
    --attach-policy-arn arn:aws:iam::$ACCOUNT_NUMBER:policy/SpotDataFeed \
    --override-existing-serviceaccounts \
    --approve
```

### Option 2: Service Keys

Create a `service-key.json` as shown:

```json
{
    "aws_access_key_id": "AWS_service_key_aws_access_key_id",
    "aws_secret_access_key": "AWS_service_key_aws_secret_access_key"
}
```

Create a k8s secret:

```bash
$ kubectl create secret generic cloud-service-key --from-file=service-key.json
```

Set the following Helm config:

```yaml
kubecostProductConfigs:
  serviceKeySecretName: "cloud-service-key"
```

## Troubleshooting Spot data feed

### No Spot instances detected

![](https://user-images.githubusercontent.com/102574445/199281977-3195b1d1-e3a5-4561-85da-eb8b24e23f27.png)

Verify below points:

* Make sure data is present in the Spot data feed bucket.
* Make sure Project ID is configured correctly. You can cross-verify the values under Helm values in bug report
* Check the value of `kubecost_node_is_spot` in Prometheus:
  * "1" means Spot data instance configuration is correct.
  * "0" means not configured properly.
* Is there a prefix? If so, is it configured in Kubecost?
* Make sure the IAM permissions are aligned with https://github.com/kubecost/cloudformation/blob/7feace26637aa2ece1481fda394927ef8e1e3cad/kubecost-single-account-permissions.yaml#L36
* Make sure the Spot data feed bucket has all permissions to access by Kubecost
* The Spot Instance in the Spot data feed bucket should match the instance in the cluster where the Spot data feed is configured. `awsSpotDataBucket` has to be present in the right cluster.
