Integrating Kubecost with your AWS data provides the ability to allocate out of cluster costs, e.g. RDS instances and S3 buckets, back to Kubernetes concepts like namespace and deployment.

The following guide provides the steps required for enabling out of cluster costs allocation. In a multi-account organization, all of the following steps will need to be completed in the payer account.


## Step 1: Enable User-Defined Cost Allocation Tags
Kubecost utilizes AWS tagging to allocate the costs of AWS resources outside of the Kubernetes cluster to specific Kubernetes concepts, such as namespaces, pods, etc. These costs are then shown in a unified dashboard within the Kubecost interface.

In order to make the custom Kubecost AWS tags appear on the cost and usage reports, and therefore in Kubecost, individual cost allocation tags must be enabled. Details on which tags to enable can be found in Step #6 of this doc.

[Instructions for enabling user-defined cost allocation tags](https://docs.aws.amazon.com/awsaccountbilling/latest/aboutv2/activating-tags.html)


## Step 2: Tag your resources

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

To use an alternative or existing AWS tag schema, you may supply these in your [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) under the "kubecostProductConfigs.labelMappingConfigs.\<aggregation\>\_external_label" 


More on AWS tagging [here](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/Using_Tags.html).

**Note:** you must include the protocol for your S3 bucket name, e.g. s3://aws-athena-query-results-5303329856255-us-east-1

## Having issues?

* Visit the Allocation view in the Kubecost product. If external costs are not shown, open your browser's Developer Tools > Console to see any reported errors.
* Query Athena directly to ensure data is availble. Note: it can take up to 6 hours for data to be written. 
* You may need to upgrade your AWS Glue if you are running an old version https://docs.aws.amazon.com/athena/latest/ug/glue-upgrade.html
* Finally, review pod logs from the `cost-model` container in the `cost-analyzer` pod and look for auth errors or Athena query results. 

