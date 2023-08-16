# Cloud Cost Explorer

> **Note**: Cloud Cost is currently in beta. Please read the documentation carefully.

The Cloud Cost Explorer is a dashboard which provides visualizations of your cloud spending.

### Installation and configuration

Cloud Cost will not be available in Kubecost upon fresh install like other similar dashboards. It needs to be enabled first through Helm, using the following parameters:

```
kubecostModel:
  cloudCost:
     enabled: true
     labelList:
       IsIncludeList: false
       # format labels as comma separated string (ex. "label1,label2,label3")
       labels: ""
     topNItems: 1000
```

Enabling Cloud Cost is required. Optional parameters include:

* `labelList.labels`: Comma separated list of labels; empty string indicates that the list is disabled
* `labelList.isIncludeList`: If true, label list is a white list; if false, it is a black list
* `topNItems`: number of sampled "top items" to collect per day

While Cloud Cost is enabled, it is recommended to disable Cloud Usage, which is more memory-intensive.

```
kubecostModel:
  etlCloudUsage: false
```

> **Note**: Disabling Cloud Usage will restrict functionality of your Assets dashboard. Learn more about Cloud Usage [here](https://docs.kubecost.com/install-and-configure/install/cloud-integration#cloud-usage).

### Date range

You can adjust your displayed metrics using the date range feature, represented by _Last 7 days_, the default range. This will control the time range of metrics that appear. Select the date range of the report by setting specific start and end dates, or by using one of the preset options. Select _Apply_ to make changes.

### Aggregate filters

You can adjust your displayed metrics by aggregating your cost by category. Supported fields are _Billing Account_, _Provider_, _Service_, and _Workspace_, as well as custom labels.

### Table metrics

Your cloud cost spending will be displayed across your dashboard with several key metrics:

* Credits:
* K8 Utilization:
* Total cost: Total cloud spending
