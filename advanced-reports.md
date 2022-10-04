Advanced Reporting
======

Kubecost Advanced Reporting allows teams to sculpt and tailor custom reports to easily view the information they care about. Providing an intersection between K8s Allocation and Cloud Assets data, this tool provides insight into important cost considerations.


![Kubecost Advanced Reporting UI](https://raw.githubusercontent.com/kubecost/docs/main/images/sample-advanced-report.png)



## Report Configurations

A UI is provided as a means to manage the configurations which make up a report.

| Configuration | Description |
|---------|-----------|
| `Aggregate By` |  Field by which to aggregate Allocation results. `cluster`, `namespace`, etc.|
| `Asset Breakdown` | Field to control how Cloud Asset data is grouped. |
| `Data Source Grouping` | Used to map Asset and Allocation data. Ex: by default, a Allocation `namespace` is mapped to the Asset response via the label `label:kubernetes_namespace`. This field is used to override defaults. |
| `Date Range` | At this time, only a window is provided (`24h`, `48h`, `7d`, `30d`). Custom date ranges will follow in an upcoming release |
| `Sharing` | Field to handle sharing configurations of the Allocation data. |
| `Filters` | Used to filter Allocation information |

## Visual Add-Ons

Add-Ons or Visual Elements are used to enhance your report and provide a high-level view about the information important to you.

> Note: This feature is currently disabled for this release.


Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/advanced-reports.md)


<!--- {"article":"5991192077079","section":"4402815656599","permissiongroup":"1500001277122"} --->
