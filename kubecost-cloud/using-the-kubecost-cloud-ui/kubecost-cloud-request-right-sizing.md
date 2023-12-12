# Kubecost Cloud: Request Right-Sizing Recommendations

{% hint style="info" %}
This documentation should only be consulted when using Kubecost Cloud! For information about request right-sizing recommendations for self-hosted Kubecost, see [here](/using-kubecost/navigating-the-kubecost-ui/savings/container-request-right-sizing-recommendations.md).
{% endhint %}

Kubecost Cloud is able to provide recommendations for right-sizing your container requests to ensure they are as cost-effective as possible. Recommendations are provided for all namespaces within your cluster.

## Viewing request recommendations

You can access request right-sizing by selecting _Savings_ in the left navigation, then select the _Right-size your container requests_ panel.

On the Container Request Right-sizing Recommendations page, you will see a table containing all namespaces/controller pairs and the cluster and container associated with each. You will also see the requested and recommended RAM/CPU, the current efficiency, and finally estimated monthly savings by adopting recommendations.

### Configuring your recommendations

The displayed right-sizing recommendations are calculated by taking into account your environment profile. You can optionally configure this for more optimal results by selecting _Customize_ above the table.
* Window: The range of time Kubecost will read for resource activity to determine its recommendations.
* Profile: Refers to the type of environment. The selected value for Profile may restrict you from customizing certain other values.
  * Production: Stable container activity, will provide some extra space for potential spikes in activity.
  * Development: Container can tolerate small amount of instability, will run somewhat close to capacity.
  * High availability: Container should avoid instability at all costs, will size container with lots of extra space to account for unexpected spikes in activity.
* CPU/RAM recommendation algorithm: The algorithm used to compute the recommendations. Currently, the only supported option is _Percentile_.
* CPU/RAM target utilization: These can be set to limit recommended utilization of resources below a percentage threshold.
* CPU/RAM percentile: Percentage of data points that will be sampled within your window range. Outlier data will be filtered out when determining recommendations.
* Add Filters: Filter the table of namespaces/controllers to be equal or not equal to values of one or several different categories such as cluster, label, or pod. For example, if you want to only see namespace/cluster pairs within the namespace kube-system, select _Namespace_ from the first dropdown, select _Equals_ from the second dropdown, then provide the value "kube-system" in the text box. Select the plus icon to confirm your filter. Multiple filters can be applied.

Select _Save_ to confirm your customization. The table should update accordingly.
