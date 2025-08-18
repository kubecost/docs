# Efficiency and Idle

For teams interested in reducing their Kubernetes costs, it's beneficial to first understand how provisioned resources have been used. There are two major concepts to start with: pod resource efficiency and cluster idle costs.

![The Allocations view aggregated by namespace, which shows efficiency & idle](/images/efficiency-idle.png)

## Workload Efficiency

Workload efficiency is defined as the resource utilization versus the resource request over a given time window. It is cost-weighted and can be expressed as follows:

> _(((CPU Usage / CPU Requested) \* CPU Cost) + ((RAM Usage / RAM Requested) \* RAM Cost)) / (RAM Cost + CPU Cost)_
>
> where\
> _CPU Usage = rate(container\_cpu\_usage\_seconds\_total) over the time window_\
> _RAM Usage = avg(container\_memory\_working\_set\_bytes) over the time window_

For example, if a pod is requesting 2CPU and 1GB, using 500mCPU and 500MB, CPU on the node costs $10/CPU, and RAM on the node costs $1/GB, we have ((0.5/2) \* 20 + (0.5/1) \* 1) / (20 + 1) = 5.5 / 21 = 26%

## Idle

Cluster idle cost is defined as the difference between the cost of allocated resources and the cost of the hardware they run on. Allocation is defined as the max of usage and requests. It can also be expressed as follows:

> _idle\_cost = sum(cluster\_cost) - (cpu\_allocation\_cost + ram\_allocation\_cost + gpu\_allocation\_cost)_
>
> where\
> _allocation = max(request, usage)_

Node idle cost can be expressed as:

> _idle\_cost = sum(node\_cost) - (cpu\_allocation\_cost + ram\_allocation\_cost + gpu\_allocation\_cost)_
>
> where\
> _allocation = max(request, usage)_

So, idle costs can also be thought of as the cost of the space that the Kubernetes scheduler could schedule pods, without disrupting any existing workloads, but it is not currently.

Kubecost continuously recalculates idle costs whenever underlying Assets & Allocations data changes. For example when cloud billing integration is enabled and Kubecost reconciles with your cloud bill, the process follows a specific sequence: first node costs are adjusted, then container workload costs on those nodes are updated, and finally idle costs are fully recalculated. As a result, when querying the Allocations API, the `__idle__` line item will not show any "adjustments" entries.

### Sharing idle

Idle can be charged back to pods on a cost-weighted basis or viewed as a separate line item. As an example, consider the following representations:

* \[ ... ] = cluster
* ( ... ) = node
* wN = workload
* \-- = idle capacity

Then, a cluster might look like:

\[ ( w1, w2, w3, w4, --, --), (w5, --, --, --, --, --) ]

In total, there are 12 units of resources, and idle can be shared as follows:

* **Separate**: In this single cluster across two nodes, there are 7 total idles.
* **Share By Node**: The first node has 4 resources used and 2 idle. The second node has 1 resource used and 5 idle. If you share idle by node, then w1-4 will share 2 idles, and w5 will get 5 idles.
* **Share By Cluster**: The single cluster has 5 resources used and 7 idle. If you share idle by cluster, then w1-5 will share the 7 idles.

### Distributing idle when aggregating

If for example you are aggregating by namespace, idle costs will be distributed to each namespace proportional to how much that namespace costs. Specifically:

> _namespace\_cpu\_idle\_cost = (namespace\_cpu\_cost / (total\_cpu\_cost - idle\_cpu\_cost)) \* idle\_cpu\_cost_

This same principle applies for ram, and also applies to any aggregation that is used (e.g. Deployment, Label, Service, Team).

## Target values for efficiency and idle

The most common pattern for cost reduction is to ensure service owners tune the efficiency of their pods, and ensure cluster owners scale resources to appropriately minimize idle.

Efficiency targets can depend on the SLAs of the application. See our [Request Right-Sizing API doc](/apis/savings-apis/api-request-right-sizing-v2.md) for more details.

It's recommended to target idle in the following ranges:

* CPU: 50%-65%
* Memory: 45%-60%
* Storage: 65%-80%

Target figures are highly dependent on the predictability and distribution of your resource usage (e.g. P99 vs median), the impact of high utilization on your core product/business metrics, and more. While too low resource utilization is wasteful, too high utilization can lead to latency increases, reliability issues, and other negative behavior.
