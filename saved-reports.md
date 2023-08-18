# Reports

Reports are saved queries from your various Monitoring dashboards which can be referenced at a later date for convenience. Aggregation, filters, and other details of your query will be saved in the report, and the report can be opened at any time. Reports are currently supported by the Allocations, Assets, and Cloud Cost Explorer dashboards.

Reports can be managed via [_values.yaml_](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) or the Kubecost UI. This reference outlines the process of configuring saved reports through a values file, and provides documentation on the required and optional parameters.

<figure><img src=".gitbook/assets/savedreports.PNG" alt=""><figcaption><p>Reports page</p></figcaption></figure>

## Managing reports via UI

### Creating a report

Begin by selecting _Create a report_. There are five report types available. Three of these correspond to Kubecost's different monitoring dashboards. The other two are specialized beta features.

* Allocation Report
* Asset Report
* [Advanced Report](https://docs.kubecost.com/using-kubecost/getting-started/advanced-reports) (beta)
* Cloud Cost Report
* [Advanced Report - Cost Centers](https://docs.kubecost.com/using-kubecost/navigating-the-kubecost-ui/saved-reports/cost-center-report) (beta)

Selecting a monitoring report type will take you to the respective dashboard. Provide the details of the query, then select _Save_. The report will now be saved on your Reports page for easy access.

For help creating an Advanced Report (either type), select the respective hyperlink above for a step-by-step process.

### Sharing reports

After creating a report, you are able to share that report in recurring intervals via email as a PDF or CSV file. Shared reports replicate your saved query parameters every interval so you can view cost changes over time.

{% hint style="info" %}
Sharing reports is only available for Allocations, Assets, and Cloud Cost Reports, not either type of Advanced Report.
{% endhint %}

In the line for the report you want to share, select the three horizontal dots icon in the Actions column. Select _Share report_ from the menu. The Share Report window opens. Provide the following fields:

* Interval: Interval that recurring reports will be sent out. Supports _Daily_, _Weekly_, and _Monthly_. Weekly reports default to going out Sunday at midnight. Monthly reports default to midnight on the first of the month. When selecting _Monthly_ and resetting on a day of the month not found in every month, the report will reset at the latest available day of that month. For example, if you choose to reset on the 31st, it will reset on the 30th for months with only 30 days.
* Format: Supports _PDF_ or _CSV_.
* Add email: Email(s) to distribute the report to.

Select _Apply_ to finalize. When you have created a schedule for your report, the selected interval will be displayed in the Interval column of your Reports page.

## Managing reports via _values.yaml_

The saved report settings, under `global.savedReports`, accept two parameters:

* `enabled` determines whether Kubecost will read saved reports configured via _values.yaml_; default value is `false`
* `reports` is a list of report parameter maps

The following fields apply to each map item under the `reports` key:

* `title` the title/name of your custom report; any non-empty string is accepted
* `window` the time window the allocation report covers, the following values are supported:
  * keywords: `today`, `week` (week-to-date), `month` (month-to-date), `yesterday`, `lastweek`, `lastmonth`
  * number of days: `{N}d` (last N days)
    * e.g. `30d` for the last 30 days
  * date range: `{start},{end}` (comma-separated RFC-3339 date strings or Unix timestamps)
    * e.g. `2021-01-01T00:00:00Z,2021-01-02T00:00:00Z` for the single day of 1 January 2021
    * e.g. `1609459200,1609545600` for the single day of 1 January 2021
  * _Note: for all window options, if a window is requested that spans "partial" days, the window will be rounded up to include the nearest full date(s)._
    * e.g. `2021-01-01T15:04:05Z,2021-01-02T20:21:22Z` will return the two full days of 1 January 2021 and 2 January 2021
* `aggregateBy` the desired aggregation parameter -- equivalent to _Breakdown_ in the Kubecost UI. Supports:
  * `cluster`
  * `container`
  * `controller`
  * `controllerKind`
  * `daemonset`
  * `department`
  * `deployment`
  * `environment`
  * `job`
  * `label` requires the following format: `label:<label_name>`
  * `namespace`
  * `node`
  * `owner`
  * `pod`
  * `product`
  * `service`
  * `statefulset`
  * `team`
* `chartDisplay` -- Can be one of `category`, `series`, `efficiency`, `percentage`, or `treemap`. See [Cost Allocation Charts](using-kubecost/navigating-the-kubecost-ui/cost-allocation/#chart) for more info.
* `idle` idle cost allocation, supports `hide`, `shareByNode`, `shareByCluster`, and `separate`
* `rate` -- Can be one of `cumulative`, `monthly`, `daily`, `hourly`
* `accumulate` determines whether or not to sum Allocation costs across the entire window -- equivalent to _Resolution_ in the UI, supports `true` (Entire window resolution) and `false` (Daily resolution)
* `sharedNamespaces` -- a list containing namespaces to share costs for.
* `sharedOverhead` -- an integer representing overhead costs to share.
* `sharedLabels` -- a list of labels to share costs for, requires the following format: `label:<label_name>`
* `filters` -- a list of maps consisting of a property and value
  * `property` -- supports `cluster`, `node`, `namespace`, and `label`
  * `value` -- property value(s) to filter on, supports wildcard filtering with a `*` suffix
    * Special case `label` `value` examples: `app:cost-analyzer`, `app:cost*`
      * Wildcard filters only apply for the label value. e.g., `ap*:cost-analyzer` is not valid
  * _Note: multiple filter properties evaluate as ANDs, multiple filter values evaluate as ORs_
    * _e.g., (namespace=foo,bar), (node=fizz) evaluates as (namespace == foo || namespace == bar) && node=fizz_
  * **Important:** If no filters used, supply an empty list `[]`

## Example Helm _values.yaml_ Saved Reports section

{% code overflow="wrap" %}
```
   # Set saved report(s) accessible in reports.html
   # View configured saved reports in <front-end-url>/model/reports
  savedReports:
    enabled: true # If true, overwrites report parameters set through UI
    reports:
      - title: "Example Saved Report 0"
        window: "today"
        aggregateBy: "namespace"
        chartDisplay: "category"
        idle: "separate"
        rate: "cumulative"
        accumulate: false # daily resolution
        sharedNamespaces:
          - monitoring
          - kube-system
        filters:
          - property: "cluster"
            value: "cluster-one,cluster*" # supports wildcard filtering and multiple comma separated values
          - property: "namespace"
            value: "kubecost"
      - title: "Example Saved Report 1"
        window: "month"
        aggregateBy: "controllerKind"
        chartDisplay: "category"
        idle: "shareByNode"
        rate: "monthly"
        accumulate: false
        filters:
          - property: "label"
            value: "app:cost*,environment:kube*"
          - property: "namespace"
            value: "kubecost"
      - title: "Example Saved Report 2"
        window: "2020-11-11T00:00:00Z,2020-12-09T23:59:59Z"
        aggregateBy: "service"
        chartDisplay: "category"
        idle: "hide"
        rate: "daily"
        accumulate: true # entire window resolution
        filters: [] # if no filters, specify empty array
```
{% endcode %}

## Combining UI report management with _values.yaml_

When defining reports via _values.yaml_, by setting `global.savedReports.enabled = true` in the values file, the reports defined in _values.yaml_ are created when the Kubecost pod starts. Reports can still be freely created/deleted via the UI while the pod is running. However, when the pod restarts, whatever is defined the values file supersedes any UI changes.

Generally, the ConfigMap, if present, serves as the source of truth at startup.

If saved reports are _not_ provided via _values.yaml_, meaning `global.savedReports.enabled = false`, reports created via the UI are saved to a persistent volume and persist across pod restarts.

## Troubleshooting

Review these steps to verify that saved reports are being passed to the Kubecost application correctly:

1. Confirm that `global.savedReports.enabled` is set to `true`
2.  Ensure that the Helm values are successfully read into the ConfigMap

    * Run `helm template ./cost-analyzer -n kubecost > test-saved-reports-config.yaml`
    * Open `test-saved-reports-config`
    * Find the section starting with `# Source: cost-analyzer/templates/cost-analyzer-saved-reports-configmap.yaml`
    * Ensure that the Helm values are successfully read into the ConfigMap under the `data` field. Example below.

    {% code overflow="wrap" %}
    ```
    # Source: cost-analyzer/templates/cost-analyzer-saved-reports-configmap.yaml
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: saved-report-configs
      labels:

        app.kubernetes.io/name: cost-analyzer
        helm.sh/chart: cost-analyzer-1.70.0
        app.kubernetes.io/instance: RELEASE-NAME
        app.kubernetes.io/managed-by: Helm
        app: cost-analyzer
    data:
      saved-reports.json: '[{"accumulate":false,"aggregateBy":"namespace","filters":[{"property":"cluster","value":"cluster-one,cluster*"},{"property":"namespace","value":"kubecost"}],"idle":"separate","title":"Example Saved Report 0","window":"today"},{"accumulate":false,"aggregateBy":"controllerKind","filters":[{"property":"label","value":"app:cost*,environment:kube*"},{"property":"namespace","value":"kubecost"}],"idle":"shareByNode","title":"Example Saved Report 1","window":"month"},{"accumulate":true,"aggregateBy":"service","filters":[],"idle":"hide","title":"Example Saved Report 2","window":"2020-11-11T00:00:00Z,2020-12-09T23:59:59Z"}]'# Source: cost-analyzer/templates/cost-analyzer-alerts-configmap.yaml
    ```
    {% endcode %}
3. Ensure that the JSON string is successfully mapped to the appropriate configs

Navigate to your Reports page in the Kubecost UI and ensure that the configured report parameters have been set by selecting the Report name.
