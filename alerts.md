Alerts
======

Kubecost alerts allow teams to receive updates on real-time Kubernetes spend. They are configurable via the Kubecost UI or via Helm values. This resource gives an overview of how to configure Kubecost email and Slack alerts using [Kubecost helm chart values](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml).
  

## Alert Types

 1. [Recurring update](#type-recurring-update) - sends an email and/or Slack alert with cluster spend across all or a set of namespaces, with costs broken down by namespace

 2. [Budget](#type-budget) -- sends an email and/or Slack alert when spend crosses a defined threshold

 3. [Spend Change](#type-spend-change) -- sends an email and/or Slack alert reporting unexpected spend increases relative to moving averages

 4. [Beta] [Efficiency](#type-efficiency) -- detect when a Kubernetes tenant is operating below a target cost efficiency threshold

 5. [Kubecost Health Diagnostic](#type-kubecost-health-diagnostic) -- used for production monitoring for the health of Kubecost itself
 
 6. [Cluster Health](#type-cluster-health) -- used to determine if the cluster's health score changes by a specific threshold.

Have questions or issues? View our [troubleshooting guide](#troubleshooting).
  
## Configuring Alerts in Helm

*Note: Configuring Alerts from the helm chart will set the configuration in `values.yaml` as the source of truth. Alerts set through `values.yaml` will continually overwrite any manual alert settings set through the Kubecost UI.* 

### Global Alert Parameters  
The alert settings, under `global.notifications.alertConfigs` in `cost-analyzer/values.yaml`, accept four global fields:

* `frontendUrl` optional, your cost analyzer front end URL used for linkbacks in alert bodies
* `globalSlackWebhookUrl` optional, a global Slack webhook used for alerts, enabled by default if provided
* `globalAlertEmails` a global list of emails for alerts

Example Helm values.yaml: 

```
notifications:
	alertConfigs:
		frontendUrl: http://localhost:9090  # optional, used for linkbacks
		globalSlackWebhookUrl: https://hooks.slack.com/services/T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX  # optional, used for Slack alerts
		globalAlertEmails:
			- recipient@example.com
			- additionalRecipient@example.com
		alerts:
		# list of individual alerts
		...
```

## Configuring Each Alert Type

In addition to `globalSlackWebhookUrl` and `globalAlertEmails` fields, every alert allows optional individual `ownerContact` (a list of email addresses) and `slackWebhookUrl` (if different from `globalSlackWebhookUrl`) fields. Alerts will default to the global Slack and email settings if these optional fields are not supplied.

### Type: Recurring Update

Sends an recurring email and/or Slack alert with a summary report of cost and efficiency metrics. 

Required parameters:

- `type: recurringUpdate`
- `aggregation: <aggregation>` -- configurable, accepts a single valid aggregation parameter\*
- `filter: '*'`
- `window: <N>d` -- configurable, N ≥ 1

**Valid Aggregation Parameters**: 
- `cluster`
- `container`
- `controller`
- `namespace`
- `pod`
- `service`
- `deployment`
- `daemonset`
- `statefulset`
- `job`
- `label` requires the following format: `label:<label_name>`
- `annotation` requires the following format: `annotation:<annotation_name>`

Required parameters (by individual namespace):

- `type: recurringUpdate`
- `aggregation: namespace`
- `filter: <value>` -- configurable, accepts a single namespace name (comma separated values unsupported)
- `window: 7d`

Example Helm values.yaml:

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

### Type: Efficiency 

> Note: this feature is currently in Beta

Alert when Kubernetes tenants, e.g. namespaces or label sets, are running below defined cost efficiency thresholds.

Required parameters:

- `type: efficiency`
- `efficiencyThreshold: <threshold>` -- efficiency threshold ranging from 0.0 to 1.0
- `aggregation: <agg-parameter>` -- configurable, accepts all aggregations supported by the [aggregated cost model API](https://github.com/kubecost/docs/blob/main/allocation-api.md#aggregated-cost-model-api)
- `window: <N>d` number of days for measuring efficiency

Optional paremeters:
- `filter: <value>` -- limit the aggregations that this alert will cover, accepts comma separated values
- `spendThreshold` represents a minimal spend threshold for alerting

The example below sends a Slack alert when any namespace spending is running below 40% cost efficiency and has spent more than $100 during the last one day. 

```
- type: efficiency
	efficiencyThreshold: 0.4  # Alert if below this percentage cost efficiency
	spendThreshold: 100 # optional, alert if tenant has spend more than $100 over this window
	window: 1d    # measure efficiency over last 
	aggregation: namespace
	slackWebhookUrl: ‘https://hooks.slack.com/services/TE6GRBNET/BFFK0P848/jFWmsadgfjhiBJp30p’ # optional, overrides global Slack webhook 
```

### Type: Budget

Define spend budgets and alert on budget overruns.

Required parameters:

- `type: budget`
- `threshold: <amount>` -- cost threshold in configured currency units
- `aggregation: <agg-parameter>` -- configurable, accepts all aggregations supported by the [aggregated cost model API](https://github.com/kubecost/docs/blob/main/allocation-api.md#aggregated-cost-model-api)
- `filter: <value>` -- configurable, accepts a single filter value (comma separated values unsupported)
- `window: <N>d` or `<M>h` -- configurable, (1 ≤ N ≤ 7, 1 ≤ M ≤ 24)

Example Helm values.yaml:

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

### Type: Spend Change

Detect unexpected spend increases/decreases relative to historical moving averages.

Required parameters:

- `type: spendChange`
- `relativeThreshold: <N>` -- configurable, N ≥ -1
- `aggregation: <agg-value>` -- configurable, accepts all aggregations supported by the [aggregated cost model API](https://github.comhttps://github.com/kubecost/docs/blob/main/allocation-api.md#aggregated-cost-model-api)
- `window: <N>d` or `<M>h` -- configurable, (1 ≤ N ≤ 7, 1 ≤ M ≤ 24)
- `baselineWindow: <N>d` -- configurable, N ≥ 1

Optional parameters:

- `filter: <value>` -- limit the aggregations that this alert will cover, accepts comma separated values

Example Helm values.yaml:

```
			# Daily spend change alert on the 
			- type: spendChange
			  relativeThreshold: 0.20  # change relative to baseline average cost. Must be greater than -1 (can be negative).
			  window: 1d                # accepts ‘d’, ‘h’
			  baselineWindow: 30d       # previous window, offset by window
			  aggregation: namespace
			  filter: kubecost, default # accepts csv
```

### Type: Kubecost Health Diagnostic

Enabling diagnostic alerts in Kubecost occur when an event impacts product uptime. This feature can be enabled in seconds from a values file. The following health events are detected:

* Prometheus is unreachable
* Kubecost metrics missing over last 5 minutes
* More coming soon.

This alert only only uses Slack (email coming soon), so it requires the `globalSlackWebhookUrl` field.

Example Helm values.yaml:
```
        # Kubecost Health Diagnostic
        - type: diagnostic
          window: 10m
 ```

*Versions Earlier than 1.79.0*

This alert used to be configured via the `notifications.alertConfigs.kubecostHealth` flag seen [here](https://github.com/kubecost/cost-analyzer-helm-chart/blob/31dc60d2c539720f2b2a72c8e22b2f6b866580bd/cost-analyzer/values.yaml#L31). If upgrading to version 1.79.0 or newer, remove the `kubecostHealth` flag, and append the alert definition shown above. 


### Type: Cluster Health

Cluster health alerts occur when the cluster health score changes by a specific threshold. The health score is calculated based on the following criteria:

* Low Cluster Memory
* Low Cluster CPU
* Too Many Pods
* Crash Looping Pods
* Out of Memory Pods
* Failed Jobs

This alert only only uses Slack (email coming soon), so it requires the `globalSlackWebhookUrl` field. 

Example Helm values.yaml:

```
        # Health Score Alert 
        - type: health              # Alerts when health score changes by a threshold
          window: 10m
          threshold: 5              # Send Alert if health scores changes by 5 or more
```

## Alerts Scheduler

All times in UTC.

Alert send times are determined by parsing the supplied `window` parameter. The running alert status containing `nextRun` and `lastRun` metadata can be viewed via the endpoint: `<your-kubecost-url>/model/alerts/status`.

Supported: `weekly` and `daily` special cases, `<N>d`, `<M>h` (1 ≤ N ≤ 7, 1 ≤ M ≤ 24)
Currently Unsupported: time zone adjustments, windows greater than `7d`, windows less than `1h`

### Scheduler Behavior

An `<N>d` alert sends at 00:00 UTC N day(s) from now, i.e., N days from now rounded down to midnight. 

For example, a `5d` alert scheduled on Monday will send on Saturday at 00:00, and subsequently the next Thursday at 00:00

An `<N>h` alert sends at the earliest time of day after now that is a multiple of N.

For example, a `6h` alert scheduled at any time between 12pm and 6pm will send next at 6pm and subsequently at 12am the next day.

If 24 is not divisible by the hourly window, schedule at next multiple of `<N>h` after now, starting from current day at 00:00.

For example, a `7h` alert scheduled at 22:00 checks 00:00, 7:00, 14:00, and 21:00, before arriving at a next send time of 4:00 tomorrow.


## Troubleshooting
Review these steps to verify alerts are being passed to the Kubecost application correctly.

### Configuration from UI
If alerts are not configured from `values.yaml`, then they are persisted on the container attached disk (PV or ephemeral disk). This method should only be used on a single replica deployment. To continue troubleshooting, skip ahead to the [Scheduling](#Scheduling) section. 


### Configuration via Helm
First, ensure that the Helm values are successfully read into the configmap:

-   Confirm that the `global.notifications.alertConfigs` contains a valid configuration.
-   Run `kubectl get configmap alert-configs -n kubecost -o json` to view alerts configmap.
-   Ensure that the Helm values are successfully read into the `ConfigMap` as `alerts.json` under the `data` field.
-   Example:

```
{
    "apiVersion": "v1",
	"kind": "ConfigMap",
	"metadata": {
		"name": "alert-configs",
        "namespace": "kubecost",
        "annotations": {
            "meta.helm.sh/release-name": "kubecost",
            "meta.helm.sh/release-namespace": "kubecost"
        },
        "labels": {
            "app": "cost-analyzer",
            "app.kubernetes.io/instance": "kubecost-stage",
            "app.kubernetes.io/managed-by": "Helm",
	    ...
        },
	...
    }
    "data": {
        "alerts.json": "{\"alerts\":[{\"aggregation\":\"namespace\",\"efficiencyThreshold\":0.4,\"spendThreshold\":1,\"type\":\"efficiency\",\"window\":\"1d\"}],\"frontendUrl\":\"http://localhost:9090\",\"globalAlertEmails\":[\"recipient@example.com\"],\"globalSlackWebhookUrl\":\"https://hooks.slack.com/services/TE6RTBNET/BFFK0P848/jFWms48dnxlk4BBPiBJp30p\"}"
    },
}

```

-   Ensure that the json string is successfully mapped to the appropriate configs

Next, confirm that Kubecost product has received configuration data:

- Go to `<your-kubecost-url>/alerts.html` in the Kubecost UI to view all configured alerts settings.
- If you did not use `values.yaml` to configure your alerts, you can begin that configuration from the `alerts.html` page. 

### Scheduling
If alerts that you expect to trigger are failing to do so, you may need to investigate when the configured alerts have been internally scheduled to execute condition checks. You can get this information by navigating to `<your-kubecost-url>/model/alerts/status` which will list all alerts which are currently scheduled to run with attached status metadata:
- *id*: The unique identifier for the scheduled alert.
- *scheduledOn*: When the scheduler received the configuration and created the live alert.
- *lastRun*: When the alert conditional checks ran last.
- *nextRun*: When the alert conditional checks have been scheduled to run next.
- *lastError*: If an alert conditional triggered an unexpected error during it's last run, this field will be set to that error. Absense of this field indicates no error.

When investigating the status for potential error cases:
- Confirm that all configured alerts have a status. 
- Confirm that `lastRun` and `nextRun` times correctly schedule the execution of the alert conditional checks.
- Confirm that the `lastError` field doesn't exist for any of the alerts. 

### Common Errors 
Common causes of misconfiguration include the following:
- unsupported csv filters -- `spendChange` alerts accept `filter` as comma-separated values; other alert types do not.
- unsupported alert type -- all alert type names are in camelCase -- check spelling and capitalization for all alert parameters
- unsupported aggregation parameters -- see the [aggregated cost model API](https://github.com/kubecost/docs/blob/2ea9021e8530369d53184ea5382b2e4c080bb426/allocation-api.md#aggregated-cost-model-api) for details

### Unexpected Errors
If you have exhausted the previous steps, our pod's logging will emit specific warning and error messages pertaining to alert configuration and scheduling. These logs can be retrieved via a bug report from the frontend Settings, or via `kubectl`:
```bash
$ kubectl logs $(kubectl get pods -n kubecost | awk '{print $1}' | grep "^kubecost-cost-analyzer.\{16\}") -n kubecost -c cost-model > kubecost-logs.txt
```

## Alerts API
The backend API available to support Alerts is available to interface with the current set of scheduled alerts in kubecost. The payloads required to add/update new alerts follow the parameter sets from the configuration specification. The endpoints are available on the `/model` prefix, and are as follows:

The new Alerts API makes available the following new endpoints:
| Method    | Path           | Description |
| --------- | -------------- | ----------- |
| `GET`     | `/alerts`      | Returns an array of all running alert instances `[]AlertPayload` |
| `POST`    | `/alerts`      | Accepts a request body containing a single `AlertPayload`. If the payloadf contains an ID, the alert with the ID is updated. Otherwise, a new Alert is created. The result of the Add or Update is returned on the response. |
| `DELETE`  | `/alerts/{id}` | Removes the alert with the id provided in the path |

To configure the specific global configuration values for all alerts, the following endpoints are available:
| Method    | Path               | Description |
| --------- | ------------------ | ------------ |
| `GET`     | `/alerts/linkback` | Returns a `LinkbackPayload` payload instance contains the global alert `frontendUrl` configuration. |
| `POST`    | `/alerts/linkback` | Sets the `LinkbackPayload` payload to set the global alert `frontendUrl` configuration. |
| `GET`     | `/alerts/slack`    | Returns a `SlackWebhookPayload` payload instance contains the alert `globalSlackWebhookUrl` configuration. |
| `POST`    | `/alerts/slack`    | Sets the `SlackWebhookPayload` payload to set the alert `globalSlackWebhookUrl` configuration. |
| `GET`     | `/alerts/email`    | Returns a `EmailPayload` payload instance contains the alert `globalAlertEmails` configuration. |
| `POST`    | `/alerts/email`    | Sets the `EmailPayload` payload to set the alert `globalAlertEmails` configuration. |

The request and response payload specifications are as follows:
### AlertPayload
The contents of the `AlertPayload` is based on what type of alert you are adding or updating. The payload contents are identical to the configuration specification for each alert type. The `required` field in the table below denote the alert type requirements. 

| Field                 | Required      | Type       | Description  |
| --------------------- | ------------- | ---------- | ------------ |
| `type`                | `all`         | `string`   | The `AlertType` of the alert to create described in configuration spec. |
| `window`              | `all`         | `string`   | The scheduling parameter described in configuration spec. |
| `aggregation`         | `all`         | `string`   | See aggregation constraints per alert type |
| `filter`              | `all`         | `string`   | See filter constraints per alert type |
| `ID`                  | `optional`    | `string`   | Passing the identifier in a request indicates you'd like to update an existing alert's parameters |
| `ownerContact`        | `optional`    | `[]string` | Overrides the global alerts `globalAlertEmails` for a specific alert |
| `slackWebhookUrl`     | `optional`    | `string`   | Overrides the global alerts `globalSlackWebhookUrl` for a specific alert |
| `threshold`           | `budget`      | `float64`  | Used to set the alert threshold for `budget` alert types |
| `baselineWindow`      | `spendChange` | `string`   | The baseline window used to compare the `window` to for determining spend change. |
| `relativeThreshold`   | `spendChange` | `float64`  | The relative threshold to trigger the alert when comparing window and baseWindow hourly spend |
| `efficiencyThreshold` | `efficiency`  | `float64`  | Efficiency threshold between 0.0 and 1.0 |
| `spendThreshold`      | `efficiency`  | `float64`  | The baseline spend threshold that must be reached before checking efficiency |

### LinkbackPayload
The contents of the `LinkbackPayload` is simply a `frontendUrl`.
| Field                 | Required | Type       | Description  |
| --------------------- | -------- | ---------- | ------------ |
| `frontendUrl`         | ✔️       | `string`   | The global alert `frontendUrl` configuration used when issuing alert linkbacks. |

### SlackWebhookPayload
The contents of the `SlackWebhookPayload` is simply a `webhookUrl`.
| Field                 | Required | Type       | Description  |
| --------------------- | -------- | ---------- | ------------ |
| `webhookUrl`          | ✔️       | `string`   | The global alert `webhookUrl` configuration used when issuing slack alerts. |

### EmailPayload
The contents of the `EmailPayload` is simply an array of email addresses.
| Field                 | Required | Type        | Description  |
| --------------------- | -------- | ----------- | ------------ |
| `recipients`          | ✔️       | `[]string` | The global alert `globalAlertEmails` configuration used when issuing email alerts. |


Have questions? Join our [Slack community](https://join.slack.com/t/kubecost/shared_invite/enQtNTA2MjQ1NDUyODE5LWFjYzIzNWE4MDkzMmUyZGU4NjkwMzMyMjIyM2E0NGNmYjExZjBiNjk1YzY5ZDI0ZTNhZDg4NjlkMGRkYzFlZTU) or contact us via email at [team@kubecost.com](team@kubecost.com)!

Edit this doc on [Github](https://github.com/kubecost/docs/blob/main/alerts.md)

<!--- {"article":"4407601796759","section":"4402815656599","permissiongroup":"1500001277122"} --->