Kubernetes Assets
======

The Kubecost Assets view shows Kubernetes cluster costs broken down by the individual backing assets in your cluster (e.g. cost by node, disk, and other assets). 
It’s used to identify spend drivers over time and to audit Allocation data. This view can also optionally show out-of-cluster assets by service, tag/label, etc.

> **Note**: Similar to our Allocation API, the Assets API uses our ETL pipeline which aggregates data daily. This allows for enterprise-scale with much higher performance.

![Kubecost Assets view](https://raw.githubusercontent.com/kubecost/docs/main/images/assets-screenshot.png)

This user interface is available at `<your-kubecost-address>/assets.html`.

## Cloud cost reconciliation

After granting Kubecost permission to access cloud billing data, Kubecost adjusts its asset prices once cloud billing data becomes available, e.g. AWS Cost and Usage Report and the spot data feed. Until this data is available from cloud providers, Kubecost uses data from public cloud APIs to determine cost, or alternatively custom pricing sheets. This allows teams to have highly accurate estimates of asset prices in real-time and then become even more precise once cloud billing data becomes available, which is often 1-2 hours for spot nodes and up to a day for reserved instances/savings plans. 


Note that while cloud adjustments typically lag by roughly a day, there are certain adjustments, e.g. credits, that may continue to come in over the course of the month, and in some cases at the very end of the month, so reconciliation adjustments may continue to update over time.


Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/assets.md)

<!--- {"article":"4407595924247","section":"4402829033367","permissiongroup":"1500001277122"} --->
