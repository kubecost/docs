Kubecost pulls asset prices from the public AWS pricing API by default. To have accurate pricing information from AWS, you can integrate directly with your account. This integration will properly account for Enterprise Discount Programs, Reserved Instance usage, Savings Plans, spot usage and more. This resource describes the required steps for achieving this. 

# Cost and Usage Report Integration

## Step 1: Setting up the CUR
Follow these steps to set up a Cost and Usage Report. Be sure to enable Resource Ids and Athena integration when creating the CUR.
[https://docs.aws.amazon.com/cur/latest/userguide/cur-create.html](https://docs.aws.amazon.com/cur/latest/userguide/cur-create.html)

> Note the name of the bucket you create for CUR data. This will be used in following step. 

> If you believe you have the correct permissions, but cannot access the Billing and Cost Management page, have the owner of your organization's root account follow these instructions [https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/control-access-billing.html](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/control-access-billing.html#ControllingAccessWebsite-Activate)

AWS may take several hours to publish data, wait until this is complete before continuing to the next step

## Step 2: Setting up Athena

[https://docs.aws.amazon.com/cur/latest/userguide/cur-ate-setup.html#create-athena-cur](https://docs.aws.amazon.com/cur/latest/userguide/cur-ate-setup.html#create-athena-cur)

> Click the next **Next Topic** link for step-by-step instructions on setting up Athena through cloud formation

Once Athena is set up with the CUR, you will need to create a new S3 bucket for Athena query results.

 1. Navigate to https://console.aws.amazon.com/s3
 2. Select **Create Bucket**
 3. Be sure to use the same region as was used for the CUR bucket and pick a name that follows the format `aws-athena-query-results-*`
 4. Select **Create Bucket**
 5. Navigate to https://console.aws.amazon.com/athena
 6. Click **Settings**
 7. Set **Query result location** to the S3 bucket you just created

## Step 3: Setting up IAM permissions

### Add via Cloudformation: 
Kubecost offers a set of cloudformation templates to help set your IAM roles up. If you’re new to provisioning IAM roles, we suggest downloading our templates and using the cloudformation wizard to set these up: [https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-create-stack.html](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-create-stack.html) . 
Download template files from the URLs provided below and upload them as the stack template in the Creating a stack > Selecting a stack template step.

<details>
  <summary>My kubernetes clusters all run in the same account as the master payer account.</summary>
  

  * Download this file: [https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-single-account-permissions.yaml](https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-single-account-permissions.yaml)
  
  * Navigate to https://console.aws.amazon.com/cloudformation
  
  * Click **Create New Stack** if you have never used AWS CloudFormation before. Otherwise, click **Create Stack**. and select **With new resource (standard)**
  
  * Under **Prepare template**, choose **Template is ready**.
  
  * Under **Template source**, choose **Upload a template file**.
  
  * Select **Choose file**.
  
  * Choose the downloaded .yaml template, and then choose **Open**.
  
  * Choose **Next**.
  
  * For **Stack name**, enter a name for your template 
  
  * Set the following parameters:
  	*   AthenaCURBucket: The bucket where the CUR is sent from the “Setting up the CUR” step
	*   SpotDataFeedBucketName: Optional. The bucket where the spot data feed is sent from the “Setting up the Spot Data feed” step (see below)
  
  * Choose **Next**.
  
  * Choose **Next**
  
  * At the bottom of the page, select **I acknowledge that AWS CloudFormation might create IAM resources.** 
  
  * Choose **Create Stack**
</details>

<details>
  <summary>My kubernetes clusters run in different accounts from the master payer account</summary>
  
  * On each sub account running kubecost
	* Download this file: [https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-sub-account-permissions.yaml](https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-sub-account-permissions.yaml)
  	* Navigate to https://console.aws.amazon.com/cloudformation
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
  	*   Follow the same steps to create a cloudformation stack as above, but with the following as your yaml file instead: [https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-masterpayer-account-permissions.yaml](https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-masterpayer-account-permissions.yaml) , and with these parameters:
		*   AthenaCURBucket: The bucket where the CUR is set from the “Setting up the CUR” step
		*   KubecostClusterID: An account that kubecost is running on that requires access to the Athena CUR
</details>

### Add manually
<details>
	<summary>My Kubernetes clusters run in the same account as the master payer account</summary>

Attach both of the following policies to the same role or user. Use a user if you intend to integrate via servicekey, and a role if via IAM annotation (See more below under Via Pod Annotation by EKS). The SpotDataAccess policy statment is optional if the spot data feed is configured (see “Setting up the Spot Data feed” step below)

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

On each sub account running kubecost, attach both of the following policies to the same role or user. Use a user if you intend to integrate via servicekey, and a role if via IAM annotation (See more below under Via Pod Annotation by EKS). The SpotDataAccess policy statment is optional if the spot data feed is configured (see “Setting up the Spot Data feed” step below)


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
You will then need to add the following trust statement to the role the policy is attached to (replace `${KubecostClusterID}` variable):
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


## Step 4: Attaching IAM permissions to Kubecost
Now that the policies have been created, we will need to attach those policies to Kubecost. We support the following methods:

<details>
	<summary>Attach via Service Key And Kubernetes Secret</summary>

* Navigate to https://console.aws.amazon.com/iam Access Management > Users . Find the Kubecost User and select Security Credentials > Create Access Key. Note the Access key ID and Secret access key. You'll use it to either Create a secret from helm values or Create and use an existing secret.

	<details>
		<summary>Create a secret from helm values</summary>

	* Set `.Values.kubecostProductConfigs.awsServiceKeyName `to <code> <strong>Access key ID</strong></code>
	*   Set <code>.Values.kubecostProductConfigs.awsServiceKeyPassword </code>to <strong>Secret access key</strong>
	*   Note that this will leave your secrets unencrypted in values.yaml. Use an existing secret as in the next step to avoid this.

	</details>

	<details>
		<summary> Create and use an existing secret </summary>

	If you commit your helm values to source control, you may want to create a secret in a different way and import that secret to kubecost.
	* Create a json file named <em>service-key.json</em> of the following format
    ```
    {
      "aws_access_key_id": "<ACCESS_KEY_ID>",
      "aws_secret_access_key": "<ACCESS_KEY_SECRET>"
    }
	```
	* Create a secret from file in the namespace kubecost is deployed in:
        	```
                kubectl create secret generic <name> --from-file=service-key.json --namespace <kubecost>
        	```
	* Set .Values.kubecostProductConfigs.serviceKeySecretName to the name of this secet. Note also that .Values.kubecostProductConfigs.awsServiceKeyName and .Values.kubecostProductConfigs.awsServiceKeyPassword should be unset if adding the service key from values this way.

	</details>

</details>

<details>
	<summary>Attach via Service Key on Kubecost frontend</summary>
	
* Navigate to https://console.aws.amazon.com/iam Access Management > Users . Find the Kubecost User and select Security Credentials > Create Access Key. Note the Access key ID and Secret access key.
*   You can add the Access key ID and Secret access key on /settings.html  > External Cloud Cost Configuration (AWS) > Update  and setting Service key name to **Access key ID** and Service key secret to **Secret access key**

</details>

<details>
	<summary>Attach via Pod Annotation on EKS</summary>

*   First, create an OIDC provider for your cluster with these [steps](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html)
*   Next, create a Role with these [steps](https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html). 
	*   When asked to attach policies, you'll want to attach the policies created above in Step 2
	*   When asked for "namespace" and "serviceaccountname" use the namespace kubecost is installed in and the name of the serviceaccount attached to the cost-analyzer pod. You can find that name by running `kubectl get pods kubecost-cost-analyzer-69689769b8-lf6nq -n <kubecost-namespace> -o yaml | grep serviceAccount`
* Then, you need to add an annotation to that service account as described in these [docs](https://docs.aws.amazon.com/eks/latest/userguide/specify-service-account-role.html). This annotation can be added to the kubecost service account by setting `.Values.serviceAccount.annotations ` in the helm chart to `eks.amazonaws.com/role-arn: arn:aws:iam::<AWS_ACCOUNT_ID>:role/<IAM_ROLE_NAME>`

</details>

## Step 5: Provide CUR config values to Kubecost

These values can either be set from the kubecost frontend or via .Values.kubecostProductConfigs in the helm chart. Note that if you set any kubecostProductConfigs from the helm chart, all changes via the frontend will be overridden on pod restart.

* `athenaProjectID` e.g. "530337586277" # The AWS AccountID where the Athena CUR is. 
* `athenaBucketName` An S3 bucket to store Athena query results that you’ve created that kubecost has permission to access
    * The name of the bucket should match `s3://aws-athena-query-results-*`, so the IAM roles defined above will automatically allow access to it
    * The bucket can have a Canned ACL of `Private` or other permissions as you see fit.
* `athenaRegion` The aws region athena is running in
* `athenaDatabase` the name of the database created by the CUR setup
    * The athena database name is available as the value (physical id) of `AWSCURDatabase` in the CloudFormation stack created above (in [Step 2: Setting up the CUR](#Step-2:-Setting-up-Athena))
* `athenaTable` the name of the table created by the CUR setup
  * The table name is typically the database name with the leading `athenacurcfn_` removed (but is not available as a CloudFormation stack resource)

> Make sure using only underscore as an delimiter if needed for tables and views, using dash will not work even though you might be able to create it see [docs](https://docs.aws.amazon.com/athena/latest/ug/tables-databases-columns-names.html).

* If you are using a multi-account setup, you will also need to set `.Values.kubecostProductConfigs.masterPayerARN `To the arn of the role in the masterpayer account, e.g. `arn:aws:iam::530337586275:role/KubecostRole`.

## Troubleshooting

Once you've integrated with the CUR, you can visit /diagnostics.html in kubecost to determine if kubecost has been successfully integrated with your CUR. If any problems are detected, you will see a yellow warning sign under the cloud provider permissions status header: 
<img width="1792" alt="Screen Shot 2020-12-06 at 9 37 40 PM" src="https://user-images.githubusercontent.com/453512/101316930-587bb080-3812-11eb-8bbc-694a894314d8.png">

You can check pod logs for authentication errors by running 
`kubectl get pods -n <namespace>`
`kubectl logs <kubecost-pod-name> -n <namespace> -c cost-model`

If you do not see any authentication errors, log in to your AWS console and visit the Athena dashboard. You should be able to find the CUR. Ensure that the databse with the CUR matches the athenaTable entered in step 4-- it likely has a prefix with athenacurfn_ :
<img width="1792" alt="Screen Shot 2020-12-06 at 9 43 31 PM" src="https://user-images.githubusercontent.com/453512/101319459-e6f23100-3816-11eb-8d96-1ab977cb50bd.png">

You can also check query history to see if any queries are failing:
<img width="1792" alt="Screen Shot 2020-12-06 at 9 43 50 PM" src="https://user-images.githubusercontent.com/453512/101319633-24ef5500-3817-11eb-9f87-55a903428936.png">



## Want to relate out-of-cluster costs to k8s resources via tags?

*   [Activating User-Defined Cost Allocation Tags - AWS Billing and Cost Management](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/activating-tags.html)
*   See [Step 2 here](http://docs.kubecost.com/aws-out-of-cluster.html) for more information on how to supply tags or use existing tags.

# Spot Data feed integration

Kubecost will reconcile your spot prices with CUR billing reports as they become available (usually 1-2 days), but pricing data can be pulled hourly by integrating directly with the AWS spot feed. To enable, follow these steps:

[https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-data-feeds.html](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-data-feeds.html)

> Note the name of the bucket you create for spot data. This will be used in the following step.

## Configuring the Spot Data Feed in Kubecost

These values can either be set from the kubecost frontend or via .Values.kubecostProductConfigs in the helm chart. Note that if you set any kubecostProductConfigs from the helm chart, all changes via the frontend will be deleted on pod restart

 `awsSpotDataRegion` region of your spot data bucket

 `awsSpotDataBucket` the configured bucket for the spot data feed

 `awsSpotDataPrefix` optional configured prefix for your spot data feed bucket
 
 `spotLabel` optional kubernetes node label name designating whether a node is a spot node. Used to provide pricing estimates until exact spot data becomes available from the CUR
 
 `spotLabelValue` optional kubernetes node label value designating a spot node. Used to provide pricing estimates until exact spot data becomes available from the CUR. For example, if your spot nodes carry a label `lifecycle:spot`, then the spotLabel would be "lifecycle" and the spotLabelValue would be "spot"
