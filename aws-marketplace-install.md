AWS Marketplace Install
=======================

This document provides the steps for installing the Kubecost product from the AWS marketplace. [More info on different tiers.](https://kubecost.com/pricing)

Please contact us at support@kubecost.com with any questions and we'd be happy to help!

## Step 1. Create an IAM policy

To deploy Kubecost from AWS Marketplace, you need to assign an IAM policy with approriate IAM permission to a Kubernetes (K8s) service account before starting the deployment. You can either use AWS managed policy `arn:aws:iam::aws:policy/AWSMarketplaceMeteringRegisterUsage` or creating your own IAM policy. You can learn [more info on how to create a new policy](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial_managed-policies.html#step1-create-policy)

Example IAM policy:

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

## Step 2. Create an IAM role for service account (IRSA).
We recommend doing this via [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html). The command below helps to automate these manual steps:
- Create an IAM role with AWS managed IAM policy.
- Create a K8s service account name `awsstore-serviceaccount` in your Amazon EKS cluster.
- Set up trust relationship between the created IAM role with awsstore-serviceaccount.
- Modify `awsstore-serviceaccount` annotation to associate it with the created IAM role 

Please remember to replace `CLUSTER_NAME` with your actual Amazon EKS cluster name.

```
eksctl create iamserviceaccount \
    --name awsstore-serviceaccount \
    --namespace kubecost \
    --cluster CLUSTER_NAME \
    --attach-policy-arn arn:aws:iam::aws:policy/AWSMarketplaceMeteringRegisterUsage \
    --approve \
    --override-existing-serviceaccounts
```
More details and how to set up the appropriate trust relationships is available [here](https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html).

> Note: Your Amazon EKS cluster needs to have IAM OIDC provider enabled to set up IRSA. You can learn more on how to enable IAM OIDC provider with this [AWS documentation](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) 
## Step 3. Deploy Kubecost with attached IAM role

- Define which available version you would like to install using this following command (you can check available version title from the AWS Marketplace product, e.g: prod-1.95.0):

`export IMAGETAG=<VERSION-TITLE>`

- Deploy Kubecost with `Helm` using the following command:

```
helm upgrade -i kubecost kubecost/cost-analyzer \
    --namespace kubecost --create-namespace \
    --set prometheus.nodeExporter.enabled=false \
    --set global.grafana.enabled=false \
    --set global.grafana.proxy=false \
    --set awsstore.useAwsStore=true \
    --set awsstore.imageNameAndVersion=709825985650.dkr.ecr.us-east-1.amazonaws.com/stackwatch/awsstore:${IMAGETAG} \
    --set imageVersion=${IMAGETAG} \
    --set kubecostFrontend.image=709825985650.dkr.ecr.us-east-1.amazonaws.com/stackwatch/frontend \
    --set kubecostModel.image=709825985650.dkr.ecr.us-east-1.amazonaws.com/stackwatch/cost-model \
    --set prometheus.server.image.repository=709825985650.dkr.ecr.us-east-1.amazonaws.com/stackwatch/contract/quay.io/prometheus  \
    --set prometheus.server.image.tag=v2.35.0

```
- You can run these following commands to enable port-forwarding and access Kubecost dashboard at `http://localhost:9090`

`kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090`

You can now start monitoring your Amazon EKS cluster cost with Kubecost. For advanced setup or if you have any questions, you can contact us on [Slack](https://join.slack.com/t/kubecost/shared_invite/enQtNTA2MjQ1NDUyODE5LWFjYzIzNWE4MDkzMmUyZGU4NjkwMzMyMjIyM2E0NGNmYjExZjBiNjk1YzY5ZDI0ZTNhZDg4NjlkMGRkYzFlZTU) or email at team@kubecost.com 

To participate in our free Enterprise onboarding program, contact us at support@kubecost.com to schedule these sessions!


Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/aws-marketplace-install.md)

<!--- {"article":"4407596808087","section":"4402829036567","permissiongroup":"1500001277122"} --->
