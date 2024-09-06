# Cluster Right-Sizing Recommendations

Kubecost can provide and implement recommendations for right-sizing your supported clusters to ensure they are configured in the most cost-effective way. Recommendations are available for any and all clusters. In certain configurations, Kubecost is also capable of taking a recommendation and applying it directly to your cluster in one moment. These two processes should be distinguished respectively as viewing cluster recommendations vs. adopting cluster recommendations.

Kubecost is also able to implement cluster sizing recommendations on a user-scheduled interval, known as continuous cluster right-sizing.

## Viewing cluster right-sizing recommendations

You can access cluster right-sizing by selecting _Savings_ in the left navigation, then select the _Right-size your cluster nodes_ panel. 

You can choose to view recommendations for the cluster as a whole, or for each individual node group in the cluster.

For the cluster as a whole, Kubecost will offer two recommendations: simple (returns one node group) and complex (returns two or more node groups). Kubecost may hide the complex recommendation when it is more expensive than the simple recommendation, and present a single recommendation instead. For individual node groups, Kubecost will always provide a recommendation with one node group.  

These recommendations and their metrics will be displayed in a chart next to your existing configuration in order to compare values like total cost, node count, and usage.

### Configuring your cluster right-sizing recommendations

Kubecost provides its right-sizing recommendations based on the characteristics of your cluster. You have the option to edit certain properties to generate relevant recommendations.

There are multiple dropdown menus to consider:

* In the Cluster dropdown, you can select the individual cluster you wish to apply right-sizing recommendations to.
* (Optional) In the Node Group dropdown, you can select the individual node group you wish to apply right-sizing recommendations to.
* In the Window dropdown, select the number of days to query for your cluster's most recent activity. Options range from 1 day to 7 days. If your cluster has varying performance on different days of the week, it's better to select a longer interval for the most consistent recommendations.

You can toggle on _Show optimization inputs_ to view resources which will determine the minimum size of your nodes. These resources are:

* DaemonSet VCPUs/RAM: Resources allocated by DaemonSets on each node.
* Max pod VCPUs/RAM: Largest resource allocation by any single Pod in the cluster.
* Non-DaemonSet/static VCPUs/RAM: Sum of resources allocated to Pods not controlled by DaemonSets.

Finally, you can select _Edit_ to provide information about the function of your cluster.

* In the Profile dropdown, select the most relevant category of your cluster. You can select _Production_, _Development_, or _High Availability_.
  * Production: Stable cluster activity, will provide some extra space for potential spikes in activity.
  * Development: Cluster can tolerate small amount of instability, will run cluster somewhat close to capacity.
  * High availability: Cluster should avoid instability at all costs, will size cluster with lots of extra space to account for unexpected spikes in activity.
* In the Architecture dropdown, select either _x86_ or _ARM_. You may only see _x86_ as an option. This is normal. At the moment, ARM architecture recommendations are only supported on AWS clusters.

With this information provided, Kubecost can provide the most accurate recommendations for running your clusters efficiently. By following some additional steps, you will be able to adopt Kubecost's recommendation, applying it directly to your cluster.

## Adopting cluster right-sizing recommendations

### Prerequisites

To receive cluster right-sizing recommendations, you must first:

* Have a GKE/EKS/AWS Kops cluster

To adopt cluster right-sizing recommendations, you must:

* Have a GKE/EKS/AWS Kops cluster
* Enable the [Cluster Controller](/install-and-configure/advanced-configuration/controller/cluster-controller.md) on that cluster and perform the [provider service key setup](/install-and-configure/advanced-configuration/controller/cluster-controller.md#provider-service-key-setup)

In order for Kubecost to apply a recommendation, it needs write access to your cluster. Write access to your cluster is enabled with the Cluster Controller.

### Usage

To adopt a recommendation, select _Adopt recommendation_ > _Adopt_. Implementation of right-sizing for your cluster should take roughly 10-30 minutes.

If you have [Kubecost Actions](/using-kubecost/navigating-the-kubecost-ui/savings/savings-actions.md) enabled, you can also perform immediate right-sizing by selecting _Savings_, then selecting _Actions_. On the Actions page, select _Create Action_ > _Cluster Sizing_ to receive immediate recommendations and the option to adopt them.

{% hint style="info" %}
Recommendations via Kubecost Actions can only be adopted on your primary cluster. To adopt recommendations on a secondary cluster via Kubecost Actions, you must first manually switch to that cluster's Kubecost frontend.
{% endhint %}

## Continuous cluster right-sizing

### Prerequisites

Continuous cluster right-sizing has the same requirements needed as implementing any cluster right-sizing recommendations. See above for a complete description of prerequisites.

### Usage

Continuous Cluster Right-Sizing is accessible via [Actions](/using-kubecost/navigating-the-kubecost-ui/savings/savings-actions.md#guided-sizing). On the Actions page, select _Create Action_ > _Guided Sizing_. This feature implements both cluster right-sizing and [container right-sizing](/using-kubecost/navigating-the-kubecost-ui/savings/container-request-right-sizing-recommendations.md).

For a tutorial on using Guided Sizing, see [here](/using-kubecost/navigating-the-kubecost-ui/savings/savings-actions.md#guided-sizing).

## Troubleshooting

### EBS-related scheduling challenges on EKS

If you are using Persistent Volumes (PVs) with AWS's Elastic Block Store (EBS) Container Storage Interface (CSI), you may run into a problem post-resize where pods are in a Pending state because of a "volume node affinity conflict". This may be because the pod needs to mount an already-created PV which is in an Availability Zone (AZ) without node capacity for the pod. This is a limitation of the EBS CSI.

Kubecost mitigates this problem by ensuring continuous cluster right-sizing creates at least one node per AZ by forcing NodeGroups to have a node count greater than or equal to the number of AZs of the EKS cluster. This will also prevent you from setting a minimum node count for your recommendation below the number of AZs for your cluster. If the EBS CSI continues to be problematic, you can consider switching your CSI to services like Elastic File System (EFS) or FSx for Lustre.

Using Cluster Autoscaler on AWS may result in a similar error. See more [here](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md#common-notes-and-gotchas).

## Instance Selection 

Cluster right-sizing recommendations are generated by simulating placing your cluster workload requirements on multiple different instance type configurations and choosing the most resource- and cost-optimal configuration. Kubecost queries public pricing APIs of the relevant cloud provider to build and maintain a ‘general pool’ of instance type options that the cluster-sizing algorithm can choose from.
Kubecost also supports limiting the instance types that the cluster-sizing algorithm will consider so that your organization can generate recommendations using the instance types most relevant to your use case.

### Configuration
You can supply your desired list of node types in an allow list. Kubecost will only consider the specified instance types when generating recommendations. We support allow lists for AWS, GCP and Azure instance types.
Each of the allow lists can be configured by setting the related [Helm chart parameters](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values.yaml#L3451-3454). For example:

```yaml
kubecostProductConfigs:
  ...
  savingsRecommendationsAllowLists:
    AWS:
      - t3.2xlarge
      - t3.xlarge
      - t3.large
      - t3.medium
      - t3.small
      - t3.micro
      - t3.nano
      - ...
    GCP: 
      - e2-standard-2
      - ...
    Azure:
      - B1ms
      - ...
```

### Supported instance types

The complete lists of supported instance types currently available for each of the supported cloud service providers (AWS, GCP, Azure) can be found in the [Helm chart](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/docs/resources/savings-recommendations-allow-lists).

