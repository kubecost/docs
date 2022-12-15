Amazon Managed Service for Prometheus
==================
## Overview

Kubecost leverages the open-source Prometheus project as a time series database and post-processes the data in Prometheus to perform cost allocation calculations and provide optimization insights for your Kubernetes clusters such as Amazon Elastic Kubernetes Service (Amazon EKS). Prometheus is a single machine statically-resourced container, so depending on your cluster size or when your cluster scales out, it could exceed the scraping capabilities of a single Prometheus server. In the collaboration with Amazon Web Services (AWS), Kubecost integrates with [Amazon Managed Service for Prometheus (AMP)](https://docs.aws.amazon.com/prometheus/index.html) - a managed Prometheus-compatible monitoring service - to enable the customer to easily monitor Kubernetes cost at scale. 

## Reference resources

- [Amazon Managed Prometheus (AMP)](https://docs.aws.amazon.com/prometheus/latest/userguide/what-is-Amazon-Managed-Service-Prometheus.html)
- [AMP IAM permissions and policies](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-and-IAM.html)

## Installation guides
### Install AMP
#### Prerequisites
- You have an existing AWS account.
- You have IAM credentials to create AMP and IAM roles programmatically.
- You have an existing Amazon EKS cluster with OIDC enabled. You can consider using the following command to enable OIDC for your existing Amazon EKS cluster:

> **Note**: Remember to replace `<YOUR_CLUSTER_NAME>` and `<AWS_REGION>` with your desired values

```
export YOUR_CLUSTER_NAME=<YOUR-CLUSTER-NAME>
export AWS_REGION=<YOUR-AWS-REGION>

eksctl utils associate-iam-oidc-provider \
    --cluster ${YOUR_CLUSTER_NAME} --region ${AWS_REGION} \
    --approve
```
#### Setting up AMP

You can use the following AWS CLI command to create a new AMP workspace:

```bash
export AWS_REGION=<YOUR-AWS-REGION>
aws amp create-workspace --alias kubecost-amp --region $AWS_REGION
```
Example output:

```json
{
    "arn": "arn:aws:aps:us-west-2:xxxxxxxxxxxxx:workspace/${AMP_WORKSPACE_ID}",
    "status": {
        "statusCode": "CREATING"
    },
    "tags": {},
    "workspaceId": "${AMP_WORKSPACE_ID}"
}
```

The workspace should be created in a few seconds. You can log in to [AWS AMP console](https://console.aws.amazon.com/prometheus/) to retrieve more information. You need to set `$REMOTEWRITEURL` and `$QUERYURL` for using in the integration with Kubecost later as follows:

REMOTEWRITEURL="https://aps-workspaces.us-west-2.amazonaws.com/workspaces/${AMP_WORKSPACE_ID}/api/v1/remote_write"
QUERYURL="http://localhost:8005/workspaces/${AMP_WORKSPACE_ID}"

### Install Kubecost with the default values

#### Prerequisites
- Install the following tools: [Helm 3.9+](https://helm.sh/docs/intro/install/), [kubectl](https://kubernetes.io/docs/tasks/tools/), and optionally [eksctl](https://eksctl.io/) and [AWS CLI](https://aws.amazon.com/cli/).
- You have access to an [Amazon EKS cluster](https://aws.amazon.com/eks/).

#### Installation

Run the following command to install Kubecost from Amazon ECR Public Gallery:

```bash
helm upgrade -i kubecost \
oci://public.ecr.aws/kubecost/cost-analyzer --version <$VERSION> \
--namespace kubecost --create-namespace \
-f https://tinyurl.com/kubecost-amazon-eks
```
### Set up IAM role for Kubecost service account (IRSA):

These following commands help to automate the following tasks:
- Create an IAM role with the AWS managed IAM policy and trusted policy for the following service accounts: `kubecost-cost-analyzer`, `kubecost-prometheus-server`.
- Modify current K8s service accounts with annotation to attach new IAM role.

> **Note**: remember to replace `<YOUR_CLUSTER_NAME>` and `<AWS_REGION>` with your desired values

```
eksctl create iamserviceaccount \
    --name kubecost-cost-analyzer \
    --namespace kubecost \
    --cluster ${YOUR_CLUSTER_NAME} --region ${AWS_REGION} \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonPrometheusQueryAccess \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess \
    --override-existing-serviceaccounts \
    --approve


eksctl create iamserviceaccount \
    --name kubecost-prometheus-server \
    --namespace kubecost \
    --cluster ${YOUR_CLUSTER_NAME} --region ${AWS_REGION} \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonPrometheusQueryAccess \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonPrometheusRemoteWriteAccess \
    --override-existing-serviceaccounts \
    --approve
```

For more information, you can check AWS documentation at [IAM roles for service accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) and learn more about AMP managed policy at [Identity-based policy examples for Amazon Managed Service for Prometheus](https://docs.aws.amazon.com/prometheus/latest/userguide/security_iam_id-based-policy-examples.html)

### Configure Kubecost to use AMP as a time series database

If you use the default values as in this documentation, you can simply run this command to update Kubecost Helm release to use your AMP workspace as a time series database.

```bash
helm upgrade -i kubecost \
oci://public.ecr.aws/kubecost/cost-analyzer --version <$VERSION> \
--namespace kubecost --create-namespace \
-f https://tinyurl.com/kubecost-amazon-eks \
-f https://tinyurl.com/kubecost-amp \
--set global.amp.prometheusServerEndpoint=${QUERYURL} \
--set global.amp.remoteWriteService=${REMOTEWRITEURL}
```

For advanced configuration, you can download [values-amp.yaml](https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-amp.yaml) locally to edit it accordingly then run the following command:

```bash
helm upgrade -i kubecost \
oci://public.ecr.aws/kubecost/cost-analyzer --version <$VERSION> \
--namespace kubecost --create-namespace \
-f https://tinyurl.com/kubecost-amazon-eks \
-f PATH_TO_THE_LOCAL_DIRECTORY/values-amp.yaml
```

Next, run the following command to restart the Prometheus deployment to reload the service account configuration:
  
```bash
kubectl rollout restart deployment/kubecost-prometheus-server -n kubecost
```

Your Kubecost setup is now start writing and collecting data from AMP. Data should be ready for viewing within 15 minutes.

---

To verify that the integration is set up, check the `Prometheus Status` section on Kubecost Settings page.

![Prometheus status screenshot](https://user-images.githubusercontent.com/22844059/132998278-fd388e9a-8d61-4b8b-ad1c-0e52f17ca251.png)

Have a look at the [Custom Prometheus integration troubleshooting guide](https://docs.kubecost.com/custom-prom.html#troubleshooting-issues) if you run into any errors while setting up the integration. You're also welcome to [reach out to us on Slack](https://join.slack.com/t/kubecost/shared_invite/zt-1dz4a0bb4-InvSsHr9SQsT_D5PBle2rw) if you require further assistance or if you need support from AWS team, you can submit a support request through your existing [AWS support contract](https://aws.amazon.com/contact-us/).

### Add recording rules (optional)

You can add these recording rules to improve the performance. Recording rules allow you to precompute frequently needed or computationally expensive expressions and save their results as a new set of time series. Querying the precomputed result is often much faster than running the original expression every time it is needed. Follow [these instructions](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-Ruler.html) to add the following rules:

```yaml
    groups:
      - name: CPU
        rules:
          - expr: sum(rate(container_cpu_usage_seconds_total{container_name!=""}[5m]))
            record: cluster:cpu_usage:rate5m
          - expr: rate(container_cpu_usage_seconds_total{container_name!=""}[5m])
            record: cluster:cpu_usage_nosum:rate5m
          - expr: avg(irate(container_cpu_usage_seconds_total{container_name!="POD", container_name!=""}[5m])) by (container_name,pod_name,namespace)
            record: kubecost_container_cpu_usage_irate
          - expr: sum(container_memory_working_set_bytes{container_name!="POD",container_name!=""}) by (container_name,pod_name,namespace)
            record: kubecost_container_memory_working_set_bytes
          - expr: sum(container_memory_working_set_bytes{container_name!="POD",container_name!=""})
            record: kubecost_cluster_memory_working_set_bytes
      - name: Savings
        rules:
          - expr: sum(avg(kube_pod_owner{owner_kind!="DaemonSet"}) by (pod) * sum(container_cpu_allocation) by (pod))
            record: kubecost_savings_cpu_allocation
            labels:
              daemonset: "false"
          - expr: sum(avg(kube_pod_owner{owner_kind="DaemonSet"}) by (pod) * sum(container_cpu_allocation) by (pod)) / sum(kube_node_info)
            record: kubecost_savings_cpu_allocation
            labels:
              daemonset: "true"
          - expr: sum(avg(kube_pod_owner{owner_kind!="DaemonSet"}) by (pod) * sum(container_memory_allocation_bytes) by (pod))
            record: kubecost_savings_memory_allocation_bytes
            labels:
              daemonset: "false"
          - expr: sum(avg(kube_pod_owner{owner_kind="DaemonSet"}) by (pod) * sum(container_memory_allocation_bytes) by (pod)) / sum(kube_node_info)
            record: kubecost_savings_memory_allocation_bytes
            labels:
              daemonset: "true"
```
