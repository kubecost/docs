# AWS Cross-Account Billing Integration

There are many ways to configure Kubecost to pull the Cost and Usage Report (CUR) from AWS.

This guide is intended as the best-practice method for users meeting the assumptions below. There is a separate guide which has more options: [AWS Cloud Integration](aws-cloud-integrations.md)

The below guide assumes the following:
1. Kubecost will run in a different account than the AWS Payer Account
1. The IAM permissions will utilize AWS [IRSA](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) to avoid shared secrets
1. The configuration of Kubecost will be done using a *cloud-integration.json* file, and not via Kubecost UI (following infrastructure as code practices)

## Overview of Kubecost CUR integration

This guide is a one-time setup per AWS Payer Account and is typically one per organization. It can be automated, but may not be worth the effort given that it will not be needed again.

<details>

<summary>Basic diagram when the below steps are complete:</summary>

![cur-diagram](/images/aws-cur/kubecost-cross-account-cur-diagram.png)

</details>

Kubecost supports multiple AWS Payer Accounts as well as multiple cloud providers from a single Kubecost primary cluster. For multiple Payer Accounts, create additional entries inside the array below.

Detail for multiple cloud provider setups is [here](https://docs.kubecost.com/install-and-configure/install/cloud-integration/multi-cloud#aws).

## Configuration

Create a file called *cloud-integration.json* as below:
```json
{
    "aws": [
        {
            "athenaBucketName": "s3://ATHENA_RESULTS_BUCKET_NAME",
            "athenaRegion": "ATHENA_REGION",
            "athenaDatabase": "ATHENA_DATABASE",
            "athenaTable": "ATHENA_TABLE",
            "athenaWorkgroup": "primary",
            "projectID": "ATHENA_PROJECT_ID",
            "masterPayerARN": "PAYER_ACCOUNT_ROLE_ARN"
        }
    ]
}
```

Provide the following values to this file, then save the file for future use:

- `projectID` is the AWS payer account number where the CUR is located and where the Kubecost primary cluster is running.
- `athenaWorkgroup` will be `primary` when following this guide.

Following this guide, you will be able to generate the remaining other values.

### Step 1: Create a CUR Export (and wait 24 hours)

Follow the [AWS documentation](https://docs.aws.amazon.com/cur/latest/userguide/cur-create.html) to create a CUR export using the settings below.

* For time granularity, select _Daily_.
* Select the checkbox to enable _Resource IDs_ in the report.
* Select the checkbox to enable _Athena integration_ with the report.
* Select the checkbox to enable the JSON IAM policy to be applied to your bucket.

<details>

<summary>Screenshots from select CUR creation in the above AWS documentation</summary>

![CUR-export-config](/images/aws-cur/1-cur-nav.png)
![resource-ids](/images/aws-cur/2-cur-create-step1.png)
![bucket-permissions](/images/aws-cur/3-cur-s3-bucket.png)
![delivery-options](/images/aws-cur/4-delivery-options.png)
</details>

{% hint style="info" %}
If this CUR data is only used by Kubecost, it is safe to expire or delete the objects after seven days of retention.
{% endhint %}

Note the name of the bucket you create for CUR data as `CUR_BUCKET_NAME`.

AWS may take up to 24 hours to publish data. Wait until this is complete before continuing to the next step.

### Step 2: Setting up Athena

As part of the CUR creation process, Amazon creates a CloudFormation template that is used to create the Athena integration. It is created in the CUR S3 bucket under `s3-path-prefix/cur-name` and typically has the filename *crawler-cfn.yml*. This .yml is your CloudFormation template. You will need it in order to complete the CUR Athena integration. You can read more about this [here](https://docs.aws.amazon.com/cur/latest/userguide/use-athena-cf.html).

![athena-output-bucket](/images/aws-cur/8-upload-cfn-template.png)

{% hint style="info" %}
Your S3 path prefix can be found by going to your AWS Cost and Usage Reports dashboard and selecting your bucket's report. In the Report details tab, you will find the S3 path prefix.
{% endhint %}

Once Athena is set up with the CUR, you will need to create a *new* S3 bucket for Athena query results which will be the `ATHENA_RESULTS_BUCKET_NAME` value. The bucket used for the CUR cannot be used for the Athena output.

1. Navigate to the [S3 Management Console](https://console.aws.amazon.com/s3/home?region=us-east-2).
2. Select _Create bucket._ The Create Bucket page opens.
3. Use the same region used for the CUR bucket. This is the value for `athenaBucketName`.
4. Select _Create bucket_ at the bottom of the page.
5. Navigate to the [Amazon Athena](https://console.aws.amazon.com/athena) dashboard.
6. Select _Settings_, then select _Manage._ The Manage settings window opens.
7. Set _Location of query result_ to the S3 bucket you just created, then select _Save._

Navigate to Athena in the AWS Console. Be sure the region matches the one used in the steps above. Now it's time to update your *configuration.json* file with the following values. Use the screenshots below for help.

![CUR-Config](/images/aws-cur/6-cur-config.png)

* `athenaDatabase`: the value in the Database dropdown
* `athenaRegion`: the AWS region value where your Athena query is configured
* `athenaTable`: the partitioned value found in the Table list

{% hint style="info" %}
For Athena query results written to an S3 bucket only accessed by Kubecost, it is safe to expire or delete the objects after one day of retention.
{% endhint %}

### Step 3: Download configuration templates

The policy documents required can be cloned in our [poc-common-config repo](https://github.com/kubecost/poc-common-configurations/tree/main/aws-attach-roles). You will need the following files:
*    _iam-payer-account-cur-athena-glue-s3-access.json_
*    _iam-payer-account-trust-primary-account.json_
*    *iam-access-cur-in-payer-account.json*

### Step 4: Setting up Payer Account IAM permissions

**From the AWS Payer Account**

In _iam-payer-account-cur-athena-glue-s3-access.json_, replace all `ATHENA_RESULTS_BUCKET_NAME` instances with your Athena S3 bucket name (the default will look like `aws-athena-query-results-xxxx`).

In *iam-payer-account-trust-primary-account.json*, replace `SUB_ACCOUNT_222222222` with the account number of the account where the Kubecost primary cluster will run.

In the same location as your downloaded configuration files, run the following command to create the appropriate policy (`jq` is not required):

{% code overflow="wrap" %}
```sh
aws iam create-role --role-name kubecost-cur-access \
  --assume-role-policy-document file://iam-payer-account-trust-primary-account.json \
  --output json | jq -r .Role.Arn
```

The output is the value for the `PAYER_ACCOUNT_ROLE_ARN`:

```
arn:aws:iam::PAYER_ACCOUNT_11111111111:role/kubecost-cur-access
```

Update the placeholders (everything with a `_` ex. `ATHENA_DATABASE`) in *iam-payer-account-cur-athena-glue-s3-access.json* and attach the required policies to the new role:

```sh
aws iam put-role-policy --role-name kubecost-cur-access \
  --policy-name kubecost-payer-account-cur-athena-glue-s3-access \
  --policy-document file://iam-payer-account-cur-athena-glue-s3-access.json
```

Then allow Kubecost to read account tags:

```sh
aws iam put-role-policy --role-name kubecost-cur-access \
  --policy-name kubecost-payer-account-list-tags-policy \
  --policy-document file://iam-payer-account-list-tags-policy.json
```
{% endcode %}

Now we can obtain the last value `masterPayerARN` for *cloud-integration.json* as the ARN associated with the newly-created IAM role, as seen below in the AWS console:

![ARN](/images/masterPayerARN.png)

### Step 5: Setting up IAM permissions for the primary cluster

**From the AWS Account where the Kubecost primary cluster will run**

In *iam-access-cur-in-payer-account.json*, update `PAYER_ACCOUNT_11111111111` with the AWS account number of the Payer Account and create a policy allowing Kubecost to assumeRole in the Payer Account:

```sh
aws iam create-policy --policy-name kubecost-access-cur-in-payer-account \
  --policy-document file://iam-access-cur-in-payer-account.json \
  --output json |jq -r .Policy.Arn
```

Note the output ARN (used in the `iamserviceaccount --attach-policy-arn` below):
```
arn:aws:iam::SUB_ACCOUNT_222222222:policy/kubecost-access-cur-in-payer-account
```

Create a namespace and set environment variables:

```sh
kubectl create ns kubecost
export CLUSTER_NAME=YOUR_CLUSTER
export AWS_REGION=YOUR_REGION
```

Enable the OIDC-Provider:

```sh
eksctl utils associate-iam-oidc-provider \
    --cluster $CLUSTER_NAME --region $AWS_REGION \
    --approve
```

Create the Kubernetes service account, attaching the assumeRole policy:

**Note:** Replace `SUB_ACCOUNT_222222222` with the AWS account number where the primary Kubecost cluster will run.

{% code overflow="wrap" %}
```sh
eksctl create iamserviceaccount \
    --name kubecost-serviceaccount \
    --namespace kubecost \
    --cluster $CLUSTER_NAME --region $AWS_REGION \
    --attach-policy-arn arn:aws:iam::SUB_ACCOUNT_222222222:policy/kubecost-access-cur-in-payer-account \
    --override-existing-serviceaccounts \
    --approve
```
{% endcode %}

Create the secret (in this setup, there are no actual secrets in this file):

{% code overflow="wrap" %}
```
kubectl create secret generic cloud-integration -n kubecost --from-file=cloud-integration.json
```
{% endcode %}

Install Kubecost using the service account and cloud-integration secret:

{% code overflow="wrap" %}
```sh
helm install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost \
  --set serviceAccount.name=kubecost-serviceaccount \
  --set serviceAccount.create=false \
  --set kubecostProductConfigs.cloudIntegrationSecret=cloud-integration
```
{% endcode %}


## Validation

It can take over an hour to process the billing data for large AWS accounts. In the short-term, follow the logs and look for a message similar to `(7.7 complete)`, which should grow gradually to `(100.0 complete)`. Some errors (ERR) are expected, as seen below.

```
kubectl logs -l app=cost-analyzer --tail -1 --follow |grep -i athena
------------------
Defaulted container "cost-model" out of: cost-model, cost-analyzer-frontend
2023-05-24T19:41:31.63093249Z ERR Failed to lookup reserved instance data: no reservation data available in Athena
2023-05-24T19:41:31.630973097Z ERR Failed to lookup savings plan data: Error fetching Savings Plan Data: QueryAthenaPaginated: athena configuration incomplete
2023-05-24T19:41:34.577437245Z INF Adding AWS Provider to map with key: 440082503234/s3://aws-athena-query-results-
2023-05-24T19:41:34.57901059Z INF ETL: CloudUsage[440082503234/s3://aws-athena-query-results-]: Starting PipelineController
2023-05-24T19:41:34.579037927Z INF CloudCost: IngestionManager: creating integration with key: 440082503234/s3://aws-athena-query-results-
2023-05-24T19:41:34.581131953Z INF RunBuildProcess[CloudCost][440082503234/s3://aws-athena-query-results-]: build[NLzAH]: Starting build back to 2023-02-22 00:00:00 +0000 UTC in blocks of 7d
2023-05-24T19:41:34.581715777Z INF CloudCost[440082503234/s3://aws-athena-query-results-]: ingestor: building window [2023-05-17T00:00:00+0000, 2023-05-24T00:00:00+0000)
2023-05-24T19:41:34.581771159Z INF AthenaIntegration[440082503234/s3://aws-athena-query-results-]: StoreCloudCost: [2023-05-17T00:00:00+0000, 2023-05-24T00:00:00+0000)
2023-05-24T19:41:34.608040758Z ERR ETL:  CloudUsage[440082503234/s3://aws-athena-query-results-]: Build[XPQMa]:  failed to load range from back up 2023-05-18 00:00:00 +0000 UTC - 2023-05-25 00:00:00 +0000 UTC: file does not exist
2023-05-24T19:41:34.60806207Z INF ETL: CloudUsage[440082503234/s3://aws-athena-query-results-]: Build[XPQMa]: QueryCloudUsage [2023-05-18T00:00:00+0000, 2023-05-25T00:00:00+0000)
2023-05-24T19:41:34.588661972Z INF ETL: CloudUsage[440082503234/s3://aws-athena-query-results-]: Run[JkSYH]: QueryCloudUsage [2023-05-21T00:00:00+0000, 2023-05-25T00:00:00+0000)
2023-05-24T19:41:50.528544821Z INF ETL: CloudUsage[440082503234/s3://aws-athena-query-results-]: Build[XPQMa]: coverage [2023-05-18T00:00:00+0000, 2023-05-25T00:00:00+0000) (7.7 complete)
```

## Troubleshooting

For help with troubleshooting, see the section in our original [AWS integration guide](https://docs.kubecost.com/install-and-configure/install/cloud-integration/aws-cloud-integrations#troubleshooting).
