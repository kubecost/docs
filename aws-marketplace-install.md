## Step 1. Create an IAM policy

[More info on how to create a new policy](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_managed-policies.html)

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

Access Helm install steps are available at [kubecost.com/install](kubecost.com/install). 

Supply the following parameters to your helm install command to attach your IAM role ([more info](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html)) via annotation set as .Values.awstore.annotations and deploy Kubecost with AWS Marketplace images. 

> Note that you need to supply your AWS account ID and IAM role name in the parameter below. 

```
--set awstore.annotations="eks.amazonaws.com/role-arn: arn:aws:iam::YOUR_AWS_ACCOUNT_ID:role/YOUR_IAM_ROLE_NAME" \
--set kubecostModel.image=117940112483.dkr.ecr.us-east-1.amazonaws.com/ef3b1962-d859-427a-b88c-7d91cc1aa233/cg-2124175658/gcr.io/kubecost1/cost-model \
--set kubecostFrontend.image=117940112483.dkr.ecr.us-east-1.amazonaws.com/8cc31d15-33f6-49fe-8d6c-e9c0366cefa0/cg-2124175658/gcr.io/kubecost1/frontend \
--set kubecost.image=117940112483.dkr.ecr.us-east-1.amazonaws.com/8cc31d15-33f6-49fe-8d6c-e9c0366cefa0/cg-2124175658/gcr.io/kubecost1/server \
--set kubecostChecks.enabled=false \
--set prometheus.alertmanager.enabled=false \
--set prometheus.nodeExporter.enabled=false \
--set imageVersion="1.57.0-latest" \
--set global.grafana.enabled=false \
```
