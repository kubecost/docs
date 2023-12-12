# Container Request Right-Sizing Recommendations

{% hint style="warning" %}
This feature is in beta. Please read the documentation carefully.
{% endhint %}

Kubecost can automatically implement its [recommendations](/apis/apis-overview/api-request-right-sizing-v2.md) for container [resource requests](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits) if you have the [Cluster Controller](/install-and-configure/advanced-configuration/controller/cluster-controller.md) component enabled. Using container request right-sizing (RRS) allows you to instantly optimize resource allocation across your entire cluster. You can easily eliminate resource over-allocation in your cluster, which paves the way for vast savings via cluster right-sizing and other optimizations.

## Prerequisites

There are no restrictions to receive container RRS recommendations, however, to adopt these recommendations, you must:

* Have a GKE/EKS/AWS Kops cluster
* Enable the [Cluster Controller](/install-and-configure/advanced-configuration/controller/cluster-controller.md) on that cluster

In order for Kubecost to apply a recommendation, it needs write access to your cluster. Write access to your cluster is enabled with the Cluster Controller.

## Configuring RRS recommendations

Select _Savings_ in the left navigation, then select _Right-size your container requests_. The Request right-sizing recommendations page opens.

Select _Customize_ to modify the right-sizing settings. Your customization settings will tell Kubecost how to calculate its recommendations, so make sure it properly represents your environment and activity:

* Window: Duration of deployment activity Kubecost should observe
* Profile: Select from *Development*, *Production*, or High Availability*, which come with preconfigured values for CPu/RAM target utilization fields. Selecting *Custom* will allow you to manually configure these fields.
* CPU/RAM recommendation algorithm: Alwayus configured to *Max*.
* CPU/RAM target utilization: Refers to the percentage of used resources over total resources available.
* Add Filters: Optional configuration to limit the deployments which will have right-sizing recommendations applied. This will provide greater flexibility in optimizing your environment. Ensure you select the plus icon next to the filter value text box to add the filter. Multiple filters can be added.

When finished, select *Save*.

Your configured recommendations can also be downloaded as a CSV file by selecting the three dots button > _Download CSV_.

## Adopting RRS recommendations

There are several ways to adopt Kubecost's container RRS recommendations, depending on how frequently you wish to utilize this feature for your container requests.

### One-click right-sizing

To apply RRS as you configured in one instance, select *Resize Requests Now* > *Yes, apply the recommendation*.

### Autoscaling

Also referred to as continuous container RRS, autoscaling allows you to configure a schedule to routinely apply RRS to your deployments. You can configure this by selecting *Enable Autoscaling*, selecting your Start Date and schedule, then confirming with *Apply*.

### Savings Actions

Both one-click and continuous container RRS can be configured via Savings [Actions](/using-kubecost/navigating-the-kubecost-ui/savings/savings-actions.md). On the Actions page, select _Create Action_, then select either:

* _Request Sizing_: Will open the Container RRS page with the schedule window open to configure and apply.
* _Guided Sizing_: Will open the Guided Sizing page and allow you to apply both one-click RRS, then continous [cluster sizing](/using-kubecost/navigating-the-kubecost-ui/savings/cluster-right-sizing-recommendations.md)
