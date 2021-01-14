# Alerts Documentation

### Summary

Kubecost alerts allow teams to receive updates on real-time Kubernetes spend. They are configurable via Helm values. This resource gives an overview of how to configure Kubecost email and Slack alerts using [Kubecost helm chart values](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml).
  

As of v1.72.0, Kubecost supports three types of alerts:

 1. Recurring update
   
   - Weekly (all namespaces) -- sends an email and Slack alert reporting cluster spend across all namespaces, with costs broken down by namespace
     - Required parameters:
       - `type: recurringUpdate`
       - `aggregation: namespace`
       - `filter: '*'`
       - `window: 7d`
   - Weekly (by namespace) -- sends an email and Slack alert reporting individual namespace spend, identified by `filter`
     - Required parameters:
       - `type: recurringUpdate`
       - `aggregation: namespace`
       - `filter: <value>` -- configurable, accepts a single namespace name (comma separated values unsupported)
       - `window: 7d`

 2. Budget -- sends an email and Slack alert reporting spend
     - Required parameters:
       - `type: budget`
       - `threshold: <amount>` -- configurable, cost threshold in configured currency units
       - `aggregation: <agg-parameter>` -- configurable, accepts all aggregations supported by the [aggregated cost model API](https://github.com/kubecost/docs/blob/2ea9021e8530369d53184ea5382b2e4c080bb426/allocation-api.md#aggregated-cost-model-api)
       - `filter: <value>` -- configurable, accepts a single filter value
       - `window: <N>d` or `<M>h` -- configurable, (1 ≤ N ≤ 7, 1 ≤ M ≤ 24)

 3. Spend Change -- sends an email and Slack alert reporting deviations in cost
     - Required parameters:
       - `type: spendChange`
       - `relativeThreshold: <N>` -- configurable, N ≥ -1
       - `aggregation: <agg-value>` -- configurable
       - `filter: <value` -- configurable, accepts a single filter value
       - `window: <N>d` or `<M>h` -- configurable, (1 ≤ N ≤ 7, 1 ≤ M ≤ 24)
       - `baselineWindow: <N>d` -- configurable, N ≥ 1
  
### Configuring Alerts in Helm  
  
The alert settings, under `global.notifications.alertConfigs`, accept four global fields and a list of individual alerts to configure:

* `enabled` determines whether Kubecost will schedule alerts, default set to `false`     
* `frontendUrl` optional, your cost analyzer front end URL used for alert linkbacks
* `globalSlackWebhookUrl` optional, a global Slack webhook used for alerts, enabled by default if provided
* `globalAlertEmails` a global list of emails for alerts
    
The following fields apply to each item under the `alerts` block:

* `type` supported: `recurringUpdate`, `budget`, `spendChange`
* `threshold` required for budget alerts
* `relativeThreshold` required for spendChange alerts, the relative amount spend must exceed the baseline spend by in order to trigger
* `window` time window the alert covers, supports `1d`, `daily`, `7d`, and `weekly` settings depending on the type of alert described above
* `baselineWindow` required for spendChange alerts, the baseline window from which baseline average hourly cost is calculated
* `aggregation` aggregation parameter, supports namespace or cluster	    
* `filter` aggregation value to filter on
  * special character `*` signifies all namespaces for recurringUpdate
* `ownerContact` optional list of alert-level owner contact emails, default to `globalAlertEmails` if missing
* `slackWebhookUrl` optional alert-level Slack webhook, default to `globalSlackWebhookUrl` if missing

### Example Helm values.yaml

*Note: `values.yaml` is a source of truth. Alerts set through `values.yaml` will continually overwrite any manual alert settings set through the Kubecost UI.*

```
notifications:
	alertConfigs:
		enabled: true  # the example values below are never read unless enabled is set to true
		frontendUrl: http://localhost:9090  # optional, used for linkbacks
		slackWebhookUrl: https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX  # optional, used for Slack alerts
		globalAlertEmails:
			- recipient@example.com
			- additionalRecipient@example.com
		alerts:
				# Daily namespace budget alert on namespace `kubecost`
			- type: budget  # supported: budget, recurringUpdate
				threshold: 50  # optional, required for budget alerts
				window: daily  # or 1d
				aggregation: namespace
				filter: kubecost
				ownerContact: # optional, overrides globalAlertEmails default
					- owner@example.com
					- owner2@example.com
				# Daily cluster budget alert (clusterCosts alert) on cluster `cluster-one`
			- type: budget
				threshold: 200.8  # optional, required for budget alerts
				window: daily  # or 1d
				aggregation: cluster
				filter: cluster-one
				# Recurring weekly update (weeklyUpdate alert)
			- type: recurringUpdate
				window: weekly  # or 7d
				aggregation: namespace
				filter: '*'
				# Recurring weekly namespace update on kubecost namespace
			- type: recurringUpdate
				window: weekly  # or 7d
				aggregation: namespace
				filter: kubecost
				ownerContact: # ownerContact(s) should be the same for the same namespace, otherwise the last namespace alert overwrites
					- owner@example.com
					- owner2@example.com
			- type: spendChange  # change relative to moving avg
			  relativeThreshold: 0.20  # Proportional change relative to baseline. Must be greater than -1 (can be negative).
			  window: 1d                # accepts ‘d’, ‘h’
			  baselineWindow: 30d       # previous window, offset by window
			  aggregation: namespace
			  filter: kubecost, default # accepts csv
```

### Troubleshooting

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
	alerts.json: '{"alerts":[{"aggregation":"namespace","filter":"kubecost","ownerContact":"calvin+2@kubecost.com","threshold":0.1,"type":"budget","window":"1d"},{"aggregation":"cluster","filter":"cluster-one","threshold":0.1,"type":"budget","window":"1d"},{"aggregation":"namespace","filter":"*","type":"recurringUpdate","window":"7d"},{"aggregation":"namespace","filter":"kubecost","ownerContact":"calvin+2@kubecost.com","type":"recurringUpdate","window":"7d"}],"enabled":true,"frontendUrl":"http://35.239.230.16:9090","globalAlertEmails":["calvin@kubecost.com"],"slackWebhookUrl":"https://hooks.slack.com/services/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"}'
```

-   Ensure that the json string is successfully mapped to the appropriate configs

Next, confirm that Kubecost product has received configuration data:

- Visit `<your-kubecost-url>/model/getCustomAlertDiagnostics` to view next and last runs for alerting
