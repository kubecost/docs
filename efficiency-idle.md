# Efficiency and Idle

For teams interested in reducing their Kubernetes costs, it's beneficial to first understand how provisioned resources have been used. There are two major concepts to start with: pod resource efficiency and cluster idle costs.

![The Allocations view aggregated by namespace, which shows efficiency & idle](images/efficiency-idle.png)

## Pod resource efficiency

Resource efficiency over a time window is defined as the resource utilization over that time window versus the resource request over the same time window. It is cost-weighted and defined as followed:

* ((CPU Usage / CPU Requested) \* CPU Cost) + (RAM Usage / RAM Requested) \* RAM Cost) / (RAM Cost + CPU Cost))
* CPU Usage = rate(container\_cpu\_usage\_seconds\_total) over the time window
* RAM Usage = avg(container\_memory\_working\_set\_bytes) over the time window

For example, if a pod is requesting 2 CPU and 1Gb, using 500mCPU and 500MB, CPU on the node costs $10/CPU , and RAM on the node costs $1/GB, we have ((0.5/2) \* 20 + (0.5/1) \* 1) / (20 + 1) = 5.5 / 21 = 26%

## Cluster idle costs

Idle cost is defined as the difference between the cost of allocated resources and the cost of the hardware they run on. Allocation is defined as the max of usage and requests.

So, idle costs can also be thought of as the cost of the space that the Kubernetes scheduler could add pods without disrupting any workloads in but is not currently. Idle can be charged back to pods on a cost-weighted basis or viewed as a separate line item.

As an example, consider the following representations:

* \[ ... ] = cluster
* ( ... ) = node
* wN = workload
* \-- = idle capacity

Then, a cluster might look like:

\[ ( w1, w2, w3, w4, --, --), (w5, --, --, --, --, --) ]

In total, there are 12 units of resources, and idle can be shared as follows:

* **Separate**: In this single cluster across two nodes, there are 7 total idles.
* **Share By Node**: The first node has 4 resources used and 2 idle. The second node has 1 resource used and 5 idle. If you share idle by node, then w1-4 will share 2 idles, and w5 will get 5 idles.
* **Share By Cluster**: The single cluster has 5 resources used and 7 idle. If you share idle by cluster, then the 5 workloads will share the 7 idles

## Target values for efficiency and idle

The most common pattern for cost reduction is to ask service owners to tune the efficiency of their pods, then reclaim space by setting target idle costs.

Efficiency targets can depend on the SLAs of the application. See our notes on [request right-sizing](api-request-right-sizing-v2.md) for more details.

It's recommended to target idle in the following ranges:

* CPU: 50%-65%
* Memory: 45%-60%
* Storage: 65%-80%

Target figures are highly dependent on the predictability and distribution of your resource usage (e.g. P99 vs median), the impact of high utilization on your core product/business metrics, and more. While too low resource utilization is wasteful, too high utilization can lead to latency increases, reliability issues, and other negative behavior.
