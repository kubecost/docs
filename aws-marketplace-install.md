1. Create an IAM role

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

2. Attach that IAM role (more info) via annotation set as .Values.awstore.annotations and deploy Kubecost with AWS Marketplace images. 
Access Helm install steps are available at kubecost.com/install. 
Supply the following parameters to your helm install command to complete this:
--set awsstore.annotations="eks.amazonaws.com/role-arn: arn:aws:iam::AWS_ACCOUNT_ID:role/IAM_ROLE_NAME"
--set kubecostModel.image=117940112483.dkr.ecr.us-east-1.amazonaws.com/ef3b1962-d859-427a-b88c-7d91cc1aa233/cg-2124175658/gcr.io/kubecost1/cost-model \
--set kubecostChecks.enabled=false \
--set prometheus.alertmanager.enabled=false \
--set prometheus.nodeExporter.enabled=false \
--set imageVersion="1.57.0-latest" \
--set global.grafana.enabled=false \
