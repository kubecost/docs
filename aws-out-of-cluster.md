Kubecost provides the ability to allocate out of cluster costs, e.g. RDS instances and S3 buckets, back to Kubernetes concepts like namespace and deployment. All billing data remains on your cluster when using this functionality and is not shared externally.

The following guide provides the steps required for allocating out of cluster costs. The steps in this guide also enable accurate [Reserved Instance price allocation](http://docs.kubecost.com/getting-started#ri-committed-discount). In a multi-account organization, all of the following steps will need to be completed in the payer account.

## Step 1: Create an S3 bucket
This bucket will be used to store AWS cost and usage data.

[Instructions for creating an S3 Bucket to be used for Cost and Usage data](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/setting-up-athena.html#create-athena-bucket)

## Step 2: Create an AWS Cost and Usage Report
When creating the Cost and Usage Report, configure the report to be delivered to the bucket created in step #1. When following the instructions for this step, choose `Athena` as the data integration option so that reports are created in parquet format.

[Instructions for creating a Cost and Usage Report](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/setting-up-athena.html#create-athena-cur)

## Step 3: Enable User-Defined Cost Allocation Tags
Kubecost utilizes AWS tagging to allocate the costs of AWS resources outside of the Kubernetes cluster to specific Kubernetes concepts, such as namespaces, pods, etc. These costs are then shown in a unified dashboard within the Kubecost interface.

In order to make the custom Kubecost AWS tags appear on the cost and usage reports, and therefore in Kubecost, individual cost allocation tags must be enabled. Details on which tags to enable can be found in Step #6 of this doc.

[Instructions for enabling user-defined cost allocation tags](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/activating-tags.html)

## Step 4: Export Cost and Usage Data to Athena
By completing this step, you will make available the Cost and Usage data created in Step #2 to Amazon Athena where Kubecost can then query the data.

[Instructions for making Cost and Usage data available via Amazon Athena](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/setting-up-athena.html#use-athena-cf)

## Step 5: Give Kubecost Access

To access billing data in Athena tables, and to enable other Kubecost functionality, you have two options:
1. Create an IAM User with the following IAM permissions. Generate Access Keys for this IAM User and provide them to Kubecost.
2. Attach the following permissions to the IAM Role associated with the EC2 instance(s) in the cluster where Kubecost is running.

*We recommend [kiam](https://github.com/uswitch/kiam) as a solution for adding IAM credentials directly to the Kubecost pod(s).*

### Cost and Usage Permissions Policy
The below policy is designed to provide Kubecost least-privilege access to AWS Cost and Usage data.

Validate the following resource names in the below IAM policy before applying to your account:
* `"Sid": "ReadAccessToAthenaCurDataViaGlue"`: Validate the `database` and `table` ARNs listed. If you used the AWS managed deployment, as described in Step #4, this should already be set correctly. If you set up the Cost and Usage report to Athena flow manually, you may need to adjust this value.
* `"Sid": "AthenaQueryResultsOutput"`: Modify the listed bucket ARN to match the location where Athena should put query execution result files.
* `"Sid": "S3ReadAccessToAwsBillingData"`: Modify the bucket ARN to match the name of the bucket created in Step #1.
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "FullAthenaAccess",
            "Effect": "Allow",
            "Action": [
                "athena:*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "ReadAccessToAthenaCurDataViaGlue",
            "Effect": "Allow",
            "Action": [
                "glue:GetDatabase*",
                "glue:GetTable*",
                "glue:GetPartition*",
                "glue:GetUserDefinedFunction",
                "glue:BatchGetPartition"
            ],
            "Resource": [
                "arn:aws:glue:*:*:catalog",
                "arn:aws:glue:*:*:database/athenacurcfn*",
                "arn:aws:glue:*:*:table/athenacurcfn*/*"
            ]
        },
        {
            "Sid": "AthenaQueryResultsOutput",
            "Effect": "Allow",
            "Action": [
                "s3:GetBucketLocation",
                "s3:GetObject",
                "s3:ListBucket",
                "s3:ListBucketMultipartUploads",
                "s3:ListMultipartUploadParts",
                "s3:AbortMultipartUpload",
                "s3:CreateBucket",
                "s3:PutObject"
            ],
            "Resource": [
                "arn:aws:s3:::aws-athena-query-results-*"
            ]
        },
        {
            "Sid": "S3ReadAccessToAwsBillingData",
            "Effect": "Allow",
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::<BILLING BUCKET>*"
            ]
        }
    ]
}
```
#### IAM Policy Explanation

 * `"Sid": "FullAthenaAccess"`: Grants access to run queries on data exposed via Athena. `athena:*` is generally safe because Athena constructs are all actually using the Glue catalog under the hood. Access to data in Athena is actually controlled by:
    1. Whether the user performing the query has access to the appropriate Glue catalog, database, and table
    2. Whether the user performing the query has access to the S3 bucket where the data being queried is actually stored.
 * `"Sid": "ReadAccessToAthenaCurDataViaGlue"`: When following the AWS provided instructions for enabling Cost and Usage Report data delivery via Athena, a Glue database will be created with the prefix `athenacurcfn`. This Statement allows Kubecost to query the specific Glue database and table which stores the Cost and Usage data.
 * `"Sid": "AthenaQueryResultsOutput"`: When executing queries in Athena, all results are automatically saved as a CSV to an S3 bucket. The default bucket used is prefixed with `aws-athena-query-results`. This Statement provides Kubecost the access required to write Athena query results to the results bucket. This bucket can be customized within the Kubecost interface when setting up Out of Cluster resource access and this Statement would need to be updated to reflect the new bucket name.
 * `"Sid": "S3ReadAccessToAwsBillingData"`: Provides read access to the underlying Cost and Usage report data being generated by AWS. This Statement will include access to the bucket created during Step #1 of this doc. This is required to allow Kubecost to run queries against the cost data, which exists in this bucket.

### Inventory and AWS Resource Policy
As Kubecost integrates with additional AWS services, additional read access may need to be granted to access those services.
```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation",
                "s3:ListAllMyBuckets"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "sns:ListTopics",
                "sns:GetTopicAttributes"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
                "cloudwatch:PutMetricAlarm",
                "cloudwatch:DescribeAlarms",
                "cloudwatch:DeleteAlarms",
                "cloudwatch:ListMetrics",
                "cloudwatch:GetMetricStatistics",
                "cloudwatch:Describe*"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": "ec2:Describe*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "elasticloadbalancing:Describe*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "autoscaling:Describe*",
            "Resource": "*"
        }
    ]
}
```

## Step 6: Tag your resources

To allocate AWS resources to a Kubernetes concept, use the following tag naming scheme:

| Kubernetes Concept 	| AWS Tag Key         	| AWS Tag Value 	|
|--------------------	|---------------------	|---------------	|
| Cluster           	| kubernetes_cluster	| &lt;cluster-name>	|
| Namespace          	| kubernetes_namespace	| &lt;namespace-name> |
| Deployment         	| kubernetes_deployment	| &lt;deployment-name>|
| Label              	| kubernetes_label_NAME*| &lt;label-value>    |
| DaemonSet          	| kubernetes_daemonset	| &lt;daemonset-name> |
| Pod                	| kubernetes_pod	      | &lt;pod-name>     |
| Container          	| kubernetes_container	| &lt;container-name> |


*\*In the `kubernetes_label_NAME` tag key, the `NAME` portion should appear exactly as the tag appears inside of Kubernetes. For example, for the tag `app.kubernetes.io/name`, this tag key would appear as `kubernetes_label_app.kubernetes.io/name`.*

To use an alternative or existing AWS tag schema, you may supply these in your [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml#L403-L414).

More on AWS tagging [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Using_Tags.html).

## Step 7: Add AWS Credentials and Athena configuration details in the Kubecost product

Visit the Kubecost Settings page to provide the AWS access credentials and Athena information.

**Note:** you must include the protocol for your S3 bucket name, e.g. s3://aws-athena-query-results-5303329856255-us-east-1

## Having issues?


* Visit the Allocation view in the Kubecost product. If external costs are not shown, open your browser's Developer Tools > Console to see any reported errors.
* Query Athena directly to ensure data is availble. Note: it can take up to 6 hours for data to be written. 
* You may need to upgrade your AWS Glue if you are running an old version https://docs.aws.amazon.com/athena/latest/ug/glue-upgrade.html
* Finally, review pod logs from the `cost-model` container in the `cost-analyzer` pod and look for auth errors or Athena query results. 

