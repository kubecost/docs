# AWS Spot Instances

## Spot Data feed integration

Kubecost will reconcile your spot prices with CUR billing reports as they become available (usually 1-2 days), but pricing data can be pulled hourly by integrating directly with the AWS spot feed. To enable, follow these steps:

[https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-data-feeds.html](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-data-feeds.html)

## Configuring the Spot Data feed in Kubecost

These values can either be set from the kubecost frontend or via .Values.kubecostProductConfigs in the Helm Chart. Note that if you set any kubecostProductConfigs from the Helm Chart, all changes via the frontend will be deleted on pod restart.

Spot data feed provide same functionality as aws cur integration , The only difference is you will receive Spot Feed data hourly with the Spot Feed Integration. The AWS Cloud Integration, or CUR, is delayed up to 48 hours. So if you are looking for accurate costs across the board, as most customers do, you can skip the Spot Feed integration. If your use case is different want to go for spot data feed make sure you had the right information to make an informed decision.

* `projectID` the Account ID of the AWS Account on which the spot nodes are running.
* `awsSpotDataRegion` region of your spot data bucket
* `awsSpotDataBucket` the configured bucket for the spot data feed
* `awsSpotDataPrefix` optional configured prefix for your spot data feed bucket
* `spotLabel` optional Kubernetes node label name designating whether a node is a spot node. Used to provide pricing estimates until exact spot data becomes available from the CUR
* `spotLabelValue` optional Kubernetes node label value designating a spot node. Used to provide pricing estimates until exact spot data becomes available from the CUR. For example, if your spot nodes carry a label `lifecycle:spot`, then the spotLabel would be "lifecycle" and the spotLabelValue would be "spot"

## Troubleshooting Spot Data feed

### No spot instances detected

![](https://user-images.githubusercontent.com/102574445/199281977-3195b1d1-e3a5-4561-85da-eb8b24e23f27.png)

Verify below points:

* Make sure data is present in the spot data feed bucket.
* Make sure Project ID is configured correctly. You can cross-verify the values under Helm values in bug report
* Check the value of kubecost\_node\_is\_spot in Prometheus:
  * "1" means Spot data instance configuration is correct.
  * "0" means not configured properly.
* Is there a prefix? If so, is it configured in kubecost?
* Make sure the IAM permissions are aligned with https://github.com/kubecost/cloudformation/blob/7feace26637aa2ece1481fda394927ef8e1e3cad/kubecost-single-account-permissions.yaml#L36
* Make sure the Spot data feed bucket has all permissions to access by Kubecost
* The Spot instance in the Spot data feed bucket should match the instance in the cluster where the spot data feed is configured. awsSpotDataBucket has to be present in the right cluster.
