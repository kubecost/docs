# Kubecost Cloud: Assets Dashboard

{% hint style="info" %}
This documentation should only be consulted when using Kubecost Cloud! For information about the Assets dashboard for self-hosted Kubecost, see [here](/using-kubecost/navigating-the-kubecost-ui/assets.md).
{% endhint %}

The Kubecost Assets dashboard shows Kubernetes cluster costs broken down by the individual backing assets in your cluster (e.g. cost by node, disk, and other assets). It’s used to identify spend drivers over time and to audit Allocation data. This view can also optionally show out-of-cluster assets by service, tag/label, etc.

## UI overview <a href="#ui-overview" id="ui-overview"></a>

### Date range <a href="#date-range" id="date-range"></a>

You can control the window of allocation spend by selecting _Last 7 days_ (the default option), and choosing the time window you want to view spend for. When using custom dates instead of a preset, select _Apply_ to make changes.

### Aggregate By <a href="#aggregate-by" id="aggregate-by"></a>

Here you can aggregate cost by namespace, deployment, service, and other native Kubernetes concepts. While selecting _Single Aggregation_, you will only be able to categorize by one concept at a time. While selecting _Multi Aggregation_, you will be able to filter for multiple concepts at the same time.

### Edit Report <a href="#edit-report" id="edit-report"></a>

Selecting _Edit Report_ will provide filtering and visualization options.

**Resolution**

Choose one of the following ways to display your query data on the dashboard:

* Daily: Default, displays data as a bar graph with daily steps
* Entire window: Displays all cost data as a semicircle graph with proportionate costs of your aggregate

**Cost metric**

View either cumulative or run rate costs measured over the selected time window based on the resources allocated.

* Cumulative Cost: represents the actual/historical spend captured by the Kubecost agent over the selected time window
* Rate metrics: Monthly, daily, or hourly "run rate" cost, also used for projected cost figures, based on samples in the selected time window

**Filters**

Filter resources by namespace, cluster, and/or Kubernetes label to more closely investigate a rise in spend or key cost drivers at different aggregations such as deployments or pods. When a filter is applied, only resources with this matching value will be shown.Comma-separated lists are supported to filter by multiple values, e.g. label filter equals `kube-system,kubecost`. Wild card filters are also supported, indicated by a `*` following the filter, e.g. `label=kube*` to return any namespace beginning with `kube`.

### Additional options <a href="#additional-options" id="additional-options"></a>

The three horizontal dots icon provides additional means of handling your query data. You can open a saved report or download your query data as a CSV file.
