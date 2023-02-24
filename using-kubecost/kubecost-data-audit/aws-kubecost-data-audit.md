# AWS/Kubecost Data Audit

### **Prerequisite**

Before comparing costs between Kubecost and AWS Cost Explorer, ensure your Kubecost deployment has configured [Cloud Billing Integrations](https://docs.kubecost.com/install-and-configure/install/cloud-integration/aws-cloud-integrations).

### Performing a data audit

1. Go to the Assets page, then select _Aggregate By_ > _Single Aggregation_ > _Service_.

<figure><img src="../../.gitbook/assets/step1.annotate2.png" alt=""><figcaption></figcaption></figure>

2. Audits are most effective when targeting small ranges of time. Select a Start and End Date which covers a window of 1 day, and is beyond 48 hours ago. Also select a date that has reconciled with the AWS Cost and Usage Report (CUR). CUR data can be delayed up to 24 hours.

<figure><img src="../../.gitbook/assets/step2.annotate2.png" alt=""><figcaption></figcaption></figure>

3. Select the _Kubernetes_ service from the table underneath the NAME column, then select _Node_. You should arrive at a page like this (if your information is displayed in a bar graph, you can change the display by selecting _Edit_, then _Entire Window_ under the Resolution dropdown):

<figure><img src="../../.gitbook/assets/step3.annotate.png" alt=""><figcaption></figcaption></figure>

4. Select any node to view its details.

<figure><img src="../../.gitbook/assets/step4.annotate.png" alt=""><figcaption></figcaption></figure>

5. Compare this instance's costs with what is found in AWS Cost Explorer (Amortized). The most accessible way of doing so is _Group by_ -> _Resource_, and _Filters -> Resource -> i-033b92ecd18376946._

<figure><img src="../../.gitbook/assets/step5.annotate.png" alt=""><figcaption></figcaption></figure>

If unable to _Group by -> Resource_ (because it requires enabling hourly/resource granularity in Cost Explorer), try _Group by -> Tag -> aws:eks:cluster-name_, and _Filters -> Tag -> aws:eks:cluster-name -> kc-demo-prod_.

> &#x20;**Note**: These costs only account for the nodes and network costs, not the ClusterManagement/ControlPlane, Disks, LoadBalancer.

This method is also more lossy than comparing a specific node between Kubecost and AWS Cost Explorer.

<figure><img src="../../.gitbook/assets/step5a.1.annotate.png" alt=""><figcaption></figcaption></figure>

<figure><img src="../../.gitbook/assets/step5a.2.annotate.png" alt=""><figcaption></figcaption></figure>

### **Auditing other resources**&#x20;

This doc should be used for auditing Kubernetes assets whose costs in Kubecost get adjusted once reconciled with the CUR. Kubecost should present its cost data within a 5% margin of what Cost Explorer is presenting.

When Kubecost reports costs on non-Kubernetes assets, those numbers should be exact, as those should be directly derived from the CUR.

### **Troubleshooting non-matching costs**

* Investigate Prometheus to see if the underlying metrics about the node are sporadic or missing.
* Cost Explorer CSV export for one day filtered by account and service in AWS. Compare that to the Kubecost `/model/asset` API request for the same day.
* Set up CUR to export as CSV file. Investigate to see whether costs in CSV file match with Kubecost Assets page.
* Test Athena queries.
