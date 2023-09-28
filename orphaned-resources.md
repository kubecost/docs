# Orphaned Resources

Kubecost displays all disks and IP addresses that are not utilized by any cluster. These may still incur charges, and so you should consider these orphaned resources for deletion.

You can access the Orphaned Resources page by selecting *Savings* in the left navigation, then selecting *Manage orphaned resources*.

![Orphaned Resources](/images/orphanedresources.png)

Disks and IP addresses (collectively referred to as resources) will be displayed in a single table. Selecting an individual line item will expand its tab and provide more metrics about the resource, including cost per month, size (disks only), region, and a description of the resource.

You can filter your table of resources using two dropdowns:

* The Resource dropdown will allow you to filter by resource type (*Disk* or *IP Address*).
* The Region dropdown will filter by the region associated with the resource. Resources with the region “Global” cannot be filtered, and will only display when *All* has been selected.

Above your table will be an estimated monthly savings value. This value is the sum of all displayed resources’ savings. As you filter your table of resources, this value will naturally adjust.

For cross-functional convenience, you can copy the name of any resource by selecting the copy icon next to it.
