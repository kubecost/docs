This document provides the steps for installing the Kubecost Enterprise product from the AWS marketplace. [More info on different tiers.](https://kubecost.com/pricing)

Please contact us at team@kubecost.com with any questions and we'd be happy to help!

## Step 1. Create an IAM policy

[More info on how to create a new policy](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_managed-policies.html#step1-create-policy)

```
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "aws-marketplace:RegisterUsage"
                ],
                "Effect": "Allow",
                "Resource": "*"
        }
    ]
}
```

## Step 2. Create an IAM role with the appropriate trust relationships
We recommend doing this via eksctl. More detail and how to set up the appropriate trust relationships is available [here](https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html).
```
eksctl create iamserviceaccount \
    --name service_account_name \
    --namespace service_account_namespace \
    --cluster cluster_name \
    --attach-policy-arn IAM_policy_ARN \
    --approve \
    --override-existing-serviceaccounts
```

## Step 3. Deploy Kubecost with attached IAM role

Access Helm install steps available at [kubecost.com/install](http://kubecost.com/install). 

Create a file awsstore-values.yaml of the following format. Note that you need to supply your AWS account ID and an IAM role that supports service accounts in the annotations field below.  ([more info](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)) via annotation set as .Values.awstore.annotations and deploy Kubecost with AWS Marketplace images. 

```
awsstore:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/YOUR_IAM_ROLE_NAME
  imageNameAndVersion: 117940112483.dkr.ecr.us-east-1.amazonaws.com/8cc31d15-33f6-49fe-8d6c-e9c0366cefa0/cg-142668492/gcr.io/kubecost1/awsstore:1.61.3-latest
```

Supply the following parameters to your _helm install_ command 

```
--set kubecostModel.image=117940112483.dkr.ecr.us-east-1.amazonaws.com/8cc31d15-33f6-49fe-8d6c-e9c0366cefa0/cg-142668492/gcr.io/kubecost1/cost-model \
--set kubecostFrontend.image=117940112483.dkr.ecr.us-east-1.amazonaws.com/8cc31d15-33f6-49fe-8d6c-e9c0366cefa0/cg-142668492/gcr.io/kubecost1/frontend \
--set kubecost.image=117940112483.dkr.ecr.us-east-1.amazonaws.com/8cc31d15-33f6-49fe-8d6c-e9c0366cefa0/cg-142668492/gcr.io/kubecost1/server \
--set kubecostChecks.enabled=false \
--set prometheus.alertmanager.enabled=false \
--set prometheus.nodeExporter.enabled=false \
--set imageVersion="1.61.3-latest" \
--set global.grafana.enabled=false \
--set global.grafana.proxy=false \
-f awsstore-values.yaml
```

To partipipate in our free Enterprise on-boarding program, contact us at team@kubecost.com to schedule these sessions!
