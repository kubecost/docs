# Local Disks

Kubecost displays all local disks it detects with low usage, with recommendations for resizing and predicted cost savings.

You can access the Local Disks page by selecting *Settings* in the left navigation, then selecting *Manage local disks*.

![Local Disks](/images/localdisks.png)

You will see a table of all disks in your environment which fall under 20% current usage. For each disk, the table will display its connected cluster, its current utilization, resizing recommendation, and potential savings. Selecting an individual line item will take you offsite to a Grafana dashboard for more metrics relating to that disk.

In the Cluster dropdown, you can filter your table of disks to an individual cluster in your environment.

In the Profile dropdown, you can configure your desired overhead percentage, which refers to the percentage of extra usage you would like applied to each disk in relation to its current usage. The following overhead percentages are:

* Development (25%)
* Production (50%)
* High Availability (100%)

The value of your overhead percentage will affect your resizing recommendation and estimated savings, where a higher overhead percentage will result in higher average resize recommendation, and lower average estimated savings. The overhead percentage is applied to your current usage (in GiB), then added to your usage obtain a  value which Kubecost should round up to for its resizing recommendation. For example, for a disk with a usage of 12 GiB, with _Production (50%)_ selected from the Profile dropdown, 6 GiB (50% of 12) will be added to the usage, resulting in a resizing recommendation of 18 GiB.

Kubecost can only provide detection of underused disks with recommendations for resizing. It does not assist with node turndown.
