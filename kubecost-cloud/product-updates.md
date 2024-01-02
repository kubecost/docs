# Kubecost Cloud Product Updates

## 12/21/23

### New Features:
* Cluster Status Alerts: get notified when a Kubecost Cloud agent stops reporting
* New filtering options added on the Allocations page: Department/Environment/Owner/Product/Team. Filtering by any of the properties listed above is equivalent to filtering by the following allocation label names: “department”, “env”, “owner”, “app”, “team”. The label names are not customizable at the moment.

### Bug Fixes:
* Fixed issue where Cloud Cost reports could not be created directly from the Reports page
* Fixed issue where Allocation aggregation by Service would not return the expected results
* Fixed issue where Allocation aggregation by Department/Environment/Owner/Product/Team would not return the expected results. The aggregation options listed above will now aggregate by the following allocation label names: “department”, “env”, “owner”, “app”, “team”. The label names are not customizable at the moment.

## 12/8/23

### New features:

* Alerts page
    * Get alerted when there is a significant change in your spending
* Auto-send reports
    * Schedule .csv or .pdf reports directly to your email
* Support for OpenShift Clusters

### Bug fixes:

* Fixed issue where applying multiple filters in the Cloud Cost Explorer Page resulted in only the last filter being applied
* Fixed issue where an error with one of the savings insights would block access to the entire Savings page
* Fixed issue where Cloud Cost Reports with certain properties could not be saved correctly
* Fixed issue where Azure non-compute cloud items were not returned on the Cloud Cost Explorer page
* Fixed issue where the Assets page would fail to load due to NaN costs
