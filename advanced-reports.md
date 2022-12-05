# Advanced Reporting

Kubecost Advanced Reporting allows teams to sculpt and tailor custom reports to easily view the information they care about. Providing an intersection between K8s Allocation and Cloud Assets data, this tool provides insight into important cost considerations.

<figure><img src=".gitbook/assets/advancedreporting.PNG" alt=""><figcaption></figcaption></figure>

## Report Configurations

A UI is provided to manage the configurations which make up a report.

| Configuration                    | Description                                                                                                                                                                    |
| -------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| Date Range (Last 7 days)         | Will report _Last 7 days_ by default. Manually select your start and end date, or pick one of twelve preset options.                                                           |
| Aggregate By                     | Field by which to aggregate Allocation results. `cluster`, `namespace`, etc.                                                                                                   |
| Cloud Breakdown                  | Filter by `Provider`, `Service`, `Account`, or use _Custom Data Mapping_ to override default label mappings                                                                    |
| Edit Report                      | Opens window with additional options for configuring report, including filters and shared resources                                                                            |
| Filters                          | Accessed in _Edit Report_. Used to filter Allocation information                                                                                                               |
| Shared resources                 | Accessed in _Edit Report_. Field to handle default and custom shared resources (adjusted on the Settings page). Configure custom shared overhead costs, namespaces, and labels |
| External Cost Breakdown/eye icon | Compare K8s costs with out-of-cluster (OOC) costs                                                                                                                              |

## Visual Add-Ons

Add-Ons or Visual Elements are used to enhance your report and provide a high-level view about the information important to you.

> Note: This feature is currently disabled for this release.
