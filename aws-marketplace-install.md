AWS Marketplace Install
=======================

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
    --name awsstore-serviceaccount \
    --namespace kubecost \
    --cluster cluster_name \
    --attach-policy-arn IAM_policy_ARN \
    --approve \
    --override-existing-serviceaccounts
```

## Step 3. Deploy Kubecost with attached IAM role

Access Helm install steps available at [kubecost.com/install](http://kubecost.com/install). 

Supply the following parameters to your _helm install_ command.

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
--set awsstore.useAwsStore=true \
--set awsstore.imageNameAndVersion=117940112483.dkr.ecr.us-east-1.amazonaws.com/8cc31d15-33f6-49fe-8d6c-e9c0366cefa0/cg-142668492/gcr.io/kubecost1/awsstore:1.61.3-latest
```

To partipipate in our free Enterprise on-boarding program, contact us at team@kubecost.com to schedule these sessions!


Edit this doc on [Github](https://github.com/kubecost/docs/blob/main/aws-marketplace-install.md)

<!--- {"article":"4407596808087","section":"4402829036567","permissiongroup":"1500001277122"} --->