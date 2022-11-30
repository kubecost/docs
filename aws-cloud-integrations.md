# AWS Cloud Integrations

Kubecost pulls asset prices from the public AWS pricing API by default. To have accurate pricing information from AWS, you can integrate directly with your account. This integration will properly account for Enterprise Discount Programs, Reserved Instance usage, Savings Plans, spot usage, and more.

You will need necessary permissions to create the Cost and Usage Report (CUR), and add IAM credentials for Athena and S3. Optional permission is the ability to add and execute CloudFormation templates. Kubecost does not require root access in the AWS account.

A GitHub repository with sample files used in below instructions can be found here: [https://github.com/kubecost/poc-common-configurations/tree/main/aws](https://github.com/kubecost/poc-common-configurations/tree/main/aws)

## Cost and Usage Report integration

### Step 1: Setting up the CUR

Follow [these steps](https://docs.aws.amazon.com/cur/latest/userguide/cur-create.html) to set up a CUR. For time granularity, select _Daily_. Be sure to enable Resource IDs and Athena integration when creating the CUR.

Remember the name of the bucket you create for CUR data. This will be used in Step 2.

> **Note**: If you believe you have the correct permissions, but cannot access the Billing and Cost Management page, have the owner of your organization's root account follow [these instructions](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/control-access-billing.html#ControllingAccessWebsite-Activate)

AWS may take up to 24 hours to publish data. Wait until this is complete before continuing to the next step.

### Step 2: Setting up Athena

As part of the CUR creation process, Amazon also creates a CloudFormation template that is used to create the Athena integration. It is created in the CUR S3 bucket under `your-billing-prefix/cur-name` and typically has the filename `crawler-cfn.yml`. You will need to deploy this CloudFormation template in order to complete the CUR Athena integration. You can read more about this [here](https://docs.aws.amazon.com/cur/latest/userguide/use-athena-cf.html).

Once Athena is set up with the CUR, you will need to create a new S3 bucket for Athena query results.

1. Navigate to https://console.aws.amazon.com/s3
2. Select _Create Bucket_
3. Be sure to use the same region as was used for the CUR bucket and pick a name that follows the format `aws-athena-query-results-*`
4. Select _Create Bucket_
5. Navigate to https://console.aws.amazon.com/athena
6. Select _Settings_
7. Set _Query result location_ to the S3 bucket you just created

### Step 3: Setting up IAM permissions

#### Add via CloudFormation:

Kubecost offers a set of CloudFormation templates to help set your IAM roles up. If you’re new to provisioning IAM roles, we suggest downloading our templates and using the CloudFormation wizard to set these up, as explained [here](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-create-stack.html). Download template files from the URLs provided below and upload them as the stack template in the Creating a stack > Selecting a stack template step.

<details>

<summary>My Kubernetes clusters all run in the same account as the master payer account.</summary>

* Download this file: [https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-single-account-permissions.yaml](https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-single-account-permissions.yaml)
* Navigate to [https://console.aws.amazon.com/cloudformation](https://console.aws.amazon.com/cloudformation)
* Click **Create New Stack** if you have never used AWS CloudFormation before. Otherwise, select **Create Stack**, and select **With new resource (standard)**
* Under **Prepare template**, choose **Template is ready**.
* Under **Template source**, choose **Upload a template file**.
* Select **Choose file**.
* Choose the downloaded .yaml template, and then choose **Open**.
* Choose **Next**.
* For **Stack name**, enter a name for your template
* Set the following parameters:
  * AthenaCURBucket: The bucket where the CUR is sent from Step 1
  * SpotDataFeedBucketName: Optional: The bucket where the spot data feed is sent from the “Setting up the Spot Data feed” step (see below)
* Choose **Next**.
* Choose **Next**
* At the bottom of the page, select **I acknowledge that AWS CloudFormation might create IAM resources.**
* Choose **Create Stack**

</details>

<details>

<summary>My Kubernetes clusters run in different accounts from the master payer account</summary>

* On each sub account running Kubecost
  * Download this file: [https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-sub-account-permissions.yaml](https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-sub-account-permissions.yaml)
    * Navigate to [https://console.aws.amazon.com/cloudformation](https://console.aws.amazon.com/cloudformation)
    * Choose **Create New Stack** if you have never used AWS CloudFormation before. Otherwise, choose **Create Stack**.
    * Under **Prepare template**, choose **Template is ready**.
    * Under **Template source**, choose **Upload a template file**.
    * Select **Choose file**.
    * Choose the downloaded .yaml template, and then choose **Open**.
    * Choose **Next**.
    * For **Stack name**, enter a name for your template
    * Set the following parameters:
    * MasterPayerAccountID: The account ID of the master payer account where the CUR has been created
    * SpotDataFeedBucketName: The bucket where the spot data feed is sent from the “Setting up the Spot Data feed” step
    * Choose **Next**.
    * Choose **Next**
    * At the bottom of the page, select **I acknowledge that AWS CloudFormation might create IAM resources.**
    * Choose **Create Stack**
  * On the master payer account
    * Follow the same steps to create a CloudFormation stack as above, but with the following as your .yaml file instead: [https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-masterpayer-account-permissions.yaml](https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-masterpayer-account-permissions.yaml) , and with these parameters:
    * AthenaCURBucket: The bucket where the CUR is set from Step 1
    * KubecostClusterID: An account that Kubecost is running on that requires access to the Athena CUR

</details>

#### Add manually

<details>

<summary>My Kubernetes clusters run in the same account as the master payer account</summary>

Attach both of the following policies to the same role or user. Use a user if you intend to integrate via ServiceKey, and a role if via IAM annotation (See more below under Via Pod Annotation by EKS). The SpotDataAccess policy statement is optional if the spot data feed is configured (see “Setting up the Spot Data feed” step below)

```
        {
           "Version": "2012-10-17",
           "Statement": [
              {
                 "Sid": "AthenaAccess",
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
                    "arn:aws:s3:::${AthenaCURBucket}*"
                 ]
              }
           ]
        }
	{
           "Version": "2012-10-17",
           "Statement": [
              {
                 "Sid": "SpotDataAccess",
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

</details>

<details>

<summary>My Kubernetes clusters run in different accounts</summary>

On each sub account running kubecost, attach both of the following policies to the same role or user. Use a user if you intend to integrate via ServiceKey, and a role if via IAM annotation (See more below under Via Pod Annotation by EKS). The SpotDataAccess policy statement is optional if the spot data feed is configured (see “Setting up the Spot Data feed” step below)

```
	{
               "Version": "2012-10-17",
               "Statement": [
                  {
                     "Sid": "AssumeRoleInMasterPayer",
                     "Effect": "Allow",
                     "Action": "sts:AssumeRole",
                     "Resource": "arn:aws:iam::${MasterPayerAccountID}:role/KubecostRole-${This-account’s-id}"
                  }
               ]
	}

	{
               "Version": "2012-10-17",
               "Statement": [
                  {
                     "Sid": "SpotDataAccess",
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

On the masterpayer account, attach this policy to a role (replace `${AthenaCURBucket}` variable):

```
	{
               "Version": "2012-10-17",
               "Statement": [
                  {
                     "Sid": "AthenaAccess",
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
                        "arn:aws:s3:::${AthenaCURBucket}*"
                     ]
                  }
               ]
	}
```

Then add the following trust statement to the role the policy is attached to (replace `${KubecostClusterID}` variable):

```
	{
               "Version": "2012-10-17",
               "Statement": [
                  {
                     "Effect": "Allow",
                     "Principal": {
                        "AWS": "arn:aws:iam::${KubecostClusterID}:root"
                     },
                     "Action": [
                        "sts:AssumeRole"
                     ]
                  }
               ]
            }
```

</details>

### Step 4: Attaching IAM permissions to Kubecost

> **Note:** If you are using the alternative [multi-cloud integration](https://docs.kubecost.com/install-and-configure/advanced-configuration/cloud-integration/multi-cloud) method, steps 4 and 5 are not required. The use of "Attach via Pod Annotation on EKS" authentication is optional.

Now that the policies have been created, attach those policies to Kubecost. We support the following methods:

<details>

<summary>Attach via ServiceKey And Kubernetes Secret</summary>

Navigate to [https://console.aws.amazon.com/iam](https://console.aws.amazon.com/iam) > Access Management > Users. Find the Kubecost User and select Security Credentials > Create Access Key. Note the Access Key ID and Secret Access Key. Set the below configs from either Option 1 or Option 2, but _not both_.

**Option 1 (generate a secret from Helm values):**

Note that this will leave your AWS keys unencrypted in your `values.yaml.` Set the following helm values:

```yaml
kubecostProductConfigs:
  awsServiceKeyName: <ACCESS_KEY_ID>
  awsServiceKeyPassword: <SECRET_ACCESS_KEY>
```

**Option 2 (manually create a secret):**

This may be the preferred method if your Helm values are in version control and you want to keep your AWS secrets out of version control.

* Create a `service-key.json`:

```json
{
    "aws_access_key_id": "<ACCESS_KEY_ID>",
    "aws_secret_access_key": "<SECRET_ACCESS_KEY>"
}
```

* Create a kubernetes secret:

```bash
$ kubectl create secret generic <SECRET_NAME> --from-file=service-key.json --namespace <kubecost> 
```

* Set the helm value:

```yaml
kubecostProductConfigs:
  serviceKeySecretName: <SECRET_NAME>
```

</details>

<details>

<summary>Attach via Service Key on Kubecost frontend</summary>

* Navigate to [https://console.aws.amazon.com/iam](https://console.aws.amazon.com/iam) Access Management > Users. Find the Kubecost User and select Security Credentials > Create Access Key. Note the Access key ID and Secret access key.
* You can add the Access key ID and Secret access key on /settings.html > External Cloud Cost Configuration (AWS) > Update and setting Service key name to **Access key ID** and Service key secret to **Secret access key**

</details>

<details>

<summary>Attach via Pod Annotation on EKS</summary>

* First, create an OIDC provider for your cluster with these [steps](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html)
* Next, create a Role with these [steps](https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html).
  * When asked to attach policies, you’ll want to attach the policies created above in Step 3
  * When asked for “namespace” and “serviceaccountname” use the namespace Kubecost is installed in and the name of the serviceaccount attached to the cost-analyzer pod. You can find that name by running `kubectl get pods kubecost-cost-analyzer-69689769b8-lf6nq -n <kubecost-namespace> -o yaml | grep serviceAccount`
* Then, you need to add an annotation to that service account as described in these [docs](https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html). This annotation can be added to the Kubecost service account by setting `.Values.serviceAccount.annotations` in the helm chart to `eks.amazonaws.com/role-arn: arn:aws:iam::<AWS_ACCOUNT_ID>:role/<IAM_ROLE_NAME>`

**Note**: If you see the error: `User: ***/assumed-role/<role-name>/### is not authorized to perform: sts:AssumeRole on resource...`, you can add the following to your policy permissions to allow the role the correct permissions:

```
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
```

</details>

<details>

<summary>Attach via Pod Annotation on EKS</summary>

* First, create an OIDC provider for your cluster with these [steps](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html)
* Next, create a Role with these [steps](https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html).
  * When asked to attach policies, you’ll want to attach the policies created above in Step 3
  * When asked for “namespace” and “serviceaccountname” use the namespace Kubecost is installed in and the name of the serviceaccount attached to the cost-analyzer pod. You can find that name by running `kubectl get pods kubecost-cost-analyzer-69689769b8-lf6nq -n <kubecost-namespace> -o yaml | grep serviceAccount`
* Then, you need to add an annotation to that service account as described in these [docs](https://docs.aws.amazon.com/eks/latest/userguide/associate-service-account-role.html). This annotation can be added to the Kubecost service account by setting `.Values.serviceAccount.annotations` in the helm chart to `eks.amazonaws.com/role-arn: arn:aws:iam::<AWS_ACCOUNT_ID>:role/<IAM_ROLE_NAME>`

**Note**: If you see the error: `User: ***/assumed-role/<role-name>/### is not authorized to perform: sts:AssumeRole on resource...`, you can add the following to your policy permissions to allow the role the correct permissions:

```
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Effect": "Allow",
            "Resource": "*"
        }
    ]
```

</details>

### Step 5: Provide CUR config values to Kubecost

These values can either be set from the kubecost frontend or via .Values.kubecostProductConfigs in the helm chart. Note that if you set any kubecostProductConfigs from the Helm chart, all changes via the frontend will be overridden on pod restart.

* `athenaProjectID` e.g. "530337586277" # The AWS AccountID where the Athena CUR is. Generally your master payer account.
* `athenaBucketName` An S3 bucket to store Athena query results that you’ve created that Kubecost has permission to access
  * The name of the bucket should match `s3://aws-athena-query-results-*`, so the IAM roles defined above will automatically allow access to it
  * The bucket can have a Canned ACL of `Private` or other permissions as you see fit.
* `athenaRegion` The aws region athena is running in
* `athenaDatabase` the name of the database created by the Athena setup
  * The athena database name is available as the value (physical id) of `AWSCURDatabase` in the CloudFormation stack created above (in [Step 2: Setting up Athena](aws-cloud-integrations.md#Step-2:-Setting-up-Athena))
* `athenaTable` the name of the table created by the Athena setup
  * The table name is typically the database name with the leading `athenacurcfn_` removed (but is not available as a CloudFormation stack resource)
* `athenaWorkgroup` The workgroup assigned to be used with Athena. If not specified, defaults to `Primary`

> **Note**: Make sure use only underscore as a delimiter if needed for tables and views, using dash will not work even though you might be able to create it see [docs](https://docs.aws.amazon.com/athena/latest/ug/tables-databases-columns-names.html).

* If you are using a multi-account setup, you will also need to set `.Values.kubecostProductConfigs.masterPayerARN` to the Amazon Resource Number (ARN) of the role in the masterpayer account, e.g. `arn:aws:iam::530337586275:role/KubecostRole`.

## Troubleshooting

Once you've integrated with the CUR, you can visit /diagnostics.html in Kubecost to determine if Kubecost has been successfully integrated with your CUR. If any problems are detected, you will see a yellow warning sign under the cloud provider permissions status header:

![Screen Shot 2020-12-06 at 9 37 40 PM](https://user-images.githubusercontent.com/453512/101316930-587bb080-3812-11eb-8bbc-694a894314d8.png)

You can check pod logs for authentication errors by running: `kubectl get pods -n <namespace>` `kubectl logs <kubecost-pod-name> -n <namespace> -c cost-model`

If you do not see any authentication errors, log in to your AWS console and visit the Athena dashboard. You should be able to find the CUR. Ensure that the database with the CUR matches the athenaTable entered in step 4-- it likely has a prefix with athenacurfn\_ :

![Screen Shot 2020-12-06 at 9 43 31 PM](https://user-images.githubusercontent.com/453512/101319459-e6f23100-3816-11eb-8d96-1ab977cb50bd.png)

You can also check query history to see if any queries are failing:

![Screen Shot 2020-12-06 at 9 43 50 PM](https://user-images.githubusercontent.com/453512/101319633-24ef5500-3817-11eb-9f87-55a903428936.png)

### Common Athena errors.

#### Incorrect bucket in IAM Policy.

*   **Symptom:** A similar error to this will be shown on the diagnostics page under "Pricing Sources" on the "Diagnostics" page. You can search for the in the Athena "Recent queries" dashboard to find additional info about the error.

    ```
    QueryAthenaPaginated: query execution error: no query results available for query <Athena Query ID>
    ```

    And / or the following error will be found in the Kubecost `cost-model` container logs.

    ```
    Permission denied on S3 path: s3://cur-report/cur-report/cur-report/year=2022/month=8

    This query ran against the "athenacurcfn_test" database, unless qualified by the query. Please post the error message on our forum  or contact customer support  with Query Id: <Athena Query ID>
    ```
*   **Resolution:** This error is typically caused by the incorrect (Athena results) s3 bucket being specified in the cloudformation template of step 3 from above. To resolve the issue ensure the bucket used for storing the AWS CUR report (step 1) is specified in the `S3ReadAccessToAwsBillingData` SID of the IAM policy (default: kubecost-athena-access) attached to the user or role used by Kubecost (Default: KubecostUser / KubecostRole). See the following example. **NOTE:** This error can also occur when master payer cross account permissions are incorrect, that solution may differ.

    ```
            {
            "Action": [
                "s3:Get*",
                "s3:List*"
            ],
            "Resource": [
                "arn:aws:s3:::<AWS CUR BUCKET>*"
            ],
            "Effect": "Allow",
            "Sid": "S3ReadAccessToAwsBillingData"
        }
    ```

#### Query not supported

* **Symptom:** A similar error to this will be shown on the diagnostics page under "Pricing Sources" on the "Diagnostics" page.

```
QueryAthenaPaginated: start query error: operation error Athena: StartQueryExecution, https response error StatusCode: 400, RequestID: <Athena Query ID>, InvalidRequestException: Queries of this type are not supported
```

* **Resolution:** While rare, this issue was caused by and Athena instance which failed to provision properly on AWS. The solution was to delete the Athena DB and deploy a new one. To verify this is needed, find the failed query ID in the Athena "Recent queries" dashboard and attempt to manually run the query.

#### HTTPS Response error

* **Symptom:** A similar error to this will be shown on the diagnostics page under "Pricing Sources" on the "Diagnostics" page.

```
QueryAthenaPaginated: start query error: operation error Athena: StartQueryExecution, https response error StatusCode: 400, RequestID: ********************, InvalidRequestException: Unable to verify/create output bucket aws-athena-query-results-test
```

* **Resolution:** Previously, if you ran a query without specifying a value for Query result location, and the query result location setting was not overridden by a workgroup, Athena created a default location for you. Now, before you can run an Athena query in a region in which your account hasn't used Athena previously, you must specify a query result location, or use a workgroup that overrides the query result location setting. While Athena no longer creates a default query results location for you, previously created default aws-athena-query-results-MyAcctID-MyRegion locations remain valid and you can continue to use them. https://docs.aws.amazon.com/athena/latest/ug/querying.html#query-results-specify-location The bucket should be in the format of: `aws-athena-query-results-MyAcctID-MyRegion` It may also be required to remove and reinstall Kubecost. If doing this please remeber to backup ETL files prior or contact support for additional assistance.

## Relating out-of-cluster costs to k8s resources via tags?

* [Activating User-Defined Cost Allocation Tags - AWS Billing and Cost Management](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/activating-tags.html)
* See [Step 2 here](http://docs.kubecost.com/aws-out-of-cluster.html) for more information on how to supply tags or use existing tags.

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

## Troubleshooting Spot data feed

### Spot data instance not found

![1fva81l9sph6hh-image](https://user-images.githubusercontent.com/102574445/199281977-3195b1d1-e3a5-4561-85da-eb8b24e23f27.png)

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

## Summary and pricing

AWS services used here are:

* [Athena](https://aws.amazon.com/athena/pricing/)
* [S3](https://aws.amazon.com/s3/pricing/)
* [EC2](https://aws.amazon.com/ec2/pricing/)

Kubecost's `cost-model` requires roughly 2 CPU and 10 GB of RAM per 50,000 pods monitored. The backing Prometheus database requires roughly 2 CPU and 25 GB per million metrics ingested per minute. You can pick the EC2 instances necessary to run Kubecost accordingly.

* [EBS](https://aws.amazon.com/ebs/pricing/)

Kubecost can write its cache to disk. Roughly 32 GB per 100,000 pods monitored is sufficient. (Optional: our cache can exist in memory)

* [Cloudformation](https://aws.amazon.com/cloudformation/pricing/) (Optional: manual IAM configuration or via Terraform is fine)
* [EKS](https://aws.amazon.com/eks/pricing/) (Optional: all K8s flavors are supported)
