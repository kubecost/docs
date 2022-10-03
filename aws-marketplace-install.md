This document provides the steps for installing the Kubecost Enterprise product from the AWS marketplace. [More info on different tiers.](https://kubecost.com/pricing)

Please contact us at support@kubecost.com with any questions and we'd be happy to help!

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
--set kubecostProductConfigs.productKey.enabled=true \
--set kubecostProductConfigs.productKey.key="replace-with-product-key" \
--set prometheus.alertmanager.enabled=false \
--set prometheus.nodeExporter.enabled=false \
--set global.grafana.enabled=false \
--set global.grafana.proxy=false \
--set awsstore.useAwsStore=true \
--set awsstore.imageNameAndVersion=gcr.io/kubecost1/awsstore:latest
```

To participate in our free Enterprise onboarding program, contact us at team@kubecost.com to schedule these sessions!
