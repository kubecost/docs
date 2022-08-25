Amazon EKS integration
==================

## Overview:

[Amazon Elastic Kubernetes Services (Amazon EKS)](https://aws.amazon.com/eks/) is a managed container service to run and scale Kubernetes applications in the AWS cloud. In the collaboration with Amazon EKS, Kubecost provides optimized bundle for Amazon EKS cluster cost visibility that enable customer to accurately track costs by namespace, cluster, pod or organizational concepts such as team or application. Customers can use their existing AWS support agreements to obtain support. Kubernetes platform administrators and finance leaders can use Kubecost to visualize a breakdown of their Amazon EKS cluster charges, allocate costs, and chargeback organizational units such as application teams.

## Architecture overview:

### User experience:

![User experience](https://raw.githubusercontent.com/kubecost/docs/main/images/AWS-EKS-cost-monitoring-ux.png)

### Amazon EKS cost monitoring with Kubecost architecture:

![User experience](https://raw.githubusercontent.com/kubecost/docs/main/images/AWS-EKS-cost-monitoring-architecture.png)

## Deploying Kubecost on EKS
To get started, you can follow these steps to deploy Kubecost into your Amazon EKS cluster in a few minutes using Helm.

### Prerequisites:
- Install the following tools: [Helm 3.9+](https://helm.sh/docs/intro/install/), [kubectl](https://kubernetes.io/docs/tasks/tools/), and optionally [eksctl](https://eksctl.io/) and [AWS CLI](https://aws.amazon.com/cli/).
- You have access to an [Amazon EKS cluster](https://aws.amazon.com/eks/).

#### Step 1: Install Kubecost on your Amazon EKS cluster.

In your environment, run the following command from your terminal to install Kubecost on your existing Amazon EKS cluster.

```bash
helm upgrade -i kubecost \
oci://public.ecr.aws/kubecost/cost-analyzer --version <$VERSION> \
--namespace kubecost --create-namespace \
-f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-eks-cost-monitoring.yaml
```

> **Note**: Remember to replace $VERSION with actual version number. You can find all available versions at https://gallery.ecr.aws/kubecost/cost-analyzer

By default, the installation will include certain prerequisite software including Prometheus and kube-state-metrics. To customize your deployment, for example skipping these prerequisites if you already have them running in your cluster, you can configure any of the [available values](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values-eks-cost-monitoring.yaml) to modify storage, network configuration, and more. 

#### Step 2: Generate Kubecost dashboard endpoint.

After you install Kubecost using the Helm command in step 2, it should take under two minutes to be completed. You can run the following command to enable port-forwarding to expose the Kubecost dashboard:

```bash
kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090
```

#### Step 3: Access cost monitoring dashboard.

On your web browser, navigate to http://localhost:9090 to access the dashboard. 

You can now start monitoring your Amazon EKS cluster cost and efficiency. Depending on your organization’s requirements and set up, you may have different options to expose Kubecost for internal access. There are few examples that you can use for your references:

- You can check Kubecost documentation for [Ingress Examples](https://guide.kubecost.com/hc/en-us/articles/4407601820055-Ingress-Examples) as a reference for using Nginx ingress controller with basic auth.
- You can also consider using AWS LoadBalancer controller to expose Kubecost and use Amazon Cognito for authentication, authorization and user management. You can learn more at [“How to use Application Load Balancer and Amazon Cognito to authenticate users for your Kubernetes web apps”](https://aws.amazon.com/blogs/containers/how-to-use-application-load-balancer-and-amazon-cognito-to-authenticate-users-for-your-kubernetes-web-apps/) AWS blog post.

## Additional resources:

- [Amazon EKS documentation](https://docs.aws.amazon.com/eks/latest/userguide/cost-monitoring.html)
- [Amazon blog post](https://aws.amazon.com/blogs/containers/aws-and-kubecost-collaborate-to-deliver-cost-monitoring-for-eks-customers/)

<!--- {"article":"","section":"4402829036567","permissiongroup":"1500001277122"} --->
