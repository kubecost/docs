# Cluster Controller

{% hint style="warning" %}
The Cluster Controller is currently in beta. Please read the documentation carefully.
{% endhint %}

Kubecost's Cluster Controller allows you to access additional Savings features through automated processes. To function, the Cluster Controller requires write permission to certain resources on your cluster, and for this reason, the Cluster Controller is disabled by default.

The Cluster Controller enables features like:

* [Automated cluster turndown](/install-and-configure/advanced-configuration/controller/cluster-turndown.md)
* [Cluster right-sizing recommendations](/using-kubecost/navigating-the-kubecost-ui/savings/cluster-right-sizing-recommendations.md)
* [Container request right-sizing (RRS) recommendations](/using-kubecost/navigating-the-kubecost-ui/savings/container-request-right-sizing-recommendations.md)
* [Kubecost Actions](/using-kubecost/navigating-the-kubecost-ui/savings/savings-actions.md)

## Feature functionality

The Cluster Controller can be enabled on any cluster type, but certain functionality will only be enabled based on the cloud service provider (CSP) of the cluster and its type:

* The Cluster Controller can only be enabled on your primary cluster.
* The Controller itself and container RRS are available for all cluster types and configurations.
* Cluster turndown, cluster right-sizing, and Kubecost Actions are only available for GKE, EKS, and Kops-on-AWS clusters, after setting up a provider service key.

Therefore, the 'Provider service key setup' section below is optional depending on your cluster environment, but will limit functionality if you choose to skip it. Read the caution banner in the below section for more details.

## Provider service key setup

{% hint style="warning" %}
If you are enabling the Cluster Controller for a GKE/EKS/Kops AWS cluster, follow the specialized instructions for your CSP(s) below. If you aren't using a GKE/EKS Kops AWS cluster, skip ahead to the [Deploying](#deploying) section below.
{% endhint %}

<details>

<summary>GKE setup</summary>

The following command performs the steps required to set up a service account. [More info](https://github.com/kubecost/cluster-turndown/blob/master/scripts/README.md).

{% code overflow="wrap" %}
```bash
/bin/bash -c "$(curl -fsSL https://github.com/kubecost/cluster-turndown/releases/latest/download/gke-create-service-key.sh)" -- <Project ID> <Service Account Name> <Namespace> cluster-controller-service-key
```
{% endcode %}

To use [this setup script](https://github.com/kubecost/cluster-turndown/blob/master/scripts/gke-create-service-key.sh), provide the following required parameters:

* **Project ID**: The GCP project identifier. Can be found via: `gcloud config get-value project`
* **Namespace**: The namespace which Kubecost will be installed, e.g `kubecost`
* **Service Account Name**: The name of the service account to be created. Should be between 6 and 20 characters, e.g. `kubecost-controller`
* **Secret Name**: The Kubecost will automatically look for a secret called `cluster-controller-service-key`. This can be changed by setting `.Values.clusterController.secretName`.

</details>

<details>

<summary>EKS setup</summary>

For EKS cluster provisioning, if using `eksctl`, make sure that you use the `--managed` option when creating the cluster. Unmanaged node groups should be upgraded to managed. [More info](https://eksctl.io/usage/nodegroup-managed/).

Create a new User with `AutoScalingFullAccess` permissions, plus the following EKS-specific permissions:

{% code overflow="wrap" %}
```json
{
    "Effect": "Allow",
    "Action": [
        "eks:ListClusters",
        "eks:DescribeCluster",
        "eks:DescribeNodegroup",
        "eks:ListNodegroups",
        "eks:CreateNodegroup",
        "eks:UpdateClusterConfig",
        "eks:UpdateNodegroupConfig",
        "eks:DeleteNodegroup",
        "eks:ListTagsForResource",
        "eks:TagResource",
        "eks:UntagResource"
    ],
    "Resource": "*"
},
{
    "Effect": "Allow",
    "Action": [
        "iam:GetRole",
        "iam:ListAttachedRolePolicies",
        "iam:PassRole"
    ],
    "Resource": "*"
}
```
{% endcode %}

Create a new file, _service-key.json_, and use the access key ID and secret access key to fill out the following template:

```json
{
    "aws_access_key_id": "<ACCESS_KEY_ID>",
    "aws_secret_access_key": "<SECRET_ACCESS_KEY>"
}
```

Then, run the following to create the secret:

{% code overflow="wrap" %}
```bash
$ kubectl create secret generic cluster-controller-service-key -n <NAMESPACE> --from-file=service-key.json
```
{% endcode %}

Here is a full example of this process using the AWS CLI and a simple IAM user (requires `jq`):

```bash
NEW_IAM_USER
aws iam create-user \
    --user-name $NEW_IAM_USER

aws iam attach-user-policy \
    --user-name $NEW_IAM_USER \
    --policy-arn arn:aws:iam::aws:policy/AutoScalingFullAccess

read -r -d '' EKSPOLICY << EOM
{
    "Version": "2012-10-17",
    "Statement": [
    {
        "Effect": "Allow",
        "Action": [
            "eks:ListClusters",
            "eks:DescribeCluster",
            "eks:DescribeNodegroup",
            "eks:ListNodegroups",
            "eks:CreateNodegroup",
            "eks:UpdateClusterConfig",
            "eks:UpdateNodegroupConfig",
            "eks:DeleteNodegroup",
            "eks:ListTagsForResource",
            "eks:TagResource",
            "eks:UntagResource"
        ],
        "Resource": "*"
    },
    {
        "Effect": "Allow",
        "Action": [
            "iam:GetRole",
            "iam:ListAttachedRolePolicies",
            "iam:PassRole"
        ],
        "Resource": "*"
    }
    ]
}
EOM

aws iam put-user-policy \
    --user-name $NEW_IAM_USER \
    --policy-name "eks-permissions" \
    --policy-document "${EKSPOLICY}"

aws iam create-access-key \
    --user-name $NEW_IAM_USER --output json \
    > /tmp/aws-key.json

AAKI="$(jq -r '.AccessKey.AccessKeyId' /tmp/aws-key.json)"
ASAK="$(jq -r '.AccessKey.SecretAccessKey' /tmp/aws-key.json)"
kubectl create secret generic \
    cluster-controller-service-key \
    -n kubecost \
    --from-literal="service-key.json={\"aws_access_key_id\": \"${AAKI}\", \"aws_secret_access_key\": \"${ASAK}\"}"

```

</details>

<details>

<summary>Kops-on-AWS setup</summary>

Create a new user or IAM role with `AutoScalingFullAccess` permissions. JSON definition of those permissions:

{% code overflow="wrap" %}
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": "autoscaling:*",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "cloudwatch:PutMetricAlarm",
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeImages",
                "ec2:DescribeInstanceAttribute",
                "ec2:DescribeInstances",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeLaunchTemplateVersions",
                "ec2:DescribePlacementGroups",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSpotInstanceRequests",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcClassicLink"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": [
                "elasticloadbalancing:DescribeLoadBalancers",
                "elasticloadbalancing:DescribeTargetGroups"
            ],
            "Resource": "*"
        },
        {
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": "autoscaling.amazonaws.com"
                }
            }
        }
    ]
}


```
{% endcode %}

Create a new file, _service-key.json_, and use the access key ID and secret access key to fill out the following template:

```json
{
    "aws_access_key_id": "<ACCESS_KEY_ID>",
    "aws_secret_access_key": "<SECRET_ACCESS_KEY>"
}
```

Then run the following to create the secret:

{% code overflow="wrap" %}
```
$ kubectl create secret generic cluster-controller-service-key -n <NAMESPACE> --from-file=service-key.json
```
{% endcode %}

</details>

## Deploying

You can now enable the Cluster Controller in the Helm chart by finding the `clusterController` Helm flag and setting `enabled: true`

```yaml
clusterController:
  enabled: true
```

You may also enable via `--set` when running Helm install:

```bash
helm install kubecost kubecost \
--repo https://kubecost.github.io/cost-analyzer/ \
--namespace kubecost --create-namespace \
--set clusterController.enabled=true
```

## Verify the Cluster Controller is running

You can verify that the Cluster Controller is running by issuing the following:

```
kubectl get pods -n kubecost -l app=kubecost-cluster-controller
```

Once the Cluster Controller has been enabled successfully, you should automatically have access to the listed Savings features.
