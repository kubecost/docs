# Container Request Right-Sizing Recommendations

The container request right-sizing recommendations page shows containers which would benefit from changes to their [resource requests](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits). It additionally provides convenient options to automate the application of those [recommendations](/apis/savings-apis/api-request-right-sizing-v2.md). Using container request right-sizing allows you to optimize resource allocation across your entire cluster. You can easily eliminate resource over-allocation in your cluster, which paves the way for vast savings via cluster right-sizing and other optimizations.

![Container Request Right-Sizing Recommendations dashboard](/images/crss.png)

To access the container request right-sizing recommendations savings page, select _Savings_ in the left navigation pane, then select _Right-size container requests_.

Resource requests in Kubernetes are guarantees about resources made available from nodes to pods. They function effectively as reservations on capacity. With requests in place, Kubernetes will only schedule a pod to a node if the node has the available capacity. Defining requests is beneficial in that it increases the pod [quality of service](https://kubernetes.io/docs/concepts/workloads/pods/pod-qos) priority from BestEffort to Burstable, helpful when nodes come under pressure and some pods must be selected for eviction. From a cost perspective, ensuring that requests are always kept within an appropriate range is important. Requesting too much capacity while not consuming it means other pods cannot use the available capacity, increasing costs to run a set of workloads as potentially more, or larger, nodes are needed to run available pods.

For more details on how requests and limits function in Kubernetes, see the Kubecost blog post [Kubernetes Requests and Limits: A Practical Guide and Solutions](https://blog.kubecost.com/blog/requests-and-limits/).

The container request right-sizing recommendations page shows a tabular view of containers and their pod controllers being monitored by Kubecost along with recommendations for the resource requests. Each row represents a container where the pod controller kind and name is shown, therefore duplicate values indicate multiple containers in the same pod or pod controller have recommendations. The page offers options to sort the recommendations by CPU and RAM dimensions such as average and maximum usage, recommended requests, and current requests.

![RAM and CPU offer sort options based on various dimensions](/images/crss-ram-sort.png)

Recommendations from Kubecost can including both increasing, decreasing, as well as establishing net new resource requests. When Kubecost recommends a decrease in resource requests, this results in savings opportunities. The _EST. SAVINGS_ field (Estimated Savings) shows the estimated amount of monthly savings which can be achieved by adopting the recommendations. The amount of estimated savings depends on the Profile and other [configuration options](#configuring-request-right-sizing-recommendations) which are explained below. The container request right-sizing recommendations table is sorted by default in descending order according to the estimated savings available.

The request sizing algorithm calculates monthly CPU and RAM savings by comparing current costs with projected costs for the recommended resource allocation. Here's how it works:

1. The algorithm calculates the cost per CPU core and RAM Byte based on your current resource allocation during the analysis period.
2.The algorithm then gets the difference between your average CPU and RAM usage to the recommended amounts.
3. Finally, the algorithm multiplies the difference in resource usage by the calculated costs to estimate your monthly savings.

This approach allows Kubecost to provide accurate savings estimates tailored to your specific resource usage and costs. The overall monthly savings for all your containers are represented in the container request right-sizing recommendation page under estimated available savings.  

The _CURRENT EFFICIENCY_ field shows the efficiency of the container as a result of its current usage-to-request ratio factoring in both CPU and memory. Efficiencies at or above 100% usually indicate the container is undersized in one or both resources and Kubecost recommends increasing requests.

Expand one of the rows to see more details on the workload and the recommendations offered by Kubecost. This view shows more information about the workload, including details such as the namespace and container name, along with the current request values and Kubecost's recommendations. The recommendations displayed in this view are also a result of the [configuration options](#configuring-request-right-sizing-recommendations) explained below.

![Detailed view of a container where Kubecost has a recommendation](/images/crss-expand.png)

By clicking a row instead of expanding it, the Workload Savings screen opens to that container. In this view, more details are provided on the container and requests along with an ability to view all associated labels and a link to view the observed utilization metrics for yourself in Grafana (if deployed).

![Workload Savings page of a container](/images/crss-workload-savings.png)

## Prerequisites

While there are no restrictions to provide/view container request right-sizing recommendations, in order for Kubecost to apply those recommendations the [Cluster Controller](/install-and-configure/advanced-configuration/controller/cluster-controller.md) component is required. You must deploy Cluster Controller to the cluster(s) where Kubecost will apply any recommendations.

## Configuring request right-sizing recommendations

Select _Customize_ to modify the right-sizing settings. Your customization settings will tell Kubecost how to calculate its recommendations, so make sure it properly represents your environment and activity:

* Window: Duration of deployment activity Kubecost will observe.
* Profile: Select from _Development_, _Production_, or High Availability, which come with predefined values for CPU/RAM target utilization fields. Selecting _Custom_ will allow you to manually configure these fields.
* CPU/RAM recommendation algorithm: Set to _Max_ when any non-custom profile is in use. Additional algorithms include percentile of average and percentile of max.
* CPU/RAM target utilization: Used along with the recommendation algorithm to determine the final value used for the new requests. For example, when the recommendation algorithm is configured for _Max_, a target utilization of 0.8 and a maximum CPU usage of 1.2 CPUs will result in a recommendation of 1.5 CPUs (1,500m). This is because 1.2 CPUs (the maximum) is 80% of 1.5 CPUs (the recommendation). Mathematically, this can be expressed as `0.8(x) = 1.2`.
* Add Filters: Optional configurations to limit the returned request right-sizing results. Multiple filters are supported.

When finished, select _Save_.

{% hint style="info" %}
Regardless of how the recommendations are configured or how low the observed utilization is, Kubecost has a minimum recommendation threshold of 10m for CPU and 20Mi for RAM.
{% endhint %}

Your configured recommendations can also be downloaded as a CSV file by selecting the meatballs menu followed by _Download CSV_.

## Adopting request right-sizing recommendations

There are several ways to adopt Kubecost's container request right-sizing recommendations, depending on how frequently you wish to utilize this feature for your container requests. Note that although Kubecost will show containers from multiple different pod controllers, only deployments are supported when it comes to applying recommendations.

### One-click right-sizing

To apply container request right-sizing recommendations on-demand based on the current results of the page, select _Resize Requests Now_ and click the _Yes, apply the recommendation_ button. The new request values as shown in the current view will be applied.

### Autoscaling

Autoscaling allows you to automatically apply container request right-sizing recommendations periodically based upon a schedule to the available deployments. You can configure this by selecting _Enable Autoscaling_, selecting your Start Date and schedule, then confirming with _Apply_.

### Savings Actions

These and other automated savings opportunities can also be configured via Savings [Actions](savings-actions.md). See the [Actions](savings-actions.md) documentation for more details.
