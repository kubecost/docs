# Alerts Documentation

## Summary

Kubecost alerts allow teams to receive updates on real-time Kubernetes spend. They are configurable via the Kubecost UI or via Helm values. This resource gives an overview of how to configure Kubecost email and Slack alerts using [Kubecost helm chart values](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml).
  

As of v1.72.0, Kubecost supports three types of alerts:

 1. Recurring update
   
   - Weekly (all namespaces) -- sends an email and Slack alert reporting cluster spend across all namespaces, with costs broken down by namespace
   - Weekly (by namespace) -- sends an email and Slack alert reporting individual namespace spend, identified by `filter`

 2. Budget -- sends an email and Slack alert reporting spend by aggregation and filter value

 3. Spend Change -- sends an email and Slack alert reporting increases in average hourly spend beyond a threshold relative to baseline average hourly spend, where baseline window is a timespan prior to the current window
  
## Configuring Alerts in Helm 

*Note: `values.yaml` is a source of truth. Alerts set through `values.yaml` will continually overwrite any manual alert settings set through the Kubecost UI.* 

### Global Alert Parameters  
The alert settings, under `global.notifications.alertConfigs` in `cost-analyzer/values.yaml`, accept four global fields:

* `enabled` determines whether Kubecost will schedule and display the configured alerts in Notifications, default set to `false`     
* `frontendUrl` optional, your cost analyzer front end URL used for linkbacks in alert bodies
* `globalSlackWebhookUrl` optional, a global Slack webhook used for alerts, enabled by default if provided
* `globalAlertEmails` a global list of emails for alerts

#### Example Helm values.yaml

```
notifications:
	alertConfigs:
		enabled: true # the settings under alertConfigs are never scheduled unless enabled is set to true
		frontendUrl: http://localhost:9090  # optional, used for linkbacks
		globalSlackWebhookUrl: https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX  # optional, used for Slack alerts
		globalAlertEmails:
			- recipient@example.com
			- additionalRecipient@example.com
		alerts:
		# list of individual alerts
		...
```

### Configuring Each Alert Type

In addition to `globalSlackWebhookUrl` and `globalAlertEmails` fields, every alert allows optional individual `ownerContact` (a list of email addresses) and `slackWebhookUrl` (if different from `globalSlackWebhookUrl`) fields. Alerts will default to the global Slack and email settings if these optional fields are not supplied.

#### Type: Recurring Update

Required parameters (all namespaces):

- `type: recurringUpdate`
- `aggregation: namespace`
- `filter: '*'`
- `window: 7d`

Required parameters (by individual namespace):

- `type: recurringUpdate`
- `aggregation: namespace`
- `filter: <value>` -- configurable, accepts a single namespace name (comma separated values unsupported)
- `window: 7d`

#### Example Helm values.yaml

```
			# Recurring weekly namespace update on all namespaces
			- type: recurringUpdate
				window: weekly  # or 7d
				aggregation: namespace
				filter: '*'
			# Recurring weekly namespace update on kubecost namespace
			- type: recurringUpdate
				window: weekly  # or 7d
				aggregation: namespace
				filter: kubecost
				ownerContact: # optional, overrides globalAlertEmails default
					- owner@example.com
					- owner2@example.com
				slackWebhookUrl: https://hooks.slack.com/services/<different-from-global> # optional, overrides globalSlackWebhookUrl default
```

#### Type: Budget

Required parameters:

- `type: budget`
- `threshold: <amount>` -- cost threshold in configured currency units
- `aggregation: <agg-parameter>` -- configurable, accepts all aggregations supported by the [aggregated cost model API](https://github.com/kubecost/docs/blob/2ea9021e8530369d53184ea5382b2e4c080bb426/allocation-api.md#aggregated-cost-model-api)
- `filter: <value>` -- configurable, accepts a single filter value (comma separated values unsupported)
- `window: <N>d` or `<M>h` -- configurable, (1 ≤ N ≤ 7, 1 ≤ M ≤ 24)

#### Example Helm values.yaml

```
			# Daily namespace budget alert on namespace `kubecost`
			- type: budget
				threshold: 50
				window: daily # or 1d
				aggregation: namespace
				filter: kubecost
			# 3d cluster budget alert on cluster `cluster-one`
			- type: budget
				threshold: 600
				window: 3d
				aggregation: cluster
				filter: cluster-one
```

#### Type: Spend Change

Required parameters:

- `type: spendChange`
- `relativeThreshold: <N>` -- configurable, N ≥ -1
- `aggregation: <agg-value>` -- configurable, accepts all aggregations supported by the [aggregated cost model API](https://github.com/kubecost/docs/blob/2ea9021e8530369d53184ea5382b2e4c080bb426/allocation-api.md#aggregated-cost-model-api)
- `filter: <value>` -- configurable, **accepts comma separated values**
- `window: <N>d` or `<M>h` -- configurable, (1 ≤ N ≤ 7, 1 ≤ M ≤ 24)
- `baselineWindow: <N>d` -- configurable, N ≥ 1

### Example Helm values.yaml

```
			# Daily spend change alert on the 
			- type: spendChange
			  relativeThreshold: 0.20  # change relative to baseline average cost. Must be greater than -1 (can be negative).
			  window: 1d                # accepts ‘d’, ‘h’
			  baselineWindow: 30d       # previous window, offset by window
			  aggregation: namespace
			  filter: kubecost, default # accepts csv
```

## Troubleshooting

Review these steps to verify alerts are being passed to the Kubecost application correctly.

First, ensure that the Helm values are successfully read into the configmap:

-   Confirm that the `global.notifications.alertConfigs.enabled` field is set to `true`
-   Run `helm template ./cost-analyzer -n kubecost > test-alert-config.yaml`
-   Open `test-alert-config.yaml`
-   Find the section starting with `# Source: cost-analyzer/templates/cost-analyzer-alerts-configmap.yaml`
-   Ensure that the Helm values are successfully read into the configmap under the `data` field.
-   Example:

```
# Source: cost-analyzer/templates/cost-analyzer-alerts-configmap.yaml
apiVersion: v1
kind: ConfigMap
metadata:
name: alert-configs
labels:
	app.kubernetes.io/name: cost-analyzer
	helm.sh/chart: cost-analyzer-1.68.1
	app.kubernetes.io/instance: RELEASE-NAME
	app.kubernetes.io/managed-by: Helm
app: cost-analyzer
data:
	alerts.json: <all-fields-and-values-under-alertConfigs-as-json-string>
```

-   Ensure that the json string is successfully mapped to the appropriate configs

Next, confirm that Kubecost product has received configuration data:

- Visit `<your-kubecost-url>/model/getCustomAlertDiagnostics` to view configuration settings as well as next and last scheduled run times for individual alerts
