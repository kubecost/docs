# AWS/Kubecost Data Audit

## Performing a data audit

First, in the Kubecost UI, [view the price of a single node for a single day](./).

![Node cost details](/images/data-auditing/dataaudit-step4.png)

Next, compare this instance's costs with what is found in AWS Cost Explorer (Net Amortized). The most accessible way of doing so is _Group by_ -> _Resource_, and _Filters -> Resource -> i-033b92ecd18376946._

![A node cost for one day in AWS Cost Explorer](/images/data-auditing/dataaudit-aws-costexplorer1.png)

If unable to _Group by -> Resource_ (because it requires enabling hourly/resource granularity in Cost Explorer), try _Group by -> Tag -> aws:eks:cluster-name_, and _Filters -> Tag -> aws:eks:cluster-name -> kc-demo-prod_. This will compare the cost of a cluster in AWS Cost Explorer, versus the cost of a cluster in Kubecost.

> **Note**: When grouping by cluster, AWS Cost Explorer only accounts for the Node and Network costs, not the ClusterManagement/ControlPlane, Disks, or LoadBalancer costs. Also keep in mind this method will also be less exact than comparing a specific node between Kubecost and AWS Cost Explorer.

![Daily cost of an EKS cluster in AWS Cost Explorer](/images/data-auditing/dataaudit-aws-costexplorer2.png)

![Kubecost Asset cost for an EKS cluster](/images/data-auditing/dataaudit-aws-kubecost.png)

## Troubleshooting non-matching costs

To determine what could cause a discrepancy between your instances' cost and AWS Cost Explorer, perform these troubleshooting measures:

* Investigate Prometheus to see if the underlying metrics about the node are sporadic or missing.
* Cost Explorer CSV export for one day filtered by account and service in AWS. Compare that to the Kubecost `/model/asset` API request for the same day.
* Set up CUR to export as CSV file. Investigate to see whether the costs in the CSV file match with what is displayed on the Kubecost Assets page.
* Test Athena queries.
