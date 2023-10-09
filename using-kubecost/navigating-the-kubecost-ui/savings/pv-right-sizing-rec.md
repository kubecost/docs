# Persistent Volume Right-Sizing Recommendations

Kubecost is able to provide recommendations for resizing your PVs by comparing their average usage to their maximum capacity, and can recommend sizing down to smaller storage sizes.

To access the Persistent Volume Right-Sizing Recommendations page, select *Settings* from the left navigation, then select *Right-size persistent volumes*.

![Table](/images/rightsizingpv.png)

Kubecost will display a table containing all PVs in your environment. Table columns include the PV name and its corresponding cluster, and metrics pertaining usage and savings. The estimated savings per month per table item is calculated by subtracting your recommended cost from the current cost.

Recommendations appear in multiple denominations, rounded up. The smallest denomination Kubecost will recommend per PV is 1.1 GB. From here, the recommended capacity increases in intervals of 1 GB.

You are able to filter your table of PVs using the Cluster dropdown to view all PVs in an individual cluster.

You are able to adjust Kubecost’s average recommended capacity size using the Profile dropdown, which establishes how much minimum excess capacity you will need across all PVs, using their local usage data from the past six hours. The percentage value associated with each Profile is the minimum unused capacity required per PV, which is then added to the max usage to obtain Kubecost’s recommendation. Recommended capacity is calculated as (max usage + (max usage * overhead percentage)), then rounded up to the nearest capacity increment.

For example, for a PV with a max usage of 2 GB, and a selected Production Profile (which requires 50% overhead), the overhead will be calculated as 2 * .5, then added to the max usage, resulting in a minimum recommended capacity of 3 GB. This should then be rounded up to 3.1 GB for the final recommendation.
Kubecost does not directly assist with resizing your PVs.
