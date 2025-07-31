# AWS Marketplace Install

This document provides the steps for installing the Kubecost product from the AWS marketplace. [More info pricing of different Kubecost versions](https://www.kubecost.com/pricing/).

## Step 1: Create an IAM policy

To deploy Kubecost from AWS Marketplace, you need to assign an IAM policy with appropriate IAM permission to a Kubernetes service account before starting the deployment. You can either use AWS managed policy `arn:aws:iam::aws:policy/AWSMarketplaceMeteringRegisterUsage` or create your own IAM policy. You can learn more with AWS' [Create and attach your first customer managed policy](https://docs.aws.amazon.com/IAM/latest/UserGuide/tutorial\_managed-policies.html#step1-create-policy)tutorial.

Here's an example IAM policy:

```json
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

## Step 2: Create an IAM role for service account (IRSA)

We recommend doing this via [eksctl](https://docs.aws.amazon.com/eks/latest/userguide/eksctl.html). The command below helps to automate these manual steps:

* Create an IAM role with AWS-managed IAM policy.
* Create a K8s service account name `awsstore-serviceaccount` in your Amazon EKS cluster.
* Set up a trust relationship between the created IAM role with awsstore-serviceaccount.
* Modify `awsstore-serviceaccount` annotation to associate it with the created IAM role

Remember to replace `CLUSTER_NAME` with your actual Amazon EKS cluster name.

```bash
eksctl create iamserviceaccount \
  --name awsstore-serviceaccount \
  --namespace kubecost \
  --cluster CLUSTER_NAME \
  --attach-policy-arn arn:aws:iam::aws:policy/AWSMarketplaceMeteringRegisterUsage \
  --approve \
  --override-existing-serviceaccounts
```

More details and how to set up the appropriate trust relationships is available [here](https://docs.aws.amazon.com/eks/latest/userguide/create-service-account-iam-policy-and-role.html).

{% hint style="info" %}
Your Amazon EKS cluster needs to have IAM OIDC provider enabled to set up IRSA. Learn more with AWS' [Creating an IAM OIDC provider for your cluster](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) doc.
{% endhint %}

## Step 3: Deploy Kubecost with attached IAM role

Define which available version you would like to install using this following command You can check available version titles from the AWS Marketplace product, e.g: prod-1.95.0:

`export IMAGETAG=<VERSION-TITLE>`

Deploy Kubecost with Helm using the following command:

```bash
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

Run this command to enable port-forwarding and access the Kubecost UI:

```bash
kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090
```

You can now start monitoring your Amazon EKS cluster cost with Kubecost by visiting `http://localhost:9090`.
