# Savings

The Savings page provides miscellaneous functionality to help you use resources more effectively and assess wasteful spending. In the center of the page, you will see your estimated monthly savings available. The savings value is calculated from all enabled Savings features, across your clusters and the designated cluster profile via dropdowns in the top right of the page. The total estimated monthly savings shown is ~60% of the sum of all cards to avoid overlap. In some cases, savings totals in cards such as Right-size container requests can be higher than the total estimated monthly savings due to how total estimated monthly savings is calculated.

![The Savings page](/images/savings.png)

## Savings insights

The Savings page provides an array of panels containing different insights capable of lowering your Kubernetes and cloud spend.

The monthly savings values on this page are precomputed every hour for performance reasons, while per-cluster views of these numbers, and the numbers on each individual Savings insight page, are computed live. This may result in some discrepancies between estimated savings values of the Savings page and the pages of individual Savings insights.

### Kubernetes insights

* [Right-size your cluster nodes](cluster-right-sizing-recommendations.md)
* [Right-size your container requests](container-request-right-sizing-recommendations.md)
* [Remedy abandoned workloads](abandoned-workloads.md)
* [Manage unclaimed volumes](unclaimed-volumes.md)
* [Manage local disks](local-disks.md)
* [Manage underutilized nodes](underutilized-nodes.md)
* [Right-size your persistent volumes](pv-right-sizing-rec.md)

### Cloud insights:

* Reserve instances
* [Manage orphaned resources](orphaned-resources.md)
* [Spot Instances](spot-checklist.md)

## Archiving Savings insights

You can archive individual Savings insights if you feel they are not helpful, or you cannot perform those functions within your organization or team. Archived Savings insights will not add to your estimated monthly savings available.

To temporarily archive a Savings insight, select the three horizontal dots icon inside its panel, then select _Archive._ You can unarchive an insight by selecting _Unarchive_.

You can also adjust your insight panels display by selecting _View_. From the _View_ dropdown, you have the option to filter your insight panels by archived or unarchived insights. This allows you to effectively hide specific Savings insights after archiving them. Archived panels will appear grayed out, or disappear depending on your current filter.

## Single cluster insights

By default, the Savings page and any displayed metrics (For example, estimated monthly savings available) will apply to all connected clusters. You can view metrics and insights for a single cluster by selecting it from the dropdown in the top right of the Savings page.

{% hint style="warning" %}
Functionality for most cloud insight features only exists when _All Clusters_ is selected in the cluster dropdown. Individual clusters will usually only have access to Kubernetes insight features.
{% endhint %}

## Cluster profiles

On the Savings page, as well as on certain individual Savings insights, you have the ability to designate a cluster profile. Savings recommendations such as right-sizing are calculated in part based on your current cluster profile:

* Production: Expects stable cluster activity, will provide some extra space for potential spikes in activity.
* Development: Cluster can tolerate small amount of instability, will run cluster somewhat close to capacity.
* High availability: Cluster should avoid instability at all costs, will size cluster with lots of extra space to account for unexpected spikes in activity.

The different cluster profile types and their corresponding CPU/RAM utilizations are:

| Cluster profile | CPU/RAM target utilization |
|---|---|
| High availability | 50% |
| Production | 65% |
| Development | 80% |

Cluster profile can be configured for your *values.yaml* as well, via the flag `kubecostProductConfigs.clusterProfile`, which can be set at to any of the following values: `development`, `production` or `high-availability`.
