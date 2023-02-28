Amazon EKS Integration
==================

[Amazon Elastic Kubernetes Services (Amazon EKS)](https://aws.amazon.com/eks/) is a managed container service to run and scale Kubernetes applications in the AWS cloud. In collaboration with Amazon EKS, Kubecost provides optimized bundle for Amazon EKS cluster cost visibility that enables customers to accurately track costs by namespace, cluster, pod or organizational concepts such as team or application. Customers can use their existing AWS support agreements to obtain support. Kubernetes platform administrators and finance leaders can use Kubecost to visualize a breakdown of their Amazon EKS cluster charges, allocate costs, and chargeback organizational units such as application teams.

## Architecture overview:

User experience diagram:

![User experience](https://raw.githubusercontent.com/kubecost/docs/main/images/AWS-EKS-cost-monitoring-ux.png)

Amazon EKS cost monitoring with Kubecost architecture:

![User experience](https://raw.githubusercontent.com/kubecost/docs/main/images/AWS-EKS-cost-monitoring-architecture.png)

## Deploying Kubecost on Amazon EKS cluster using Helm
To get started, you can follow these steps to deploy Kubecost into your Amazon EKS cluster in a few minutes using Helm.

### Prerequisites:
- Install the following tools: [Helm 3.9+](https://helm.sh/docs/intro/install/), [kubectl](https://kubernetes.io/docs/tasks/tools/), and optionally [eksctl](https://eksctl.io/) and [AWS CLI](https://aws.amazon.com/cli/).
- You have access to an [Amazon EKS cluster](https://aws.amazon.com/eks/).
- If your cluster is version 1.23 or later, you must have the [Amazon EBS CSI driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) installed on your cluster. You can also follow these instructions to install Amazon EBS CSI driver:

1. Run the following command to create an IAM service account with the policies needed to use the Amazon EBS CSI Driver.
> **Note**: Remember to replace `$CLUSTER_NAME` by your actual cluster name

```bash
eksctl create iamserviceaccount   \
    --name ebs-csi-controller-sa   \
    --namespace kube-system   \
    --cluster $CLUSTER_NAME   \
    --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy  \
    --approve \
    --role-only \
    --role-name AmazonEKS_EBS_CSI_DriverRole
export SERVICE_ACCOUNT_ROLE_ARN=$(aws iam get-role --role-name AmazonEKS_EBS_CSI_DriverRole --output json | jq -r '.Role.Arn')
```

2. Install the Amazon EBS CSI add-on for EKS using the AmazonEKS_EBS_CSI_DriverRole by issuing the following command:
```
eksctl create addon --name aws-ebs-csi-driver --cluster $CLUSTER_NAME \
    --service-account-role-arn $SERVICE_ACCOUNT_ROLE_ARN --force
```

After completing these prerequisite steps, you're ready to begin EKS integration.

### Step 1: Install Kubecost on your Amazon EKS cluster

In your environment, run the following command from your terminal to install Kubecost on your existing Amazon EKS cluster:

```bash
helm upgrade -i kubecost \
oci://public.ecr.aws/kubecost/cost-analyzer --version <$VERSION> \
--namespace kubecost --create-namespace \
-f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-eks-cost-monitoring.yaml
```

To install Kubecost on Amazon EKS cluster on AWS Graviton2 (ARM-based processor), you can run following command:

```bash
helm upgrade -i kubecost \
oci://public.ecr.aws/kubecost/cost-analyzer --version <$VERSION> \
--namespace kubecost --create-namespace \
-f https://raw.githubusercontent.com/linhlam-kc/cost-analyzer-helm-chart/aws-eks/cost-analyzer/values-eks-cost-monitoring.yaml \
--set prometheus.configmapReload.prometheus.image.repository=jimmidyson/configmap-reload \
--set prometheus.configmapReload.prometheus.image.tag=v0.7.1
```

> **Note**: On the Amazon EKS cluster with mixed processor architecture worker nodes (AMD64, ARM64), this parameter can be used to schedule Kubecost deployment on ARM-based worker nodes: `--set nodeSelector."beta\\.kubernetes\\.io/arch"=arm64`

> **Note**: Remember to replace $VERSION with actual version number. You can find all available versions at https://gallery.ecr.aws/kubecost/cost-analyzer

By default, the installation will include certain prerequisite software including Prometheus and kube-state-metrics. To customize your deployment, for example skipping these prerequisites if you already have them running in your cluster, you can configure any of the [available values](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values-eks-cost-monitoring.yaml) to modify storage, network configuration, and more. 

### Step 2: Generate Kubecost dashboard endpoint

Run the following command to enable port-forwarding to expose the Kubecost dashboard:

```bash
kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090
```

### Step 3: Access cost monitoring dashboard

On your web browser, navigate to http://localhost:9090 to access the dashboard. 

You can now start monitoring your Amazon EKS cluster cost and efficiency. Depending on your organization’s requirements and set up, you may have different options to expose Kubecost for internal access. There are few examples that you can use for your references:

- You can check Kubecost documentation for [Ingress Examples](/ingress-examples.md) as a reference for using Nginx ingress controller with basic auth.
- You can also consider using AWS LoadBalancer controller to expose Kubecost and use Amazon Cognito for authentication, authorization and user management. You can learn more at [“How to use Application Load Balancer and Amazon Cognito to authenticate users for your Kubernetes web apps”](https://aws.amazon.com/blogs/containers/how-to-use-application-load-balancer-and-amazon-cognito-to-authenticate-users-for-your-kubernetes-web-apps/) AWS blog post.

## Deploying Kubecost on Amazon EKS cluster using Amazon EKS add-on

### Prerequisites:
- Subscribe to Kubecost on AWS Marketplace at: https://aws.amazon.com/marketplace/pp/prodview-jatxqd2ccqvgc
- Install the following tools: [kubectl](https://kubernetes.io/docs/tasks/tools/), [AWS CLI](https://aws.amazon.com/cli/), and optionally [eksctl](https://eksctl.io/)
- You have access to an [Amazon EKS cluster](https://aws.amazon.com/eks/)
### Discover and enable Kubecost add-on from AWS console

After subscribing to Kubecost on AWS Marketplace and following the on-screen instructions successfully, you are redirected to Amazon EKS console. To get started in the Amazon EKS console, go to your EKS clusters, and in the Add-ons tab, select *Get more add-ons* to find Kubecost EKS add-ons in the cluster setting of your existing EKS clusters. You can use the search bar to find "Kubecost - Amazon EKS cost monitoring" and following the on-screen instructions to enable Kubecost add-on for your Amazon EKS cluster. You can learn more about direct deployment to Amazon EKS clusters from this [AWS blog post](https://aws.amazon.com/blogs/aws/new-aws-marketplace-for-containers-now-supports-direct-deployment-to-amazon-eks-clusters/).

### Enable Kubecost add-on using AWS CLI

On your workspace, run the following command to enable Kubecost add-on for your Amazon EKS cluster:

> **Note**: You need to replace $YOUR_CLUSTER_NAME, $AWS_REGION accordingly by your actual Amazon EKS cluster name and AWS region.

```bash
aws eks create-addon --addon-name kubecost_kubecost --cluster-name $YOUR_CLUSTER_NAME --region $AWS_REGION
```

Example output:

```bash
{
    "addon": {
        "addonName": "kubecost_kubecost",
        "clusterName": "$YOUR_CLUSTER_NAME",
        "status": "CREATING",
        "addonVersion": "v1.97.0-eksbuild.1",
        "health": {
            "issues": []
        },
        "addonArn": "arn:aws:eks:$AWS_REGION:xxxxxxxxxxxx:addon/$YOUR_CLUSTER_NAME/kubecost_kubecost/90c23198-cdd3-b295-c410-xxxxxxxxxxxx",
        "createdAt": "2022-12-01T12:18:26.497000-08:00",
        "modifiedAt": "2022-12-01T12:50:52.222000-08:00",
        "tags": {}
    }
}
```
To monitor the installation status, you can run the following command:

```bash
aws eks describe-addon --addon-name kubecost_kubecost --cluster-name $YOUR_CLUSTER_NAME --region $AWS_REGION
```

Example output:

```bash
{
    "addon": {
        "addonName": "kubecost_kubecost",
        "clusterName": "$YOUR_CLUSTER_NAME",
        "status": "ACTIVE",
        "addonVersion": "v1.97.0-eksbuild.1",
        "health": {
            "issues": []
        },
        "addonArn": "arn:aws:eks:$AWS_REGION:xxxxxxxxxxxx:addon/$YOUR_CLUSTER_NAME/kubecost_kubecost/90c23198-cdd3-b295-c410-xxxxxxxxxxxx",
        "createdAt": "2022-12-01T12:18:26.497000-08:00",
        "modifiedAt": "2022-11-10T12:53:21.140000-08:00",
        "tags": {}
    }
}
```

The Kubecost add-on should be available in few minutes. Run the following command to enable port-forwarding to expose the Kubecost dashboard:

```bash
kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090
```

### Disable Kubecost add-on

To disable Kubecost add-on, you can run the following command:

```bash
aws eks delete-addon --addon-name kubecost_kubecost --cluster-name $YOUR_CLUSTER_NAME --region $AWS_REGION
```
## Additional resources:

- [Amazon EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/cost-monitoring.html)
- [Amazon blog post](https://aws.amazon.com/blogs/containers/aws-and-kubecost-collaborate-to-deliver-cost-monitoring-for-eks-customers/)
- AWS Blog: [New – AWS Marketplace for Containers Now Supports Direct Deployment to Amazon EKS Clusters](https://aws.amazon.com/blogs/aws/new-aws-marketplace-for-containers-now-supports-direct-deployment-to-amazon-eks-clusters/)
- [Learn more about Amazon EKS add-on](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html)
- [Learn more about how to manage Amazon EKS add-on](https://docs.aws.amazon.com/eks/latest/userguide/managing-add-ons.html)
