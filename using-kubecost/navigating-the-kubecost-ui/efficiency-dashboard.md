# Efficiency Dashboard

![Efficiency Dashboard](/images/efficiency-dashboard-1.png)

The Kubernetes Efficiency Dashboard introduced in Kubecost 2.3 is designed to give Kubecost users a powerful tool for identifying the wasted spend coming from the clusters, nodes, and workloads in their Kubernetes environment.
These Efficiency Reports provide users with a single pane of glass to understand waste across all of their Kubernetes clusters. Particularly valuable is its ability to help  users understand and see the cost of idle resources on a per-cluster basis in a multi-cluster federation.
This functionality is available in all tiers of Kubecost beginning with 2.3 and can be accessed under the ‘Monitor’ menu.

The report provides three views for examining the efficiency of your infrastructure:

- **Idle by type**: A high-level view of your wasted spend for each cluster broken down by Workload Idle and Infra Idle.
- **Resource idle by workload**: A resource-specific (CPU, RAM, etc.) breakdown view of Workload Idle and Workload Efficiency for all of your Kubernetes workloads.
- **Resource idle by cluster**: A resource-specific (CPU, RAM, etc.) breakdown view of Infra Idle for all of your clusters and nodes.

Let’s establish some definitions and then explore each of these views.

## Definitions

- _**Workload Idle**_- Workload Idle is defined as the cost of resources which are requested, but not used, by Kubernetes workloads.
For example, in a pod with a single container which requests 2 Gi of memory but only uses 1 Gi, there is 1 Gi of workload idle which is assigned a cost. **This is a new definition of ‘idle’ for Kubecost.**
- _**Infra Idle**_ - Infra Idle (Infrastructure Idle) is defined as the difference between the cost of allocated resources and the cost of the hardware on which they run. Allocation is defined as the max of usage and request.
For example, a Kubernetes node which has 32 Gi of usable memory runs two pods each with one container. The first pod requests 2 Gi of memory but only uses 1 Gi. The second pod specifies no requests but uses 3 Gi. There is 27 Gi of Infra Idle which is assigned a cost. This is the same definition of ‘idle’ as used in the Kubecost Allocations page (see more details [here](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/efficiency-idle.md)).
- _**Total Idle**_ - The sum of Infra Idle and Workload Idle.
- _**Cluster Efficiency**_ - The ratio of the cost of used resources to the total cost of all resources. (cost of resources used) / (total cost of resources). This is the efficiency metric presented in the upper right-hand corner of the Overview page. **Note:** Today, 'Cluster Efficiency' considers CPU, GPU, and RAM in its calculations. Storage metrics may be factored into the efficiency calculation in a future release.

![Cluster Efficiency on Overview](/images/efficiency-cluster-efficiency-on-overview.png)

- _**Workload Efficiency**_ - The cost-weighted ratio of resources used to resources requested. Workload Efficiency is used in the Allocations Dashboard as well (see more details [here](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/efficiency-idle.md)).

## Example

![Efficiency Explanation Visual](/images/efficiency-explanation-visual-1.jpg)
![Efficiency Explanation Visual 2](/images/efficiency-explanation-visual-2.jpg)

The above visualization can be very helpful in understanding the definition of Infra Idle and Workload Idle and how these idle costs, along with actual usage costs, make up your total Kubernetes spend.
In this example, only $50 of the $300 we spent on Kubernetes was actually ‘used’ (money spent on some resource (CPU, RAM, etc.) which was actually consumed by some workload).
$150 of our Kubernetes spend was workload idle – meaning we spent $150 on resources which were requested by some workload but not used. Finally, we can see that we spent $100 on infra idle – spare resources which are neither allocated nor used by any workload.

In this example, our cluster efficiency would be $50 (cost of resources used) / $300 (total cost of resources) = 16.7%.

We can also observe that the workload efficiency in this example would be $50 (cost of resources requested) / $200 (cost of resources requested) = 25%.
**Note:** Workload Efficiency is a cost-weighted ratio. Consider the case where CPU has 20% workload efficiency while RAM has 40% workload efficiency.
If we spent the same amount on both CPU and RAM, our workload efficiency would be 30%, but if we spent twice as much on CPU than RAM, our workload efficiency would be 25%.

## Idle by Type

![Idle by Type](/images/efficiency-dashboard-1.png)

**This is where idle analysis begins.** From this view, we can see the Total Idle, Infra idle, Workload idle, and Cluster Efficiency for every cluster.
We can also see how each cluster’s total idle cost has trended over time. You leverage this page to start reducing waste and saving money by digging into the clusters with the highest Total Idle (or total waste).
You can determine if this waste is being driven by inefficiencies in your workload requests (high workload idle) or if the waste is being driven by unnecessarily large nodes (high infra idle).  
Once we’ve identified clusters of interest, you can click on the workload idle or infra idle cost to drill-down and get an understanding of which workloads or resources are contributing most to your wasted spend.

## Resource Idle by Workload

![Resource Idle by Workload](/images/efficiency-workload-view.png)

**This is where you can analyze your workload idle costs.** Workload idle is broken down by resource (CPU, RAM, and GPU) for each workload (namespace, controller, etc.).
It is important to remember that workload idle is defined as the cost of resources which are requested but not used. There may be cases where a given workload’s usage exceeds its request – for these cases, the workload idle costs will be $0.00.

**Important Note: Kubecost must be measuring some amount of GPU usage before it will show GPU Efficiency features.**

**How can I reduce my workload idle costs?**
Kubecost is full of insights and automation to help you reduce your wasted workload idle cost!
Specifically, the [right-size container requests](/using-kubecost/navigating-the-kubecost-ui/savings/container-request-right-sizing-recommendations.md) page can help drive significant reductions in workload idle.
Additionally, the [request sizing Kubecost Action](/using-kubecost/navigating-the-kubecost-ui/savings/savings-actions.md) can help you automatically resize your container requests to significantly reduce workload idle.
Finally, we recommend reviewing our [abandoned workloads](/using-kubecost/navigating-the-kubecost-ui/savings/abandoned-workloads.md) page and cleaning up workloads that are no longer needed to reduce workload idle waste.

## Resource Idle by Cluster

![Resource Idle by Cluster](/images/efficiency-infraidle-view.png)

**This is where you can analyze your infra idle costs.**  In this page you can see infra idle – the difference between the cost of allocated resources and and the cost of the hardware they run on, broken down by clusters or nodes.
This gives you easy visibility into which nodes/clusters have the most spare resources and how much those idle resources are costing you.

**How can I reduce my infra idle costs?**
Kubecost provides some recommendations on  more cost-efficient node configurations on the [right-size cluster nodes](/using-kubecost/navigating-the-kubecost-ui/savings/cluster-right-sizing-recommendations.md) page. We also recommend enabling autoscalers like [Karpenter](https://karpenter.sh/) to ensure you are not paying for extra infra idle on an on-going basis.
