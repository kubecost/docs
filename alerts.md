# Alerts Documentation

### Summary

Kubecost alerts allow teams to receive updates on real-time Kubernetes spend. They are configurable via the Kubecost UI, and now via Helm values. This resource gives an overview of how to configure Kubecost email and Slack alerts using [Kubecost helm chart values](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml).
  

Kubecost currently supports four different types of alerts:

 1. Recurring update, weekly (all namespaces)
	 - Sends an email to the configured global email(s) reporting cluster spend across all namespaces, broken down by namespace

 2. Recurring update, weekly by namespace
	 - Sends an email to the configured owner contact email, defaulting to global emails if not provided, reporting individual namespace spend, identified by `filter`

 3. Daily budget alert by cluster

	 - Sends an email and Slack alert to global email(s) and Slack webhook (if configured), reporting daily total cluster spend

 4. Daily budget alert by namespace

	 - Sends an email and Slack alert to the configured owner contact, defaulting to global emails if not provided, reporting daily total namespace spend, identified by `filter`
  
### Alerts Parameters  
  
The alert settings, under `notifications.alertConfigs`, accept four global fields and a list of individual alerts to configure:

* `enabled` determines whether Kubecost will read alerts configured via `values.yaml`, default set to `false`     
* `frontendUrl` optional, your cost analyzer front end URL used for alert linkbacks (applies to all alerts)
* `slackWebhookUrl` optional, a Slack webhook used for daily cluster and namespace budget alerts, enabled by default if provided
* `globalAlertEmails` a list of emails for alerts
    
The following fields apply to each item under the `alerts` block:

* `type` supported: budget, recurringUpdate	    
* `threshold` required for budget alerts, optional for recurring update alerts	    
* `window` time window the alert covers, supports `1d`, `daily`, `7d`, and `weekly` settings depending on the type of alert described above
* `aggregation` aggregation parameter, supports namespace or cluster	    
* `filter` aggregation value to filter on. Given the available aggregation parameters, it is the namespace name, cluster name, or `’*’` (when using the namespace aggregation parameter) to signify inclusion of all namespaces	    
* `ownerContact` optional list of owner contact emails for namespace alerts, default to global emails if missing

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

- Navigate to your Kubecost UI `/notify.html` as well as the respective `namespace.html?name=<namespace-name>` pages to see that the configured alerts are enabled, budgets are set, and email(s) are set.
