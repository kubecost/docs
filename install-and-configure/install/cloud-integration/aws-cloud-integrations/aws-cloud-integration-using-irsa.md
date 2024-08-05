# AWS Cloud Integration Using IRSA/EKS Pod Identities

There are many ways to integrate your AWS Cost and Usage Report (CUR) with Kubecost. This tutorial is intended as the best-practice method for users whose environments meet the following assumptions:

1. Kubecost will run in a different account than the AWS Payer Account
1. The IAM permissions will utilize AWS [IAM Roles for Service Accounts (IRSA)](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) to avoid shared secrets
1. The configuration of Kubecost will be done using a *cloud-integration.json* file, and not via Kubecost UI (following infrastructure as code practices)

If this is not an accurate description of your environment, see our [AWS Cloud Integration](aws-cloud-integrations.md) doc for more options.

{% hint style="info" %}
Kubecost also supports [EKS Pod Identity](https://aws.amazon.com/about-aws/whats-new/2023/11/amazon-eks-pod-identity/) as an alternative to IRSA. To set up EKS Pod Identities, complete steps 1-4 of the below tutorial fully, then follow Step 5 until you are prompted to move to the [optional Step 6](aws-cloud-integration-using-irsa.md#step-6-optional-setting-up-eks-pod-identity) below.
{% endhint %}

## Overview of Kubecost CUR integration

This guide is a one-time setup per AWS payer account and is typically one per organization. It can be automated, but may not be worth the effort given that it will not be needed again.

<details>

<summary>Basic diagram when the below steps are complete:</summary>

![cur-diagram](/images/aws-cur/kubecost-cross-account-cur-diagram.png)

</details>

Kubecost supports multiple AWS payer accounts as well as multiple cloud providers from a single Kubecost primary cluster. For multiple payer accounts, create additional entries inside the array below.

Detail for multiple cloud provider setups is [here](/install-and-configure/install/cloud-integration/multi-cloud.md#aws).

## Configuration

### Step 1: Download configuration files

To begin, download the recommended configuration template files from our [poc-common-config repo](https://github.com/kubecost/poc-common-configurations/tree/main/aws). You will need the following files from this folder:

* _cloud-integration.json_
* _iam-payer-account-cur-athena-glue-s3-access.json_
* _iam-payer-account-trust-primary-account.json_
* _iam-access-cur-in-payer-account.json_

The bottom three files are found in [/aws/iam-policies/cur](https://github.com/kubecost/poc-common-configurations/tree/main/aws/iam-policies/cur).

Begin by opening *cloud_integration.json*, which should look like this:

```json
{
    "aws": [
        {
            "athenaBucketName": "s3://ATHENA_RESULTS_BUCKET_NAME",
            "athenaRegion": "ATHENA_REGION",
            "athenaDatabase": "ATHENA_DATABASE",
            "athenaTable": "ATHENA_TABLE",
            "athenaWorkgroup": "ATHENA_WORKGROUP",
            "projectID": "ATHENA_PROJECT_ID",
            "masterPayerARN": "PAYER_ACCOUNT_ROLE_ARN"
        }
    ]
}
```

Update `athenaWorkgroup` to `primary`, then save the file and close it. The remaining values will be obtained during this tutorial.

### Step 2: Create a CUR Export (and wait 24 hours)

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

AWS may take up to 24 hours to publish data. Wait until this is complete before continuing to the next step.

While you wait, update the following configuration files:

* Update your *cloud-integration.json* file by providing a `projectID` value, which will be the AWS payer account number where the CUR is located and where the Kubecost primary cluster is running.
* Update your *iam-payer-account-cur-athena-glue-s2-access.json* file by replacing all instances of `CUR_BUCKET_NAME` to the name of the bucket you created for CUR data.

### Step 3: Setting up Athena

As part of the CUR creation process, Amazon creates a CloudFormation template that is used to create the Athena integration. It is created in the CUR S3 bucket under `s3-path-prefix/cur-name` and typically has the filename *crawler-cfn.yml*. This .yml is your CloudFormation template. You will need it in order to complete the CUR Athena integration. You can read more about this [here](https://docs.aws.amazon.com/cur/latest/userguide/use-athena-cf.html).

![athena-output-bucket](/images/aws-cur/8-upload-cfn-template.png)

{% hint style="info" %}
Your S3 path prefix can be found by going to your AWS Cost and Usage Reports dashboard and selecting your bucket's report. In the Report details tab, you will find the S3 path prefix.
{% endhint %}

Once Athena is set up with the CUR, you will need to create a *new* S3 bucket for Athena query results. The bucket used for the CUR cannot be used for the Athena output.

1. Navigate to the [S3 Management Console](https://console.aws.amazon.com/s3/home?region=us-east-2).
2. Select _Create bucket._ The Create Bucket page opens.
3. Provide a name for your bucket. This is the value for `athenaBucketName` in your *cloud-integration.json* file. Use the same region used for the CUR bucket.
4. Select _Create bucket_ at the bottom of the page.
5. Navigate to the [Amazon Athena](https://console.aws.amazon.com/athena) dashboard.
6. Select _Settings_, then select _Manage._ The Manage settings window opens.
7. Set _Location of query result_ to the S3 bucket you just created, then select _Save._

Navigate to Athena in the AWS Console. Be sure the region matches the one used in the steps above. Update your *cloud-integration.json* file with the following values. Use the screenshots below for help.

![CUR-Config](/images/aws-cur/6-cur-config.png)

* `athenaBucketName`: the name of the Athena bucket your created in this step
* `athenaDatabase`: the value in the Database dropdown
* `athenaRegion`: the AWS region value where your Athena query is configured
* `athenaTable`: the partitioned value found in the Table list

{% hint style="info" %}
For Athena query results written to an S3 bucket only accessed by Kubecost, it is safe to expire or delete the objects after one day of retention.
{% endhint %}

### Step 4: Setting up payer account IAM permissions

**From the AWS payer account**

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

{% hint style="warning" %}
By arriving at this step, you should have been able to provide all values to your *cloud-integration.json* file. If any values are missing, reread the tutorial and follow any steps needed to obtain those values.
{% endhint %}

**From the AWS Account where the Kubecost primary cluster will run**

In *iam-access-cur-in-payer-account.json*, update `PAYER_ACCOUNT_11111111111` with the AWS account number of the payer account and create a policy allowing Kubecost to assumeRole in the payer account:

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

{% hint style="warning" %}
If you are using EKS Pod Identity, skip the rest of Step 5 and continue to [Step 6](aws-cloud-integration-using-irsa.md#step-6-optional-setting-up-eks-pod-identity).
{% endhint %}

Enable the OIDC-Provider:

```sh
eksctl utils associate-iam-oidc-provider \
    --cluster $CLUSTER_NAME --region $AWS_REGION \
    --approve
```

**Linking default Kubecost Service Account to an IAM Role**

Kubecost's default service account `kubecost-cost-analyzer` is automatically created in the `kubecost` namespace upon installation. This service account can be linked to an IAM Role via Annotation + IAM Trust Policy.

In the Helm values for your deployment, add the following section:

```yaml
serviceAccount:
  create: true
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::<accountNumber>:role/<kubecost-role>
```

Go to the IAM Role and attach the proper IAM trust policy. [Use the sample trust policy here](https://github.com/kubecost/poc-common-configurations/blob/main/aws/iam-policies/irsa-iam-role-trust-policy-for-default-service-account). Verify you have replaced the example OIDC URL with your cluster OIDC URL.

**Alternative method: Create a new dedicated service account for Kubecost using `eksctl`**

{% hint style="info" %}
This method creates a new service account via eksctl command line tools, instead of using the default service account. Eksctl automatically creates the trust policy and IAM Role that are linked to the new dedicated Kubernetes service account.
{% endhint %}

Replace `SUB_ACCOUNT_222222222` with the AWS account number where the primary Kubecost cluster will run.

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

Add the following section to your Helm values. This will tell Kubecost to use your newly created service account, instead of creating one.

```yaml
serviceAccount:
  create: false
  name: kubecost-serviceaccount
```

### Step 6 (optional): Setting up EKS Pod Identity

{% hint style="warning" %}
Your cluster must support [EKS Pod Identities](https://docs.aws.amazon.com/eks/latest/userguide/pod-id-agent-setup.html) to use the method below.
{% endhint %}

Create your pod identity association:

```sh
eksctl create podidentityassociation \
--cluster $CLUSTER_NAME --region $AWS_REGION \
--namespace kubecost \
--service-account-name kubecost-serviceaccount \
--role-name kubecost-serviceaccount \
--permission-policy-arns arn:aws:iam::SUB_ACCOUNT_222222222:policy/kubecost-access-cur-in-payer-account
```

Then update your *values.yaml* file:

```yaml
serviceAccount:
  create: true
    name: kubecost-serviceaccount
```

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

For help with troubleshooting, see the section in our original [AWS integration guide](/install-and-configure/install/cloud-integration/aws-cloud-integrations/aws-cloud-integrations.md#troubleshooting).
