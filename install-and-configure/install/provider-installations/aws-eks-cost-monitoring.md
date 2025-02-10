# Amazon EKS Integration

[Amazon Elastic Kubernetes Services (Amazon EKS)](https://aws.amazon.com/eks/) is a managed container service to run and scale Kubernetes applications in the AWS cloud. In collaboration with Amazon EKS, Kubecost provides optimized bundle for Amazon EKS cluster cost visibility that enables customers to accurately track costs by namespace, cluster, pod or organizational concepts such as team or application. Customers can use their existing AWS support agreements to obtain support. Kubernetes platform administrators and finance leaders can use Kubecost to visualize a breakdown of their Amazon EKS cluster charges, allocate costs, and chargeback organizational units such as application teams.

In this article, you will learn more about how the Amazon EKS architecture interacts with Kubecost. You will also learn to deploy Kubecost on EKS using one of three different methods:

1. Deploy Kubecost on an Amazon EKS cluster using Amazon EKS add-on
2. Deploy Kubecost on an Amazon EKS cluster via Helm
3. Deploy Kubecost on an Amazon EKS Anywhere cluster using Helm

## Architecture overview

User experience diagram:

![User experience](/images/AWS-EKS-cost-monitoring-ux.png)

Amazon EKS cost monitoring with Kubecost architecture:

![User experience](/images/AWS-EKS-cost-monitoring-architecture.png)

Amazon EKS optimized diagram:

![EKS flowchart](/images/eks-flowchart.png)

## Deploying Kubecost on an Amazon EKS cluster using Amazon EKS add-on

### Prerequisites

* Subscribe to Kubecost on AWS Marketplace [here](https://aws.amazon.com/marketplace/pp/prodview-asiz4x22pm2n2?sr=0-1\&ref\_=beagle\&applicationId=AWSMPContessa).
* Install the following tools: [kubectl](https://kubernetes.io/docs/tasks/tools/), [AWS CLI](https://aws.amazon.com/cli/), and optionally [eksctl](https://eksctl.io/).
* You have access to an [Amazon EKS cluster](https://aws.amazon.com/eks/).

### Enable Kubecost add-on from AWS console

After subscribing to Kubecost on AWS Marketplace and following the on-screen instructions successfully, you are redirected to Amazon EKS console. To get started in the Amazon EKS console, go to your EKS clusters, and in the Add-ons tab, select _Get more add-ons_ to find Kubecost EKS add-ons in the cluster setting of your existing EKS clusters. You can use the search bar to find "Kubecost - Amazon EKS cost monitoring" and follow the on-screen instructions to enable Kubecost add-on for your Amazon EKS cluster. You can learn more about direct deployment to Amazon EKS clusters from this [AWS blog post](https://aws.amazon.com/blogs/aws/new-aws-marketplace-for-containers-now-supports-direct-deployment-to-amazon-eks-clusters/).

### Enable Kubecost add-on using AWS CLI

On your workspace, run the following command to enable the Kubecost add-on for your Amazon EKS cluster:

{% hint style="info" %}
You need to replace `$YOUR_CLUSTER_NAME` and `$AWS_REGION` accordingly with your actual Amazon EKS cluster name and AWS region.
{% endhint %}

{% tabs %}
{% tab title="Command" %}
{% code overflow="wrap" %}
```
aws eks create-addon --addon-name kubecost_kubecost --cluster-name $YOUR_CLUSTER_NAME --region $AWS_REGION
```
{% endcode %}
{% endtab %}

{% tab title="Example output" %}
{% code overflow="wrap" %}
```
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
{% endcode %}
{% endtab %}
{% endtabs %}

To monitor the installation status, you can run the following command:

{% tabs %}
{% tab title="Command" %}
{% code overflow="wrap" %}
```
aws eks describe-addon --addon-name kubecost_kubecost --cluster-name $YOUR_CLUSTER_NAME --region $AWS_REGION
```
{% endcode %}
{% endtab %}

{% tab title="Example output" %}
{% code overflow="wrap" %}
```
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
{% endcode %}
{% endtab %}
{% endtabs %}

The Kubecost add-on should be available in a few minutes. Run the following command to enable port-forwarding to expose the Kubecost dashboard:

```bash
kubectl port-forward --namespace kubecost deployment/cost-analyzer 9090
```

### Disable Kubecost add-on

To disable Kubecost add-on, you can run the following command:

{% code overflow="wrap" %}
```bash
aws eks delete-addon --addon-name kubecost_kubecost --cluster-name $YOUR_CLUSTER_NAME --region $AWS_REGION
```
{% endcode %}

## Deploying Kubecost on an Amazon EKS cluster using Helm

To get started, you can follow these steps to deploy Kubecost into your Amazon EKS cluster in a few minutes using Helm.

### Prerequisites

* Install the following tools: [Helm 3.9+](https://helm.sh/docs/intro/install/), [kubectl](https://kubernetes.io/docs/tasks/tools/), and optionally [eksctl](https://eksctl.io/) and [AWS CLI](https://aws.amazon.com/cli/).
* You have access to an [Amazon EKS cluster](https://aws.amazon.com/eks/).
* If your cluster is version 1.23 or later, you must have the [Amazon EBS CSI driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) installed on your cluster. You can also follow the instructions below to install the Amazon EBS CSI driver.
* If your cluster is version 1.30 or later, there is by default no longer a default StorageClass assigned. See the [EKS 1.30 release notes](https://docs.aws.amazon.com/eks/latest/userguide/kubernetes-versions-standard.html#kubernetes-1.30) for one of several alternatives.

#### Install AWS EBS CSI Driver

1. Run the following command to create an IAM service account with the policies needed to use the Amazon EBS CSI Driver.

{% hint style="info" %}
Remember to replace `$CLUSTER_NAME` with your actual cluster name.
{% endhint %}

{% code overflow="wrap" %}
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
{% endcode %}

2. Install the Amazon EBS CSI add-on for EKS using the AmazonEKS\_EBS\_CSI\_DriverRole by issuing the following command:

```
eksctl create addon --name aws-ebs-csi-driver --cluster $CLUSTER_NAME \
    --service-account-role-arn $SERVICE_ACCOUNT_ROLE_ARN --force
```

After completing these prerequisite steps, you're ready to begin EKS integration.

### Step 1: Install Kubecost on your Amazon EKS cluster

In your environment, run the following command from your terminal to install Kubecost on your existing Amazon EKS cluster:

{% code overflow="wrap" %}
```bash
helm upgrade -i kubecost \
oci://public.ecr.aws/kubecost/cost-analyzer --version <$VERSION> \
--namespace kubecost --create-namespace \
-f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/<$VERSION>/cost-analyzer/values-eks-cost-monitoring.yaml
```
{% endcode %}

To install Kubecost on Amazon EKS cluster on AWS Graviton2 (ARM-based processor), you can run following command:

{% code overflow="wrap" %}
```bash
helm upgrade -i kubecost \
oci://public.ecr.aws/kubecost/cost-analyzer --version <$VERSION> \
--namespace kubecost --create-namespace \
-f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/<$VERSION>/cost-analyzer/values-eks-cost-monitoring.yaml \
```
{% endcode %}

{% hint style="info" %}
On the Amazon EKS cluster with mixed processor architecture worker nodes (AMD64, ARM64), this parameter can be used to schedule Kubecost deployment on ARM-based worker nodes: `--set nodeSelector."beta\\.kubernetes\\.io/arch"=arm64`
{% endhint %}

{% hint style="info" %}
Remember to replace $VERSION with the actual version number. You can find all available versions via the Amazon ECR public gallery [here](https://gallery.ecr.aws/kubecost/cost-analyzer).
{% endhint %}

By default, the installation will include certain prerequisite software including Prometheus and kube-state-metrics. To customize your deployment, such as skipping these prerequisites if you already have them running in your cluster, you can configure any of the [available values](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v2.6/cost-analyzer/values-eks-cost-monitoring.yaml) to modify storage, network configuration, and more.

### Step 2: Generate Kubecost dashboard endpoint

Run the following command to enable port-forwarding to expose the Kubecost dashboard:

```bash
kubectl port-forward --namespace kubecost deployment/cost-analyzer 9090
```

### Step 3: Access Monitoring dashboards

You can now access Kubecost's UI by visiting `http://localhost:9090` in your local web browser. Here, you can monitor your Amazon EKS cluster cost and efficiency. Depending on your organization’s requirements and setup, you may have different options to expose Kubecost for internal access. There are a few examples that you can use for your references:

* See Kubecost's [Ingress Examples](/install-and-configure/install/ingress-examples.md) doc as a reference for using Nginx ingress controller with basic auth.
* You can also consider using AWS LoadBalancer controller to expose Kubecost and use Amazon Cognito for authentication, authorization, and user management. You can learn more via the AWS blog post [Authenticate Kubecost Users with Application Load Balancer and Amazon Cognito](https://aws.amazon.com/blogs/apn/authenticate-kubecost-users-with-application-load-balancer-and-amazon-cognito/).

## Deploying Kubecost on an EKS Anywhere cluster using Helm

{% hint style="warning" %}
Deploying Kubecost on EKS Anywhere via Helm is not the officially recommended method by Kubecost or AWS. The recommended method is via EKS add-on ([see above](#deploying-kubecost-on-an-amazon-eks-cluster-using-amazon-eks-add-on)).
{% endhint %}

[Amazon EKS Anywhere](https://aws.amazon.com/eks/eks-anywhere/) (EKS-A) is an alternate deployment of EKS which allows you to create and configure on-premises clusters, including on your own virtual machines. It is possible to deploy Kubecost on EKS-A clusters to monitor spend data.

{% hint style="info" %}
Deploying Kubecost on an EKS-A cluster should function similarly at the cluster level, such as when retrieving Allocations or Assets data. However, because on-prem servers wouldn't be visible in a CUR (as the billing source is managed outside AWS), certain features like the [Cloud Cost Explorer](/using-kubecost/navigating-the-kubecost-ui/cloud-costs-explorer/cloud-costs-explorer.md) will not be accessible.&#x20;
{% endhint %}

### Prerequisites:

* Install the following tools: [Helm 3.9+](https://helm.sh/docs/intro/install/), [kubectl](https://kubernetes.io/docs/tasks/tools/), and [eksctl](https://eksctl.io/) (only for EKS-A installation).
* You have installed the [EKS-A installer](https://anywhere.eks.amazonaws.com/docs/getting-started/install/) and have access to an [Amazon EKS-A cluster](https://aws.amazon.com/eks/).

### Step 1: Install Kubecost on your Amazon EKS cluster

In your environment, run the following command from your terminal to install Kubecost on your existing Amazon EKS cluster:

{% code overflow="wrap" %}
```bash
helm upgrade -i kubecost \
oci://public.ecr.aws/kubecost/cost-analyzer --version <$VERSION> \
--namespace kubecost --create-namespace \
-f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/<$VERSION>/cost-analyzer/values-eks-cost-monitoring.yaml
```
{% endcode %}

To install Kubecost on an EKS-A cluster on AWS Graviton2 (ARM-based processor), you can run following command:

{% code overflow="wrap" %}
```bash
helm upgrade -i kubecost \
oci://public.ecr.aws/kubecost/cost-analyzer --version <$VERSION> \
--namespace kubecost --create-namespace \
-f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/<$VERSION>/cost-analyzer/values-eks-cost-monitoring.yaml \
```
{% endcode %}

{% hint style="info" %}
On the Amazon EKS cluster with mixed processor architecture worker nodes (AMD64, ARM64), this parameter can be used to schedule Kubecost deployment on ARM-based worker nodes: `--set nodeSelector."beta\\.kubernetes\\.io/arch"=arm64`
{% endhint %}

{% hint style="info" %}
Remember to replace $VERSION with the actual version number. You can find all available versions via the Amazon ECR public gallery [here](https://gallery.ecr.aws/kubecost/cost-analyzer).
{% endhint %}

By default, the installation will include certain prerequisite software including Prometheus and kube-state-metrics. To customize your deployment, such as skipping these prerequisites if you already have them running in your cluster, you can configure any of the [available values](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v2.6/cost-analyzer/values-eks-cost-monitoring.yaml) to modify storage, network configuration, and more.

### Step 2: Generate Kubecost dashboard endpoint

Run the following command to enable port-forwarding to expose the Kubecost dashboard:

```bash
kubectl port-forward --namespace kubecost deployment/cost-analyzer 9090
```

### Step 3: Access Monitoring dashboards

You can now access Kubecost's UI by visiting `http://localhost:9090` in your local web browser. Here, you can monitor your Amazon EKS cluster cost and efficiency through the Allocations and Assets pages.

## Additional resources

Amazon EKS documentation:

* [Amazon EKS cost monitoring](https://docs.aws.amazon.com/eks/latest/userguide/cost-monitoring.html)
* [Amazon EKS add-on](https://docs.aws.amazon.com/eks/latest/userguide/eks-add-ons.html)
* [Amazon EKS Anywhere](https://aws.amazon.com/eks/eks-anywhere/)

AWS blog content:

* [AWS and Kubecost collaborate to deliver cost monitoring for EKS customers](https://aws.amazon.com/blogs/containers/aws-and-kubecost-collaborate-to-deliver-cost-monitoring-for-eks-customers/)
* [New – AWS Marketplace for Containers Now Supports Direct Deployment to Amazon EKS Clusters](https://aws.amazon.com/blogs/aws/new-aws-marketplace-for-containers-now-supports-direct-deployment-to-amazon-eks-clusters/)
