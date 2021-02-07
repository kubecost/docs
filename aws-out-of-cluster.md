Integrating Kubecost with your AWS data provides the ability to allocate out of cluster costs, e.g. RDS instances and S3 buckets, back to Kubernetes concepts like namespace and deployment as well as reconcile in cluster assets back to your billing data. The latter is especially helpful when teams are using Reserved Instances, Savings Plans, or Enterprise Discounts. All billing data remains on your cluster when using this functionality and is not shared externally.

The following guide provides the steps required for enabling out of cluster costs allocation and accurate pricing, e.g. [Reserved Instance price allocation](http://docs.kubecost.com/getting-started#ri-committed-discount). In a multi-account organization, all of the following steps will need to be completed in the payer account.

## Step 1: Create an AWS Cost and Usage Report and Integrate it with Kubecost

[Follow our guide for cloud integrations](https://github.com/kubecost/docs/blob/master/aws-cloud-integrations.md)

## Step 2: Tag your resources
Kubecost utilizes AWS tagging to allocate the costs of AWS resources outside of the Kubernetes cluster to specific Kubernetes concepts, such as namespaces, pods, etc. These costs are then shown in a unified dashboard within the Kubecost interface.

To allocate external AWS resources to a Kubernetes concept, use the following tag naming scheme:

| Kubernetes Concept 	| AWS Tag Key         	| AWS Tag Value 	|
|--------------------	|---------------------	|---------------	|
| Cluster           	| kubernetes_cluster	| &lt;cluster-name>	|
| Namespace          	| kubernetes_namespace	| &lt;namespace-name> |
| Deployment         	| kubernetes_deployment	| &lt;deployment-name>|
| Label              	| kubernetes_label_NAME*| &lt;label-value>    |
| DaemonSet          	| kubernetes_daemonset	| &lt;daemonset-name> |
| Pod                	| kubernetes_pod	      | &lt;pod-name>     |
| Container          	| kubernetes_container	| &lt;container-name> |


*\*In the `kubernetes_label_NAME` tag key, the `NAME` portion should appear exactly as the tag appears inside of Kubernetes. For example, for the tag `app.kubernetes.io/name`, this tag key would appear as `kubernetes_label_app.kubernetes.io/name`.*

To use an alternative or existing AWS tag schema, you may supply these in your [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.73.0/cost-analyzer/values.yaml#L589) under the "kubecostProductConfigs.labelMappingConfigs.\<aggregation\>\_external_label" . Also be sure to set kubecostProductConfigs.labelMappingConfigs.enabled = true

More on AWS tagging [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Using_Tags.html).

Tags may take several hours to show up in the **Cost Allocations Tags** section described in the next step.

## Step 3: Enable User-Defined Cost Allocation Tags

In order to make the custom Kubecost AWS tags appear on the cost and usage reports, and therefore in Kubecost, individual cost allocation tags must be enabled. Details on which tags to enable can be found in Step #2 of this doc.

Instructions for enabling user-defined cost allocation tags [here](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/activating-tags.html)

## Having issues?


* Visit the Allocation view in the Kubecost product. If external costs are not shown, open your browser's Developer Tools > Console to see any reported errors.
* Query Athena directly to ensure data is availble. Note: it can take up to 6 hours for data to be written. 
* You may need to upgrade your AWS Glue if you are running an old version https://docs.aws.amazon.com/athena/latest/ug/glue-upgrade.html
* Finally, review pod logs from the `cost-model` container in the `cost-analyzer` pod and look for auth errors or Athena query results. 

