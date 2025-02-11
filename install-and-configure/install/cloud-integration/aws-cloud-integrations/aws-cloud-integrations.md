# AWS Cloud Billing Integration

By default, Kubecost pulls on-demand asset prices from the public AWS pricing API. For more accurate pricing, this integration will allow Kubecost to reconcile your current measured Kubernetes spend with your actual AWS bill. This integration also properly accounts for Enterprise Discount Programs, Reserved Instance usage, Savings Plans, Spot usage, and more.

You will need permissions to create the Cost and Usage Report (CUR), and add IAM credentials for Athena and S3. Optional permission is the ability to add and execute CloudFormation templates. Kubecost does not require root access in the AWS account.

## Quick Start for IRSA

This guide contains multiple possible methods for connecting Kubecost to AWS billing, based on user environment and preference. Because of this, there may not be a straightforward approach for new users. To address this, a streamlined guide containing best practices can be found [here](aws-cloud-integration-using-irsa.md) for IRSA environments. This quick start guide has some assumptions to carefully consider, and may not be applicable for all users. See prerequisites in the linked article.

## Key AWS terminology

Integrating your AWS account with Kubecost may be a complicated process if you aren’t deeply familiar with the AWS platform and how it interacts with Kubecost. This section provides an overview of some of the key terminology and AWS services that are involved in the process of integration.

**Cost and Usage Report**: AWS report which tracks cloud spending and writes to an Amazon Simple Storage Service (Amazon S3) bucket for ingestion and long term historical data. The CUR is originally formatted as a CSV, but when integrated with Athena, is converted to Parquet format.

**Amazon Athena:** Analytics service which queries the CUR S3 bucket for your AWS cloud spending, then outputs data to a separate S3 bucket. Kubecost uses Athena to query for the bill data to perform [reconciliation](/install-and-configure/install/cloud-integration/README.md#reconciliation). Athena is technically optional for AWS cloud integration, but as a result, Kubecost will only provide unreconciled costs (on-demand public rates).

**S3 bucket:** Cloud object storage tool which both CURs and Athena output cost data to. Kubecost needs access to these buckets in order to read that data.

## Cost and Usage Report integration

For the below guide, a GitHub repository with sample files can be found [here](https://github.com/kubecost/poc-common-configurations/tree/main/aws).

### Step 1: Setting up a CUR

Follow [these steps](https://docs.aws.amazon.com/cur/latest/userguide/cur-create.html) to set up a Legacy CUR using the settings below.

* Select the _Legacy CUR export_ type.
* For time granularity, select _Daily_.
* Under 'Additional content', select the _Enable resource IDs_ checkbox.
* Under 'Report data integration' select the _Amazon Athena_ checkbox.

Remember the name of the bucket you create for CUR data. This will be used in Step 2.

{% hint style="warning" %}
Familiarize yourself with how column name restrictions differ between CURs and Athena tables. AWS may change your CUR name when you upload your CUR to your Athena table in Step 2, documented in AWS' [Running Amazon Athena queries](https://docs.aws.amazon.com/cur/latest/userguide/cur-ate-run.html). As best practice, use all lowercase letters and only use `_` as a special character.
{% endhint %}

AWS may take up to 24 hours to publish data. Wait until this is complete before continuing to the next step.

{% hint style="warning" %}
If you believe you have the correct permissions, but cannot access the Billing and Cost Management page, have the owner of your organization's root account follow [these instructions](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/control-access-billing.html#ControllingAccessWebsite-Activate).
{% endhint %}

### Step 2: Setting up Athena

As part of the CUR creation process, Amazon also creates a CloudFormation template that is used to create the Athena integration. It is created in the CUR S3 bucket, listed in the *Objects* tab in the path `s3-path-prefix/cur-name` and typically has the filename `crawler-cfn.yml`. This .yml is your necessary CloudFormation template. You will need it in order to complete the CUR Athena integration. See the AWS doc [Setting up Athena using AWS CloudFormation templates](https://docs.aws.amazon.com/cur/latest/userguide/use-athena-cf.html) to complete your Athena setup.

{% hint style="info" %}
Your S3 path prefix can be found by going to your AWS Cost and Usage Reports dashboard and selecting your newly-created CUR. In the 'Report details' tab, you will find the S3 path prefix.
{% endhint %}

Once Athena is set up with the CUR, you will need to create a new S3 bucket for Athena query results.

1. Navigate to the [S3 Management Console](https://console.aws.amazon.com/s3/home?region=us-east-2).
2. Select _Create bucket._ The Create Bucket page opens.
3. Use the same region used for the CUR bucket and pick a name that follows the format *aws-athena-query-results-*.
4. Select _Create bucket_ at the bottom of the page.
5. Navigate to the [Amazon Athena](https://console.aws.amazon.com/athena) dashboard.
6. Select _Settings_, then select _Manage._ The Manage settings window opens.
7. Set _Location of query result_ to the S3 bucket you just created, which will look like _s3://aws-athena-query-results..._, then select _Save._

{% hint style="info" %}
For Athena query results written to an S3 bucket only accessed by Kubecost, it is safe to expire or delete the objects after 1 day of retention.
{% endhint %}

### Step 3: Setting up IAM permissions

#### Add via CloudFormation:

Kubecost offers a set of CloudFormation templates to help set your IAM roles up.

{% hint style="info" %}
If you’re new to provisioning IAM roles, we suggest downloading our templates and using the CloudFormation wizard to set these up. You can learn how to do this in AWS' [Creating a stack on the AWS CloudFormation console](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-create-stack.html) doc. Open the step below which represents your CUR and management account arrangement, download the .yaml file listed, and upload them as the stack template in the 'Creating a stack' > 'Selecting a stack template' step.

<details>

<summary>My CUR exists in the same account as Kubecost or the management account</summary>

* Download [this .yaml file](https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-single-account-permissions.yaml).
* Navigate to the [AWS Console Cloud Formation page](https://console.aws.amazon.com/cloudformation).
* Select _Create Stack_, then select _With new resources (standard)_ from the dropdown.
* On the 'Create stack' page, under 'Prerequisite - Prepare Template', make sure *Template is ready* has been preselected. Under 'Specify Template', select *Upload a template file*. Select *Choose file*, then select your downloaded .yaml file from your file explorer. Select *Next*.
* On the 'Specify stack details' page, enter a name for your stack, then provide the following parameters:
  * S3CURBucket: The bucket where the CUR is set from Step 1
  * SpotDataFeedBucketName: (Optional, skip if you have not configured Spot data) The bucket where the Spot data feed is sent
* Select _Next_.
* On the 'Configure stack options' page opens, configure any additional options as needed. Select _Next_.
* On the 'Review stack' page, confirm all information, then select _I acknowledge that AWS CloudFormation might create IAM resources with custom names._
* Select _Submit._

</details>

<details>

<summary>My CUR exists in a member account different from Kubecost or the management account</summary>

**On each sub-account running Kubecost:**

* Download [this .yaml file](https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-sub-account-permissions.yaml).
  * Navigate to the [AWS Console Cloud Formation page](https://console.aws.amazon.com/cloudformation).
  * Select _Create Stack_, then select _With existing resources (import resources)_ from the dropdown. On the 'Identify resources' page, select _Next._
  * Under Template source, choose _Upload a template file_.
  * Select _Choose file_, which will open your file explorer. Select the .yaml template, and then select _Open_. Then, select _Next_.
  * On the 'Identify resources' page, provide any additional resources to import. Then, select _Next_.
  * For _Stack name_, enter a name for your template.
  * Set the following parameters:
    * MasterPayerAccountID: The account ID of the management account (formerly called master payer account) where the CUR has been created
    * SpotDataFeedBucketName: The bucket where the Spot data feed is sent
  * Select _Next_.
  * Select _Next_.
  * At the bottom of the page, select _I acknowledge that AWS CloudFormation might create IAM resources._
  * Select _Create Stack._

**On the management account:**

* Follow the same steps to create a CloudFormation stack as above, but using [this .yaml file](https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-management-account-permissions.yaml) instead, and with these parameters:
  * S3CURBucket: The bucket where the CUR is set from Step 1
  * KubecostClusterID: An account that Kubecost is running on that requires access to the Athena CUR.

</details>

#### Add manually:

<details>

<summary>My CUR exists in the same account as Kubecost or the management account</summary>

Attach the following policy to the same role or user. Use a user if you intend to integrate via ServiceKey, and a role if via IAM annotation (see more below under Via Pod Annotation by EKS). The SpotDataAccess policy statement is optional if the Spot data feed is configured (see “Setting up the Spot Data feed” step below).

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AthenaAccess",
      "Effect": "Allow",
      "Action": ["athena:*"],
      "Resource": ["*"]
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
      "Resource": ["arn:aws:s3:::aws-athena-query-results-*"]
    },
    {
      "Sid": "S3ReadAccessToAwsBillingData",
      "Effect": "Allow",
      "Action": ["s3:Get*", "s3:List*"],
      "Resource": ["arn:aws:s3:::${AthenaCURBucket}*"]
    },
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

<summary>My CUR exists in a member account different from Kubecost or the management account</summary>

**In the AWS account where Kubecost primary installation runs:**

* Create an IAM User or Role in the AWS account where your primary Kubecost is running.
* This Role or User links to the Kubernetes service account for Kubecost via IAM annotation (see more below under Via Pod Annotation by EKS), or via User with an Access/Secret Key.
* This Role/User will assume a role cross-account to the account where the CUR and Athena are created (the payer account), allowing Kubecost primary in a sub-account to get data from AWS Athena in the other top-level billing account.

**In the account where the AWS CUR is generated:**

* Create an IAM Role in the payer/CUR account. This is where you created the CUR export bucket and Athena query results bucket.

Now that you have the Sub-account User or Role plus the payer account Role, you will need to add policies to both.

#### Attach AssumeRole policy to IAM Role/User in Kubecost primary sub-account

Add the IAM Policy below to the IAM Role/User in the AWS sub-account with Kubecost primary. This policy allows the sub-account role to use sts:AssumeRole and assume the IAM Role created in the payer account.

The SpotDataAccess policy statement is optional, and only needed if the Spot data feed is configured (see “Setting up the Spot Data feed” step below).

{% code overflow="wrap" %}
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AssumeRoleInMasterPayer",
      "Effect": "Allow",
      "Action": "sts:AssumeRole",
      "Resource": "arn:aws:iam::${PayerAccountID}:role/<Kubecost IAM Role in payer account>"
    },
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
{% endcode %}

#### Attach Athena/CUR S3 Access Policy to IAM Role in payer account

Attach the following policy to the IAM Role created in the payer account. Replace `${S3CURBucket}` variable with your CUR bucket name, and check to make sure your Athena results bucket matches the format of aws-athena-query-results-*. If not, set the query result bucket in the policy to match your created bucket.

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "AthenaAccess",
      "Effect": "Allow",
      "Action": ["athena:*"],
      "Resource": ["*"]
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
      "Resource": ["arn:aws:s3:::aws-athena-query-results-*"]
    },
    {
      "Sid": "S3ReadAccessToAwsBillingData",
      "Effect": "Allow",
      "Action": ["s3:Get*", "s3:List*"],
      "Resource": ["arn:aws:s3:::${AthenaCURBucket}*"]
    }
  ]
}
```

#### Attach trust statement to IAM Role in payer account

We now need to make sure the payer account role trusts the sub-account User/Role.  Add the following trust statement to the Role in the payer account. (replace the `${kubecost-primary-subaccount-id}` variable with the account number of the sub-account running Kubecost primary):

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${kubecost-primary-subaccount-id}:root"
      },
      "Action": ["sts:AssumeRole"]
    }
  ]
}
```

</details>

### Step 4: Attaching IAM permissions to Kubecost

{% hint style="warning" %}
If you are using the alternative [multi-cloud integration](/install-and-configure/install/cloud-integration/multi-cloud.md) method, steps 4 and 5 are not required.
{% endhint %}

Now that the policies have been created, attach those policies to Kubecost. We support the following methods:

<details>

<summary>Attach via Service Key and Kubernetes Secret</summary>

Navigate to the [AWS IAM Console](https://console.aws.amazon.com/iam), then select _Access Management_ > _Users_ from the left navigation. Find the Kubecost User and select _Security credentials_ > _Create access key_. Follow along to receive the Access Key ID and Secret Access Key (AWS will not provide you the Secret Access Key in the future, so make sure you save this value). Then, follow the steps from either Option 1 or Option 2 below, but **not both.**

**Option 1: Generate a secret from Helm values:**

Note that this will leave your AWS keys unencrypted in your `values.yaml.` Set the following Helm values:

```yaml
kubecostProductConfigs:
  createServiceKeySecret: true
  awsServiceKeyName: <ACCESS_KEY_ID>
  awsServiceKeyPassword: <SECRET_ACCESS_KEY>
```

**Option 2: Manually create a secret:**

This may be the preferred method if your Helm values are in version control and you want to keep your AWS secrets out of version control.

1. Create a `service-key.json`:

```json
{
  "aws_access_key_id": "<ACCESS_KEY_ID>",
  "aws_secret_access_key": "<SECRET_ACCESS_KEY>"
}
```

2. Create a Kubernetes secret:

{% code overflow="wrap" %}
```bash
$ kubectl create secret generic <SECRET_NAME> --from-file=service-key.json --namespace <kubecost>
```
{% endcode %}

3. Set the Helm value:

```yaml
kubecostProductConfigs:
  serviceKeySecretName: <SECRET_NAME>
```

</details>

<details>

<summary>Attach via pod annotation with eksctl</summary>

**Prerequisites:**

* Amazon EKS cluster set up via [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html)
* [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) is installed on your device

**Step 1: Update configuration**

Download the following configuration files:

* [_cloud-integration.json_](https://github.com/kubecost/poc-common-configurations/blob/main/aws/cloud-integration.json)
* [_iam-payer-account-cur-athena-glue-s3-access.json_](https://github.com/kubecost/poc-common-configurations/blob/main/aws/iam-policies/cur/iam-payer-account-cur-athena-glue-s3-access.json)

Update the following variables in the files you downloaded:

* In _cloud-integration.json_, update the following values with the information in [Step 2: Setting up Athena](#step-2-setting-up-athena):

```json
    "athenaBucketName": "s3://<AWS_cloud_integration_athenaBucketName>",
    "athenaRegion": "<AWS_cloud_integration_athenaRegion>",
    "athenaDatabase": "<AWS_cloud_integration_athenaDatabase>",
    "athenaTable": "<AWS_cloud_integration_athenaTable>",
    "projectID": "<AWS_account_ID>"
```

{% hint style="info" %}
In your *cloud-integration.json*, you only need to provide a value for `masterPayerARN` when Kubecost is running in an AWS account different than the payer account Kubecost is querying (otherwise this value can be omitted from the config). `masterPayerARN` is the Amazon Resource Number of the role in the management account.
{% endhint %}

* In _iam-payer-account-cur-athena-glue-s3-access.json_, replace `ATHENA_RESULTS_BUCKET_NAME` with your Athena S3 bucket name (configured in Step 2: Setting up Athena).

**Step 2: Create policy**

In the same location where your downloaded configuration files are, run the following command to create the appropriate policy:

{% code overflow="wrap" %}
```
aws iam create-policy --policy-name iam-payer-account-cur-athena-glue-s3-access --policy-document file://iam-payer-account-cur-athena-glue-s3-access.json
```
{% endcode %}

**Step 3: Create OIDC provider for your cluster**

```
kubectl create ns kubecost
export YOUR_CLUSTER_NAME=<ENTER_YOUR_ACTUAL_CLUSTER_NAME>
export AWS_REGION=<ENTER_YOUR_AWS_REGION>
eksctl utils associate-iam-oidc-provider \
    --cluster ${YOUR_CLUSTER_NAME} --region ${AWS_REGION} \
    --approve
```

**Step 4: Create required IAM service accounts**

{% hint style="info" %}
Remember to replace `1234567890` with your AWS account ID number.
{% endhint %}

{% code overflow="wrap" %}
```
eksctl create iamserviceaccount \
    --name kubecost-serviceaccount-cur-athena-thanos \
    --namespace kubecost \
    --cluster ${YOUR_CLUSTER_NAME} --region ${AWS_REGION} \
    --attach-policy-arn arn:aws:iam::1234567890:policy/iam-payer-account-cur-athena-glue-s3-access \
    --override-existing-serviceaccounts \
    --approve
```
{% endcode %}

**Step 5: Create required secret to store the configuration**

{% code overflow="wrap" %}
```
kubectl create secret generic cloud-integration -n kubecost --from-file=cloud-integration.json
```
{% endcode %}

**Step 6. Install Kubecost via Helm**

{% code overflow="wrap" %}
```
helm upgrade --install kubecost --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
--namespace kubecost \
-f https://raw.githubusercontent.com/kubecost/poc-common-configurations/main/aws/values-amazon-primary.yaml
```
{% endcode %}

</details>

### Step 5: Provide CUR config values to Kubecost

These values must be set via `.Values.kubecostProductConfigs` in the Helm chart. Values for all fields must be provided.

{% hint style="warning" %}
If you set any `kubecostProductConfigs` from the Helm chart, all changes via the front end will be overridden on pod restart.
{% endhint %}

* `athenaProjectID`: The AWS AccountID where the Athena CUR is, likely your management account.
* `athenaBucketName`: An S3 bucket to store Athena query results that you’ve created that Kubecost has permission to access
  * The name of the bucket should match `s3://aws-athena-query-results-*`, so the IAM roles defined above will automatically allow access to it
  * The bucket can have a Canned ACL of `Private` or other permissions as you see fit.
* `athenaRegion`: The AWS region Athena is running in
* `athenaDatabase`: The name of the database created by the Athena setup
  * The athena database name is available as the value (physical id) of `AWSCURDatabase` in the CloudFormation stack created above (in [Step 2: Setting up Athena](#step-2-setting-up-athena))
* `athenaTable`: the name of the table created by the Athena setup
  * The table name is typically the database name with the leading `athenacurcfn_` removed (but is not available as a CloudFormation stack resource). Confirm the table name by visiting the Athena dashboard.
* `athenaWorkgroup`: The workgroup assigned to be used with Athena. If not specified, defaults to `Primary`

{% hint style="info" %}
Make sure to use only underscore as a delimiter if needed for tables and views. Using a hyphen/dash will not work even though you might be able to create it. See the [AWS docs](https://docs.aws.amazon.com/athena/latest/ug/tables-databases-columns-names.html) for more info.
{% endhint %}

If you are using a multi-account setup, you will also need to set `.Values.kubecostProductConfigs.masterPayerARN` to the Amazon Resource Number (ARN) of the role in the management account, e.g. `arn:aws:iam::530337586275:role/KubecostRole`.

## Troubleshooting

### Diagnostics through Kubecost UI

Once you've integrated with the CUR, you can visit _Settings_ > _Cloud Integrations_ in the UI to view if your integration was successful (indicated by a green checkmark). For more information, you can select *View Additional Details* to be taken to the Cloud Integrations page.

You can check pod logs for authentication errors by running: `kubectl get pods -n <namespace>` `kubectl logs <kubecost-pod-name> -n <namespace> -c cost-model`

If you do not see any authentication errors, log in to your AWS console and visit the Athena dashboard. Find your CUR and ensure that the database with the CUR matches the `athenaTable` entered in Step 5. It likely has a prefix with `athenacurcfn_` :

![Athena query editor](/images/athena-query-1.png)

You can also check query history to see if any queries are failing:

![Failed queries in Athena](/images/athena-query-2.png)

### Common Athena errors

#### Incorrect bucket in IAM Policy

* **Symptom:** A similar error to this will be shown on the Diagnostics page under Pricing Sources. You can search in the Athena "Recent queries" dashboard to find additional info about the error.

{% code overflow="wrap" %}
````
```
QueryAthenaPaginated: query execution error: no query results available for query <Athena Query ID>
```
````
{% endcode %}

```
And/or the following error will be found in the Kubecost `cost-model` container logs.

```

{% code overflow="wrap" %}
````
```
Permission denied on S3 path: s3://cur-report/cur-report/cur-report/year=2022/month=8

This query ran against the "athenacurcfn_test" database, unless qualified by the query. Please post the error message on our forum  or contact customer support  with Query Id: <Athena Query ID>
```
````
{% endcode %}

* **Resolution:** This error is typically caused by the incorrect (Athena results) s3 bucket being specified in the CloudFormation template of Step 3 from above. To resolve the issue, ensure the bucket used for storing the AWS CUR report (Step 1) is specified in the `S3ReadAccessToAwsBillingData` SID of the IAM policy (default: kubecost-athena-access) attached to the user or role used by Kubecost (Default: KubecostUser / KubecostRole). See the following example.

{% hint style="info" %}
This error can also occur when the management account cross-account permissions are incorrect, however, the solution may differ.
{% endhint %}

```json
{
  "Action": ["s3:Get*", "s3:List*"],
  "Resource": ["arn:aws:s3:::<AWS CUR BUCKET>*"],
  "Effect": "Allow",
  "Sid": "S3ReadAccessToAwsBillingData"
}
```

#### outputLocation is not a valid S3 path

* **Symptom:** A similar error to this will be shown on the Diagnostics page under Pricing Sources.

{% code overflow="wrap" %}
```
Connection test failed for cloud integration config: Fetch error: cloud billing data fetch error: GetCloudCost: error getting Athena columns: QueryAthenaPaginated: start query error: operation error Athena: StartQueryExecution, https response error StatusCode: 400, RequestID: a6059220-5ac8-4c24-97d2-401a2dbfd421, InvalidRequestException: outputLocation is not a valid S3 path.
```
{% endcode %}

* **Resolution:** Please verify that the prefix `s3://` was used when setting the `athenaBucketName` Helm value or when configuring the bucket name in the Kubecost UI.

#### Query not supported

* **Symptom:** A similar error to this will be shown on the Diagnostics page under Pricing Sources.

{% code overflow="wrap" %}
```
QueryAthenaPaginated: start query error: operation error Athena: StartQueryExecution, https response error StatusCode: 400, RequestID: <Athena Query ID>, InvalidRequestException: Queries of this type are not supported
```
{% endcode %}

* **Resolution:** While rare, this issue was caused by an Athena instance that failed to provision properly on AWS. The solution was to delete the Athena DB and deploy a new one. To verify this is needed, find the failed query ID in the Athena "Recent queries" dashboard and attempt to manually run the query.

#### HTTPS Response error

* **Symptom:** A similar error to this will be shown on the Diagnostics page under Pricing Sources.

{% code overflow="wrap" %}
```
QueryAthenaPaginated: start query error: operation error Athena: StartQueryExecution, https response error StatusCode: 400, RequestID: ********************, InvalidRequestException: Unable to verify/create output bucket aws-athena-query-results-test
```
{% endcode %}

* **Resolution:** Previously, if you ran a query without specifying a value for query result location, and the query result location setting was not overridden by a workgroup, Athena created a default location for you. Now, before you can run an Athena query in a region in which your account hasn't used Athena previously, you must specify a query result location, or use a workgroup that overrides the query result location setting. While Athena no longer creates a default query results location for you, previously created default `aws-athena-query-results-MyAcctID-MyRegion` locations remain valid and you can continue to use them. The bucket should be in the format of: `aws-athena-query-results-MyAcctID-MyRegion` It may also be required to remove and reinstall Kubecost. If doing this please remember to backup ETL files prior or contact support for additional assistance. See also this AWS doc on [specifying a query result location](https://docs.aws.amazon.com/athena/latest/ug/querying.html#query-results-specify-location).

#### Missing Athena column

* **Symptom:** A similar error to this will be shown on the Diagnostics page under Pricing Sources or in the Kubecost `cost-model` container logs.

{% code overflow="wrap" %}
```
QueryAthenaPaginated: query execution error: no query results available for query <Athena Query ID>

Checking the Athena logs we see a syntax error:

SYNTAX_ERROR: line 4:3: Column 'line_item_resource_id' cannot be resolved

This query ran against the "<DB Name>" database, unless qualified by the query
```
{% endcode %}

* **Resolution:** Verify in AWS' Cost and Usage Reports dashboard that the Resource IDs are enabled as "Report content" for the CUR created in Step 1. If the Resource IDs are not enabled, you will need to re-create the report (this will require redoing Steps 1 and 2 from this doc).

#### Not a valid S3 path

* **Symptom:** A similar error to this will be shown on the Diagnostics page under Pricing Sources or in the Kubecost `cost-model` container logs.

{% code overflow="wrap" %}
```
QueryAthenaPaginated: start query error: operation error Athena: StartQueryExecution, https response error StatusCode: 400, RequestID: <Athena Query ID>, InvalidRequestException: outputLocation is not a valid S3 path.
```
{% endcode %}

* **Resolution:** Verify that `s3://` was included in the bucket name when setting the `.Values.kubecostProductConfigs.athenaBucketName` Helm value.

### Failure when running the CloudFormation template in my AWS account due to low Lambda concurrent execution values

For AWS Lambda users, you may experience errors running the CloudFormation template created in Step 3 of this guide. This is likely due to your applied account-level quota value. To correct this, in the AWS console, visit the AWS Lambda page. If your value is set to 10 (the default value), it may be too low to run the template. Increase the value as needed.

![AWS Lambda](/images/aws-lambda.png)

## Viewing account-level tags

Account-level tags are applied (as labels) to all the Assets built from resources defined under a given AWS account. You can filter AWS resources in the Kubecost Assets View (or API) by account-level tags by adding them ('tag:value') in the Label/Tag filter.

If a resource has a label with the same name as an account-level tag, the resource label value will take precedence.

Modifications incurred on account-level tags may take several hours to update on Kubecost.

Your AWS account will need to support the `organizations:ListAccounts` and `organizations:ListTagsForResource` policies to benefit from this feature.

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
