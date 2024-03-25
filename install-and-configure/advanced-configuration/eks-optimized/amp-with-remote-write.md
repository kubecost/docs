# AMP with Kubecost Prometheus (remote_write)

## See also

* [AMP Overview](/install-and-configure/advanced-configuration/eks-optimized/aws-amp-integration.md)
* [AWS Agentless AMP](/install-and-configure/advanced-configuration/eks-optimized/kubecost-agentless-amp.md)
* [AWS Distro for Open Telemetry](/install-and-configure/advanced-configuration/eks-optimized/kubecost-aws-distro-open-telemetry.md)

## Overview

When the Amazon Managed Service for Prometheus integration is enabled, the bundled Prometheus server in the Kubecost Helm Chart is configured in the remote\_write mode. The bundled Prometheus server sends the collected metrics to Amazon Managed Service for Prometheus using the AWS SigV4 signing process. All metrics and data are stored in Amazon Managed Service for Prometheus, and Kubecost queries the metrics directly from Amazon Managed Service for Prometheus instead of the bundled Prometheus. It helps customers not worry about maintaining and scaling the local Prometheus instance.

Kubecost has multiple methods for multi-cluster. There may be performance limits to how many clusters/nodes can be supported on a single AMP instance. Please contact Kubecost support for more information.

### Quick-Start architecture

The following architecture diagram illustrates what this configuration guide aims to achieve:

![Remote-write architecture](/images/aws-amp-multi-small.png)

You have an existing AWS account. You have IAM credentials to create Amazon Managed Service for Prometheus and IAM roles programmatically. You have an existing [Amazon EKS cluster with OIDC enabled.](https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html) Your Amazon EKS clusters have [Amazon EBS CSI](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html) driver installed

### Create Amazon Managed Service for Prometheus workspace:

#### Step 1: Run the following command to get the information of your current EKS cluster:

```bash
kubectl config current-context
```

The example output should be in this format:

```bash
arn:aws:eks:${AWS_REGION}:${YOUR_AWS_ACCOUNT_ID}:cluster/${YOUR_CLUSTER_NAME}
```

#### Step 2: Run the following command to create new a Amazon Managed Service for Prometheus workspace

```bash
export AWS_REGION=<YOUR_AWS_REGION>
aws amp create-workspace --alias kubecost-amp --region $AWS_REGION
```

The Amazon Managed Service for Prometheus workspace should be created in a few seconds. Run the following command to get the workspace ID:

{% code overflow="wrap" %}
```bash
export AMP_WORKSPACE_ID=$(aws amp list-workspaces --region ${AWS_REGION} --output json --query 'workspaces[?alias==`kubecost-amp`].workspaceId | [0]' | cut -d'"' -f 2)
echo $AMP_WORKSPACE_ID
```
{% endcode %}

### Setting up the environment:

#### Step 1: Set environment variables for integrating Kubecost with Amazon Managed Service for Prometheus

Run the following command to set environment variables for integrating Kubecost with Amazon Managed Service for Prometheus:

{% code overflow="wrap" %}
```bash
export RELEASE="kubecost"
export YOUR_CLUSTER_NAME=<YOUR_EKS_CLUSTER_NAME>
export AWS_REGION=${AWS_REGION}
export VERSION="{X.XXX.X}"
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export REMOTEWRITEURL="https://aps-workspaces.${AWS_REGION}.amazonaws.com/workspaces/${AMP_WORKSPACE_ID}/api/v1/remote_write"
export QUERYURL="http://localhost:8005/workspaces/${AMP_WORKSPACE_ID}"
```
{% endcode %}

#### Step 2: Set up IRSA to allow Kubecost and Prometheus to read & write metrics from Amazon Managed Service for Prometheus

These following commands help to automate the following tasks:

* Create an IAM role with the AWS-managed IAM policy and trusted policy for the following service accounts: `kubecost-cost-analyzer-amp`, `kubecost-prometheus-server-amp`.
* Modify current K8s service accounts with annotation to attach a new IAM role.

Run the following command in your workspace:

{% code overflow="wrap" %}
```bash
eksctl create iamserviceaccount \
    --name kubecost-cost-analyzer-amp \
    --namespace ${RELEASE} \
    --cluster ${YOUR_CLUSTER_NAME} --region ${AWS_REGION} \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonPrometheusQueryAccess \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess \
    --override-existing-serviceaccounts \
    --approve
```
{% endcode %}

```bash
eksctl create iamserviceaccount \
    --name kubecost-prometheus-server-amp \
    --namespace ${RELEASE} \
    --cluster ${YOUR_CLUSTER_NAME} --region ${AWS_REGION} \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonPrometheusQueryAccess \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess \
    --override-existing-serviceaccounts \
    --approve
```

For more information, you can check AWS documentation at [IAM roles for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) and learn more about Amazon Managed Service for Prometheus managed policy at [Identity-based policy examples for Amazon Managed Service for Prometheus](https://docs.aws.amazon.com/prometheus/latest/userguide/security\_iam\_id-based-policy-examples.html)

## Integrating Kubecost with Amazon Managed Service for Prometheus

### Preparing the configuration file

Run the following command to create a file called _config-values.yaml_, which contains the defaults that Kubecost will use for connecting to your Amazon Managed Service for Prometheus workspace.

{% code overflow="wrap" %}
```bash
cat << EOF > config-values.yaml
global:
  amp:
    enabled: true
    prometheusServerEndpoint: http://localhost:8005/workspaces/${AMP_WORKSPACE_ID}
    remoteWriteService: https://aps-workspaces.${AWS_REGION}.amazonaws.com/workspaces/${AMP_WORKSPACE_ID}/api/v1/remote_write
    sigv4:
      region: ${AWS_REGION}

sigV4Proxy:
  region: ${AWS_REGION}
  host: aps-workspaces.${AWS_REGION}.amazonaws.com
EOF
```
{% endcode %}

### Primary cluster

Run this command to install Kubecost and integrate it with the Amazon Managed Service for Prometheus workspace as the primary:

{% code overflow="wrap" %}
```bash
helm upgrade -i ${RELEASE} \
oci://public.ecr.aws/kubecost/cost-analyzer --version $VERSION \
--namespace ${RELEASE} --create-namespace \
-f https://tinyurl.com/kubecost-amazon-eks \
-f config-values.yaml \
--set global.amp.prometheusServerEndpoint=${QUERYURL} \
--set global.amp.remoteWriteService=${REMOTEWRITEURL} \
--set kubecostProductConfigs.clusterName=${YOUR_CLUSTER_NAME} \
--set kubecostProductConfigs.projectID=${AWS_ACCOUNT_ID} \
--set prometheus.server.global.external_labels.cluster_id=${YOUR_CLUSTER_NAME} \
--set serviceAccount.create=false \
--set prometheus.serviceAccounts.server.create=false \
--set serviceAccount.name=kubecost-cost-analyzer-amp \
--set prometheus.serviceAccounts.server.name=kubecost-prometheus-server-amp \
--set federatedETL.federator.useMultiClusterDB=false
```
{% endcode %}

### Additional clusters

These installation steps are similar to those for a primary cluster setup, except you do not need to follow the steps in the section "Create Amazon Managed Service for Prometheus workspace", and you need to update these environment variables below to match with your additional clusters. Please note that the `AMP_WORKSPACE_ID` and `KC_BUCKET` are the same as the primary cluster.

{% code overflow="wrap" %}
```bash
export RELEASE="kubecost"
export YOUR_CLUSTER_NAME=<YOUR_EKS_CLUSTER_NAME>
export AWS_REGION="<YOUR_AWS_REGION>"
export VERSION="1.103.4"
export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
export REMOTEWRITEURL="https://aps-workspaces.${AWS_REGION}.amazonaws.com/workspaces/${AMP_WORKSPACE_ID}/api/v1/remote_write"
export QUERYURL="http://localhost:8005/workspaces/${AMP_WORKSPACE_ID}"
```
{% endcode %}

Run this command to install Kubecost and integrate it with the Amazon Managed Service for Prometheus workspace as the additional cluster:

{% code overflow="wrap" %}
```bash
helm upgrade -i ${RELEASE} \
oci://public.ecr.aws/kubecost/cost-analyzer --version $VERSION \
--namespace ${RELEASE}  --create-namespace \
-f https://tinyurl.com/kubecost-amazon-eks \
-f config-values.yaml \
--set global.amp.prometheusServerEndpoint=${QUERYURL} \
--set global.amp.remoteWriteService=${REMOTEWRITEURL} \
--set kubecostProductConfigs.clusterName=${YOUR_CLUSTER_NAME} \
--set kubecostProductConfigs.projectID=${AWS_ACCOUNT_ID} \
--set prometheus.server.global.external_labels.cluster_id=${YOUR_CLUSTER_NAME} \
--set serviceAccount.create=false \
--set prometheus.serviceAccounts.server.create=false \
--set serviceAccount.name=kubecost-cost-analyzer-amp \
--set prometheus.serviceAccounts.server.name=kubecost-prometheus-server-amp \
--set federatedETL.useMultiClusterDB=true
```
{% endcode %}

Your Kubecost setup is now writing and collecting data from AMP. Data should be ready for viewing within 15 minutes.

To verify that the integration is set up, go to _Settings_ in the Kubecost UI, and check the Prometheus Status section.

![Prometheus status screenshot](/images/aws-amp-prom-status.png)

### Troubleshooting

See more troubleshooting steps at the bottom of [AMP Overview](aws-amp-integration.md#troubleshooting).
