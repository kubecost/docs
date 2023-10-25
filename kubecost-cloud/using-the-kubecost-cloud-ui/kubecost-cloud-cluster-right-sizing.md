# Kubecost Cloud: Cluster Sizing Recommendations

{% hint style="info" %}
This documentation should only be consulted when using Kubecost Cloud! For information about cluster sizing recommendations for self-hosted Kubecost, see [here](/using-kubecost/navigating-the-kubecost-ui/savings/cluster-right-sizing-recommendations.md).
{% endhint %}

Kubecost Cloud can provide recommendations for right-sizing your clusters to ensure they are configured in the most cost-effective way. Recommendations are available for any and all clusters.

## Viewing cluster recommendations

You can access cluster right-sizing by selecting *Savings* in the left navigation, then select the *Right-size your cluster nodes* panel.

Kubecost will offer two recommendations: simple (uses one node type) and complex (uses two or more node types). Kubecost may hide the complex recommendation when it is more expensive than the simple recommendation, and present a single recommendation instead. These recommendations and their metrics will be displayed in a chart next to your existing configuration in order to compare values like total cost, node count, and usage.

{% hint style="info" %}
You may see the Total cost of the simple or complex recommendations being larger than your current cost. This is because when Kubecost Cloud attempts to find the cheapest configuration of nodes to support the existing cluster workload, it does not read the current cost and attempt to minimize it. In this case, Kubecost Cloud is unable to provide an optimized recommendation for your current workload.
{% endhint %}

You can toggle on _Show advanced metrics_ to view more details about your cluster resource consumption.

### Configuring your recommendations

Kubecost Cloud provides its right-sizing recommendations based on the characteristics of your cluster. You have the option to edit certain properties to generate relevant recommendations. Select _Filter_ to configure your settings in the Cluster Sizing Settings window.

There are multiple dropdown menus to consider:
* In the Cluster dropdown, you can select the individual cluster you wish to apply right-sizing recommendations to.
* In the Profile dropdown, select the most relevant category of your cluster. You can select _Production_, _Development_, or _High Availability_.
  * Production: Stable cluster activity, will provide some extra space for potential spikes in activity.
  * Development: Cluster can tolerate small amount of instability, will run cluster somewhat close to capacity.
  * High availability: Cluster should avoid instability at all costs, will size cluster with lots of extra space to account for unexpected spikes in activity.
* In the Architecture dropdown, select either _x86_ or _ARM_. You may only see x86 as an option. This is normal. At the moment, ARM architecture recommendations are only supported on AWS clusters.

With this information provided, Kubecost can provide the most accurate recommendations for running your clusters efficiently.
