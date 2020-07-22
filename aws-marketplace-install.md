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

## Step 2. Deploy Kubecost with attached IAM role

Access Helm install steps available at [kubecost.com/install](kubecost.com/install). 

Create a file awsstore-values.yaml of the following format. Note that you need to supply your AWS account ID and an IAM role that supports service accounts in the annotations field below.  ([more info](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)) via annotation set as .Values.awstore.annotations and deploy Kubecost with AWS Marketplace images. 

```
awsstore:
  annotations:
    eks.amazonaws.com/role-arn: arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/YOUR_IAM_ROLE_NAME
  imageNameAndVersion: 117940112483.dkr.ecr.us-east-1.amazonaws.com/8cc31d15-33f6-49fe-8d6c-e9c0366cefa0/cg-2124175658/gcr.io/kubecost1/awsstore:1.57.0-latest
```

Supply the following parameters to your _helm install_ command 

```
--set kubecostModel.image=117940112483.dkr.ecr.us-east-1.amazonaws.com/8cc31d15-33f6-49fe-8d6c-e9c0366cefa0/cg-2124175658/gcr.io/kubecost1/cost-model \
--set kubecostFrontend.image=117940112483.dkr.ecr.us-east-1.amazonaws.com/8cc31d15-33f6-49fe-8d6c-e9c0366cefa0/cg-2124175658/gcr.io/kubecost1/frontend \
--set kubecost.image=117940112483.dkr.ecr.us-east-1.amazonaws.com/8cc31d15-33f6-49fe-8d6c-e9c0366cefa0/cg-2124175658/gcr.io/kubecost1/server \
--set kubecostChecks.enabled=false \
--set prometheus.alertmanager.enabled=false \
--set prometheus.nodeExporter.enabled=false \
--set imageVersion="1.57.0-latest" \
--set global.grafana.enabled=false \
--set global.grafana.proxy=false \
-f awsstore-values.yaml
```
