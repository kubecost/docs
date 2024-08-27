# Advanced Reporting

{% hint style="warning" %}
As of Kubecost v2, Advanced Reports have been removed and replaced with [Collections](/using-kubecost/navigating-the-kubecost-ui/collections.md). See the documentation for more info.
{% endhint %}

Advanced Reporting allows teams to sculpt and tailor custom reports to easily view the information they care about. Providing an intersection between Kubernetes allocation and cloud assets data, this tool provides insight into important cost considerations for both workload and external infrastructure costs.

## Creating an advanced report

Begin by accessing the Reports page. Select _Create a report_, then select _Advanced Report_. The Advanced Reporting page opens.

Advanced Reporting will display your Allocations data and allow for similar configuring and editing. However, that data can now also intersect your cloud service, provider, or accounts.

Some line items will display a magnifying lens icon next to the name. Selecting this icon will provide a Cloud Breakdown which compares Kubernetes costs and out-of-cluster (OOC) costs. You will also see OOC costs broken down by cloud service provider (CSP).

### Configuring a report

The Advanced Reporting page manages the configurations which make up a report. Review the following tools which specify your query:

| Configuration | Description                                                                                   |
| ------------- | --------------------------------------------------------------------------------------------- |
| Date Range    | Manually select your start and end date, or choose a preset option. Default is _Last 7 days_. |
| Aggregate By  | Field by which to aggregate results, such as by _Namespace_, _Cluster_, etc.                  |

{% hint style="info" %}
The _Service_ aggregation in this context refers to a Kubernetes object that exposes an interface to outside consumers, not a CSP feature.
{% endhint %}

### Editing your report

Selecting _Edit_ will open a slide panel with additional configuration options.

#### Filters

When a filter is applied, only results matching that value will display.

#### Shared resources

Field to handle default and custom shared resources (adjusted on the Settings page). Configure custom shared overhead costs, namespaces, and labels

### Saving your report

After completing all configurations for your report, select _Save_. A name for your report based on your configuration will be auto-generated, but you have the option to provide a custom name. Finalize by selecting _Save_.

Reports can be saved via your organization like Allocations and Assets reports, instead of locally.

## Cloud Breakdown

Line items that possess any out-of-cluster (OOC) costs, ie. cloud costs, will display a magnifying lens icon next to their name. Selecting this icon will open a slide panel that compares your K8s and OOC costs.

You can choose to aggregate those OOC costs by selecting the Cloud Breakdown button next to _Aggregate By_ then selecting from one of the available options. You can aggregate by _Provider_, _Service_, _Account_, or use _Custom Data Mapping_ to override default label mappings.
