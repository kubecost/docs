# Saved Reports

Saved reports can be managed via [`values.yaml`](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml), or via the Kubecost UI, or both. This reference outlines the process of configuring saved reports through a values file, and provides documentation on the required and optional parameters.

## Saved report parameters

The saved report settings, under `global.savedReports`, accept two parameters:

- `enabled` determines whether Kubecost will read saved reports configured via `values.yaml`; default `false`
- `reports` is a list of report parameter maps

The following fields apply to each map item under the `reports` key:

- `title` the title/name of your custom report; any non-empty string is accepted
- `window` the time window the allocation report covers, the following values are supported:
  - key words: `today`, `week` (week-to-date), `month` (month-to-date), `yesterday`, `lastweek`, `lastmonth`
  - number of days: `{N}d` (last **N** days)
    - e.g. `30d` for the last 30 days
  - date range: `{start},{end}` (comma-separated **RFC-3339 date strings** or **unix timestamps**)
    - e.g. `2021-01-01T00:00:00Z,2021-01-02T00:00:00Z` for the single day of 1 January 2021
    - e.g. `1609459200,1609545600` for the single day of 1 January 2021
  - _Note: for all window options, if a window is requested that spans "partial" days, the window will be rounded up to include the nearest full date(s)._
    - e.g. `2021-01-01T15:04:05Z,2021-01-02T20:21:22Z` will return the two full days of 1 January 2021 and 2 January 2021
- `aggregateBy` the desired aggregation parameter -- equivalent to _Breakdown_ in the Kubecost UI. Supports:
  - `cluster`
  - `container`
  - `controller`
  - `controllerKind`
  - `daemonset`
  - `department`
  - `deployment`
  - `environment`
  - `job`
  - `label` requires the following format: `label:<label_name>`
  - `namespace`
  - `node`
  - `owner`
  - `pod`
  - `product`
  - `service`
  - `statefulset`
  - `team`
- `chartDisplay` -- Can be one of `category`, `series`, `efficiency`, `percentage`, or `treemap`. See [Cost Allocation Charts](https://guide.kubecost.com/hc/en-us/articles/4407601807383-Kubernetes-Cost-Allocation#chart) for more info.
- `idle` idle cost allocation, supports `hide`, `shareByNode`, `shareByCluster`, and `separate`
- `accumulate` determines whether or not to sum Allocation costs across the entire window -- equivalent to _Resolution_ in the UI, supports `true` (Entire window resolution) and `false` (Daily resolution)
- `sharedNamespaces` -- a list containing namespaces to share costs for.
- `sharedOverhead` -- an integer representing overhead costs to share.
- `sharedLabels` -- a list of labels to share costs for, requires the following format: `label:<label_name>`
- `filters` -- a list of maps consisting of a property and value
  - `property` -- supports `cluster`, `node`, `namespace`, and `label`
  - `value` -- property value(s) to filter on, supports wildcard filtering with a `*` suffix
    - Special case `label` `value` examples: `app:cost-analyzer`, `app:cost*`
      - Wildcard filters only apply for the label value. e.g., `ap*:cost-analyzer` is not valid
  - _Note: multiple filter properties evaluate as ANDs, multiple filter values evaluate as ORs_
    - _e.g., (namespace=foo,bar), (node=fizz) evaluates as (namespace == foo || namespace == bar) && node=fizz_
  - **Important:** If no filters used, supply an empty list `[]`

## Example Helm values.yaml Saved Reports section

```
   # Set saved report(s) accessible in reports.html
   # View configured saved reports in <front-end-url>/model/reports
  savedReports:
    enabled: true # If true, overwrites report parameters set through UI
    reports:
      - title: "Example Saved Report 0"
        window: "today"
        aggregateBy: "namespace"
        idle: "separate"
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
        idle: "shareByNode"
        accumulate: false
        filters:
          - property: "label"
            value: "app:cost*,environment:kube*"
          - property: "namespace"
            value: "kubecost"
      - title: "Example Saved Report 2"
        window: "2020-11-11T00:00:00Z,2020-12-09T23:59:59Z"
        aggregateBy: "service"
        idle: "hide"
        accumulate: true # entire window resolution
        filters: [] # if no filters, specify empty array

```

## Combining UI report management with `values.yaml`

When defining reports via `values.yaml`, by setting `global.savedReports.enabled = true` in the values file, the reports defined in `values.yaml` are created when the Kubecost pod starts. Reports can still be freely created/deleted via the UI while the pod is running. However, when the pod restarts, whatever is defined the the values file supersedes any UI changes.

Generally, the configmap, if present, serves as the source of truth at startup.

If saved reports are _not_ provided via `values.yaml`, meaning `global.savedReports.enabled = false`, reports created via the UI are saved to a persistent volume, and persist across pod restarts.

## Troubleshooting

Review these steps to verify that saved reports are being passed to the Kubecost application correctly:

1. Confirm that `global.savedReports.enabled` is set to `true`

2. Ensure that the Helm values are successfully read into the configmap

    - Run `helm template ./cost-analyzer -n kubecost > test-saved-reports-config.yaml`
    - Open `test-saved-reports-config`
    - Find the section starting with `# Source: cost-analyzer/templates/cost-analyzer-saved-reports-configmap.yaml`
    - Ensure that the Helm values are successfully read into the configmap under the `data` field. Example below.

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

3. Ensure that the json string is successfully mapped to the appropriate configs

- Navigate to `<front-end-url>/model/reports` and ensure that the configured report parameters have been set by selecting the "Open saved reports" button in the upper right hand corner of the report card.



<!--- {"article":"4407595977879","section":"4402815656599","permissiongroup":"1500001277122"} --->
