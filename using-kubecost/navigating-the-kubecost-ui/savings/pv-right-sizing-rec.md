# Persistent Volume Right-Sizing Recommendations

Kubecost is able to provide recommendations for resizing your PVs by comparing their average usage to their maximum capacity, and can recommend sizing down to smaller storage sizes.

To access the Persistent Volume Right-Sizing Recommendations page, select *Savings* from the left navigation, then select *Right-size persistent volumes*.

![Table](/images/rightsizingpv.png)

Kubecost will display a table containing all PVs in your environment. Table columns include the PV name and its corresponding cluster, and metrics pertaining usage and savings. The estimated savings per month per table item is calculated by subtracting your recommended cost from the current cost.

You can filter your table of PVs using the Cluster dropdown to view PVs in an individual cluster, or across all connected clusters.

## Calculating recommendations

You can filter your list of persistent volumes by selecting _Add Filters_, then providing your desired cluster or label values.

You can also adjust Kubecost’s average recommended capacity size using the Profile dropdown, which establishes how much minimum excess capacity you will for every PV, using their local usage data from the past six hours. The percentage value associated with each Profile is the minimum unused capacity required per PV, which is then added to the max usage to obtain Kubecost’s recommendation. Recommended capacity is calculated as (max usage + (max usage * overhead percentage)) in GiB. This is then converted to GB and rounded to the nearest tenth when displayed in the UI (A capacity of 1 GiB will be converted to 1.1 GB). Max Usage is also converted in this way from GiB to GB. The smallest denomination Kubecost will recommend per PV is 1.1 GB. From here, the recommended capacity increases in intervals of 1 GiB. The higher the minimum excess capacity needed, the higher the average recommended capacity, and therefore the lower the average savings.

For example, for a PV with a max usage of 2 GiB, and a selected Production Profile (which requires 50% excess capacity), the overhead will be calculated as 2 * .5, then added to the max usage, resulting in a minimum recommended capacity of 3 GiB. This will then be converted to approximately 3.2 GB for the final recommendation.

Kubecost does not directly assist with resizing your PVs.
