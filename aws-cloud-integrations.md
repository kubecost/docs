By default, Kubecost finds your prices by using the public AWS pricing API. To pull more accurate pricing information from AWS, two integrations with your account are required:

Cost and Usage Report integration via Athena: Kubecost integrates with the cost and usage report via Athena. From this, kubecost reads Reserved Instance pricing, Savings Plan pricing, exact network costs, Enterprise discounts, and tagged out-of-cluster-costs.

Spot Instance Feed Integration: Kubecost integrates with your spot data feed to pull spot data information, as the CUR is often many hours behind.


## Setting up the CUR:

[https://docs.aws.amazon.com/cur/latest/userguide/cur-ate-setup.html#create-athena-cur](https://docs.aws.amazon.com/cur/latest/userguide/cur-ate-setup.html#create-athena-cur)

Note the name of the bucket you create to place the CUR


## Setting up the Spot Data feed:

[https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-data-feeds.html](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-data-feeds.html)

Note the name of the bucket you create to place the spot data feed


## Setting up IAM permissions:
### Via Cloudformation: 
Kubecost offers a set of cloudformation templates to help set your IAM roles up. If you’re new to provisioning IAM roles, we suggest downloading our templates and using the cloudformation wizard to set these up: [https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-create-stack.html](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/cfn-console-create-stack.html) . 
Download template files from the URLs provided below and upload them as the stack template in the Creating a stack > Selecting a stack template step.

<details>
  <summary> My kubernetes clusters all run in the same account as the master payer account.</summary>
  

  * Download this file: [https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-masterpayer-account-permissions.yaml](https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-masterpayer-account-permissions.yaml)
  
  * Navigate to https://console.aws.amazon.com/cloudformation
  
  * Choose **Create New Stack** if you have never used AWS CloudFormation before. Otherwise, choose **Create Stack**.
  
  * Under **Prepare template**, choose **Template is ready**.
  
  * Under **Template source**, choose **Upload a template file**.
  
  * Select **Choose file**.
  
  * Choose the downloaded .yaml template, and then choose **Open**.
  
  * Choose **Next**.
  
  * For **Stack name**, enter a name for your template 
  
  * Set the following parameters:
        *   AthenaCURBucket: The bucket where the CUR is sent from the “Setting up the CUR” step
        *   SpotDataFeedBucketName: The bucket where the spot data feed is sent from the “Setting up the Spot Data feed” step
  
  * Choose **Next**.
  
  * Choose **Next**
  
  * At the bottom of the page, select **I acknowledge that AWS CloudFormation might create IAM resources.** 
  
  * Choose **Create Stack**
</details>

<details>
  <summary>Your kubernetes clusters run in different accounts from the masterpayer account</summary>
  
    *   On each sub account running kubecost
        *   Follow the same steps to create a cloudformation stack as above, but with the following as your yaml file instead: [https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-sub-account-permissions.yaml](https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-sub-account-permissions.yaml) , and with these parameters:
            *   MasterPayerAccountID: The account ID of the master payer account where the CUR has been created
            *   SpotDataFeedBucketName: The bucket where the spot data feed is sent from the “Setting up the Spot Data feed” step
    *   On the masterpayer account
        *   Follow the same steps to create a cloudformation stack as above, but with the following as your yaml file instead: [https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-masterpayer-account-permissions.yaml](https://raw.githubusercontent.com/kubecost/cloudformation/master/kubecost-masterpayer-account-permissions.yaml) , and with these parameters:
            *   AthenaCURBucket: The bucket where the CUR is set from the “Setting up the CUR” step
            *   KubecostClusterID: An account that kubecost is running on that requires access to the Athena CUR
</details>
*   Manually: Kubecost requires the following policies:
    *   Your kubernetes clusters run in the same account as the master payer account:

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


        Attach both of those policies to the same role or user. Use a user if you intend to integrate via servicekey, and a role if via IAM annotation (See more below under Via Pod Annotation by EKS)

    *   Your kubernetes clusters run in different accounts:
        *   On each sub account running kubecost:

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


        Attach both of those policies to the same role or user. Use a user if you intend to integrate via servicekey, and a role if via IAM annotation (See more below under Via Pod Annotation by EKS)



        *   On the masterpayer account:

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


			Attach this policy to a role, with the following trust relationship:

			{


               "Version": "2012-10-17",


               "Statement": [


                  {


                     "Effect": "Allow",


                     "Principal": {


                        "AWS": `'arn:aws:iam::${KubecostClusterID}:root'`


                     },


                     "Action": [


                        "sts:AssumeRole"


                     ]


                  }


               ]


            }


# Attaching IAM permissions to Kubecost:



*   Now that the policies have been created, we will need to attach those policies to Kubecost. We support the following methods:
*   Via Service Key
    *   Navigate to https://console.aws.amazon.com/iam Access Management > Users and select Security Credentials > Create Access Key. Note the **Access key ID **and **Secret access key**
    *   Via kubernetes secret
        *   Create a secret from helm values
            *   Set `.Values.kubecostProductConfigs.awsServiceKeyName `to<code> <strong>Access key ID</strong></code>
            *   Set <code>.Values.kubecostProductConfigs.awsServiceKeyPassword </code>to <strong>Secret access key</strong>
            *   Note that this will leave your secrets unencrypted in values.yaml. Use an existing secret as in the next step to avoid this.
        *   Use an existing secret 
            *    Create a json file named <em>service-key.json</em> of the following format

                {


                	"`aws_access_key_id": &lt;ACCESS_KEY_ID>,`


                ```
                	"aws_secret_access_key": <ACCESS_KEY_SECRET>
                ```



                }


                Create a secret from file in the namespace kubecost is deployed in:


                ```
                kubectl create secret generic <name> --from-file=service-key.json --namespace <kubecost>
                ```



                Add the &lt;name> of the secret above to serviceKeySecretName in [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/1fb9c5a3b341767570a62f14cca249a62671f6fc/cost-analyzer/values.yaml#L460) . Note also that [awsServiceKeyName](https://github.com/kubecost/cost-analyzer-helm-chart/blob/1fb9c5a3b341767570a62f14cca249a62671f6fc/cost-analyzer/values.yaml#L416) should be unset if adding the service key from values this way.

    *   Via kubecost frontend
        *   You can add the Access key ID and Secret access key on /settings.html  > External Cloud Cost Configuration (AWS) > Update  and setting Service key name to **Access key ID** and Service key secret to **Secret access key**
*   Via Pod Annotation on EKS
    *   Enable IAM roles.
        *   [https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html)
    *   you define the IAM role to associate with a service account in your cluster by adding the following annotation to the service account
        *   [https://docs.aws.amazon.com/eks/latest/userguide/specify-service-account-role.html](https://docs.aws.amazon.com/eks/latest/userguide/specify-service-account-role.html)
    *   This annotation can be added to the kubecost service account by setting `.Values.serviceAccount.annotations ` in the helm chart to `eks.amazonaws.com/role-arn: arn:aws:iam::&lt;AWS_ACCOUNT_ID>:role/&lt;IAM_ROLE_NAME>`


# Configuring the CUR in Kubecost:

	These values can either be set from the kubecost frontend or via .Values.kubecostProductConfigs in the helm chart. Note that if you set any kubecostProductConfigs from the helm chart, all changes via the frontend will be deleted on pod restart



*    athenaProjectID: "530337586277" # The AWS AccountID where the Athena CUR is. 
*    athenaBucketName: A result bucket you’ve created that kubecost has permission to access, of the form aws-athena-query-results-&lt;your-bucket-name>
*    athenaRegion: The aws region athena is running in
*    athenaDatabase: the name of the database created by the CUR setup
*    athenaTable: the name of the table created by the CUR setup
*   If you are using a multi-account setup, you will also need to set `.Values.kubecostProductConfigs.masterPayerARN `To the arn of the role in the masterpayer account. (something like arn:aws:iam::530337586275:role/KubecostRole),


## Relating out-of-cluster-costs to k8s resources via tags:



*   [Activating User-Defined Cost Allocation Tags - AWS Billing and Cost Management](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/activating-tags.html)
*   Use existing tags:


## Configuring the Spot Data Feed in Kubecost:

	These values can either be set from the kubecost frontend or via .Values.kubecostProductConfigs in the helm chart. Note that if you set any kubecostProductConfigs from the helm chart, all changes via the frontend will be deleted on pod restart

 awsSpotDataRegion: region of your spot data bucket

 awsSpotDataBucket: the configured bucket for the spot data feed

 awsSpotDataPrefix: optional configured prefix for your spot data feed bucket
