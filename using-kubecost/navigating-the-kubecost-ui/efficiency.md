# Efficiency Report

Efficiency Report is a Monitoring dashboard which provides workload and infra idle costs for your clusters. Metrics include consumption cost of individual CPU/RAM/storage metrics, and total workload efficiency.

Efficiency Report supports clusters by all major cloud service providers, and on-prem clusters.

![Efficiency Report](/images/efficiency.png)

## Understanding efficiency and idle cost metrics

Efficiency Report breaks down idle costs into two distinct categories:

* *Workload idle* refers to the cost associated with hardware resources (CPU/GPU/RAM) that are requested by the workloads, but are not consumed on average.
* *Infra idle* refers to the cost associated with purchased hardware resources that are neither requested nor consumed.

These metrics, when compared to total spend, are necessary when calculating efficiency. Workload efficiency can be calculated as:

> ((resources consumed/resources requested) * 100)

For more information about efficiency and idle metrics, see our [Efficiency and Idle](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/efficiency-idle.md) doc.

## Configuring your query

### Date Range

Select the date range of the report by setting specific start and end dates, or using one of the preset options.

### Aggregate By

Here you can aggregate your results by categories determined by your selected [idle](efficiency.md#idle).

* When *Idle by Type* or *Resource idle by cluster* is selected, your options are *Cluster* or *Node*.
* When *Resource idle by workload* is selected, your options include all available [Allocations](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/README.md#aggregate-by) aggregate options, including Single and Multi Aggregation.

Hovering your cursor over individual graph items will display a legend breaking down each color with the cost of the resource associated with it. The sum of all cost metrics in your window will equal the Total Cost metric displayed in the below table.

### Filters

Filter your results at the cluster or node level, where only matching resources will be displayed. Supports advanced filtering options as well.

### Idle

One of the most important tools for configuring your query is the idle dropdown. Here, you can choose which idle costs to display, but this will also affect the reported cost metrics in the Efficiency Report table:

* *Idle by type*: Will display table columns for both workload idle and infra idle, and provides cluster efficiency percentage
* *Resource idle by workload*: Categorizes your total workload idle cost across CPU/RAM/storage and breaks these costs down by workload
* *Resource idle by cluster*: Categorizes your total infra idle cost across CPU/RAM and breaks these costs down by cluster.

For blanket workload and infra idle costs, you can leave the default *Idle by type* selected. However, if you need a breakdown of idle costs by resource type (CPU/RAM/storage), select one of the other options from the dropdown.
