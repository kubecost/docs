# AWS Spot Instances

## Spot Data feed integration

Kubecost will reconcile your Spot prices with Cost and Usage Reports (CURs) as they become available (usually 1-2 days), but pricing data can be pulled hourly by integrating directly with the AWS Spot feed. AWS CUR integration and Spot data feed are two methods for Kubecost to read your billing data. The CUR is updated daily, while the Spot data feed is updated hourly by only applies to Spot Instances. Reduce complexity by only integrating with one of these methods. To enable Spot data feed, follow AWS' [Spot Instance data feed](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-data-feeds.html) doc.

## Configuring the Spot data feed in Kubecost

These values can either be set from the Kubecost UI or via `.Values.kubecostProductConfigs` in the Helm chart. Note that if you set any kubecostProductConfigs from the Helm chart, all changes via the frontend will be deleted on pod restart.

* `projectID` the Account ID of the AWS Account on which the Spot nodes are running.
* `awsSpotDataRegion` region of your Spot data bucket
* `awsSpotDataBucket` the configured bucket for the Spot data feed
* `awsSpotDataPrefix` optional configured prefix for your Spot data feed bucket
* `spotLabel` optional Kubernetes node label name designating whether a node is a Spot node. Used to provide pricing estimates until exact Spot data becomes available from the CUR
* `spotLabelValue` optional Kubernetes node label value designating a Spot node. Used to provide pricing estimates until exact Spot data becomes available from the CUR. For example, if your Spot nodes carry a label `lifecycle:spot`, then the `spotLabel` would be `lifecycle` and the `spotLabelValue` would be `spot`

In the UI, you can access these fields via the _Settings_ page, under Cloud Cost Settings. Next to Spot Instance Configuration, select _Update,_ then fill out all fields.

Spot data feeds are an account level setting, not a payer level. Every AWS Account will have its own Spot data feed. Spot data feed is not currently available in AWS GovCloud.

{% hint style="info" %}
For Spot data written to an S3 bucket only accessed by Kubecost, it is safe to delete objects after three days of retention.
{% endhint %}

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
