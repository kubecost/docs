Kubecost provides the ability to allocate out of clusters costs, e.g. RDS instances and S3 buckets, back to Kubernetes concepts like namespace and deployment. 
The following guide provides the steps required to accomplish this.

## Step 1: Create an S3 bucket
[https://docs.aws.amazon.com/AmazonS3/latest/user-guide/create-bucket.html](https://docs.aws.amazon.com/AmazonS3/latest/user-guide/create-bucket.html)

## Step 2: Create an AWS Cost and Usage report with appropriate permissions
[https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/billing-getting-started.html#step-2](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/billing-getting-started.html#step-2)

## Step 3: Enable tags for Billing Reports
[https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/activate-built-in-tags.html](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/activate-built-in-tags.html)

## Step 4: Export data to Athena
[https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/athena.html](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/athena.html)

## Step 5: Give Kubecost access to Athena table

You’ll either need to 1) create an access key with the following IAM permission or 2) create the instance that Kubecost runs on with the following IAM permission. 
We recommend [kiam](https://github.com/uswitch/kiam) as a solution for adding IAM credentials to the instance.

```
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "athena:*"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "glue:CreateDatabase",
        "glue:DeleteDatabase",
        "glue:GetDatabase",
        "glue:GetDatabases",
        "glue:UpdateDatabase",
        "glue:CreateTable",
        "glue:DeleteTable",
        "glue:BatchDeleteTable",
        "glue:UpdateTable",
        "glue:GetTable",
        "glue:GetTables",
        "glue:BatchCreatePartition",
        "glue:CreatePartition",
        "glue:DeletePartition",
        "glue:BatchDeletePartition",
        "glue:UpdatePartition",
        "glue:GetPartition",
        "glue:GetPartitions",
        "glue:BatchGetPartition"
      ],
      "Resource": [
        "*"
      ]
    },
    {
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
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:ListBucket"
      ],
      "Resource": [
        "arn:aws:s3:::athena-examples*"
      ]
    },
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
        "cloudwatch:DeleteAlarms"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
```

## Step 6: Tag your resources

To allocate the resources to a kubernetes concept, use the following tag naming scheme:

<pre>
Namespace:  "kubernetes_namespace" : &lt;namespace>
Deployment: "kubernetes_deployment": &lt;deployment>
Pod:        "kubernetes_pod":        &lt;pod>
Daemonset:  "kubernetes_daemonset":  &lt;daemonset>
Container:  "kubernetes_container":  &lt;container>
</pre>

## Steps 7: Add AWS configuration details in the Kubecost product

Visit the Kubecost Cost Allocation page to provide region, Athena database, Athena table, and bucket name.
