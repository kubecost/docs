# Resize Local Disks

Kubecost displays all local disks it detects with low usage, with recommendations for resizing and predicted cost savings.

You can access the Local Disks page by selecting *Settings* in the left navigation, then selecting *Manage local disks*.

![Local Disks](/images/localdisks.png)

You will see a table of all local disks in your environment which meet the selected threshold for maximum usage. For each disk, the table will display its connected cluster, its current utilization, resizing recommendation, and potential savings. Selecting an individual line item will take you offsite to a Grafana dashboard for more metrics relating to that disk.

In the Cluster dropdown, you can filter your table of disks to a singular cluster in your environment.

In the Profile dropdown, you can configure your desired overhead…

Kubecost can only provide detection of underused disks with recommendations for resizing. It does not assist with node turndown.
