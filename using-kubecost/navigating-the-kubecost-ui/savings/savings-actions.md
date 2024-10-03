# Actions

The Actions page is where you can create scheduled savings actions that Kubecost will execute for you. The Actions page supports creating actions for multiple turndown and right-sizing features.

{% hint style="info" %}
Actions are only able to be applied to your primary cluster. To use Actions on a secondary cluster (agents), you must login to the UI directly on that cluster.
{% endhint %}

## Enabling Kubecost Actions

### Enable the Cluster Controller

Before you can perform any Actions, you must deploy Kubecost's [Cluster Controller](/install-and-configure/advanced-configuration/controller/cluster-controller.md) to any cluster where Actions are desired. When enabled, Kubecost wil have administrative access to that cluster in order to perform Actions.

{% hint style="warning" %}
Users should exercise caution when enabling this feature. Kubecost will have write access to your cluster (Kubecost is otherwise read-only). The controller can perform irreversible actions. Always ensure you have a backup of your data before enabling this feature.
{% endhint %}

{% hint style="warning" %}
Some features included in Kubecost Actions are only available in GKE/EKS environments. See the Cluster Controller doc for more clarity on which features you will have access to after enabling the Cluster Controller.
{% endhint %}

### Enable experimental features

In order to access experimental Kubecost Actions for Guided Container-Sizing and Cluster Sizing, you must manually enable them. These features are still considered alpha. To access them, you must first go to _Settings_, then toggle on 'Enable experimental features' at the bottom of the page. Select _Save_ to confirm.

## Creating an Action

On the Actions page, select _Create Action_ in the top right. The Create New Action window opens.

You will have the option to perform one of several available Actions:

* Cluster Turndown: Schedule clusters to spin down when unused and back up when needed
* Request Sizing: Ensure your containers aren't over-provisioned
* Namespace Turndown: Schedule unused workloads to spin down
* Guided Sizing: Continuous container and node right-sizing (experimental)
* Cluster Sizing: Configure your cluster in the most cost-effective way (experimental)

Selecting one of these Actions will take you off the Actions page to a Action-specific page which will allow to perform the action in moments.

{% hint style="info" %}
If the Cluster Controller was not properly enabled, the Create New Action window will inform you and limit functionality until the Cluster Controller has been successfully enabled.
{% endhint %}

### Cluster Turndown

Cluster Turndown is a scheduling feature that allows you to reduce costs for clusters when they are not actively being used, without spinning them down completely. This is done by temporarily removing all existing nodes except for master nodes. The Cluster Turndown page allows you to create a schedule for when to turn your cluster down and up again.

Selecting _Cluster Turndown_ from the Create new action window will take you to the Cluster Turndown page. The page should display available clusters for turndown. Begin by selecting _Create Schedule_ next to the cluster you wish to turn down. Select what date and time you wish to turn down the cluster, and what date and time you wish to turn it back up. Select _Apply_ to finalize.

You can delete an existing turndown schedule by selecting the trash can icon.

Learn more about cluster turndown's advanced functionality [here](/install-and-configure/advanced-configuration/controller/cluster-turndown.md).

### Automated Request Sizing

Kubecost offers a condensed version of [Automatic Request Right-Sizing](/using-kubecost/navigating-the-kubecost-ui/savings/container-request-right-sizing-recommendations.md) via Actions, which allows to right-size your deployments on a recurring schedule.

Selecting _Request Sizing_ from the 'Create New Action' window will open the Automated Request Sizing page. Here, you can immediately begin configuring your plan for right-sizing using a schedule and a filtering plan to determine the affected deployments.

#### Schedule

For 'Cadence', select your desired schedule (how often you want Kubecost to right-size your selected deployments), _Daily_, _Weekly_, _Monthly_, or _Quarterly_. Then, select the start date for when you wish your desired cadence to begin occurring.

#### Deployments to right size

Kubecost supports custom filtering for you to specify which deployments you wish to right-size.

Select _Preview_ to view a list of all requests that will be right-sized, and their estimated monthly costs. This list is configurable; you can manually remove individual requests you don't wish to right-size.

#### Configuring recommendations

Finally, you can provide Kubecost with more details about your ideal environment so Kubecost can estimate average resources needed to be allocated:

* Window: Time duration of activity of your deployments to sample. Default is _Last 48h_.
* Profile: Environment profile with preset CPU/RAM recommendations and target utilizations. Includes _Development_, _Production_, and _High Availability_ with preset options, or _Custom_ which will allow you configure subsequent fields manually.
* CPU/RAM recommendation algorithm: Set to _Max_ unless Profile is set to _Custom_. Allows CPU/RAM recommendation algorithms to be separately formatted as a percentile when set to _Percentile_.
* CPU/RAM target utilization: Percentage utilization written as a decimal (for 60% utilization, value should be 0.6). Will keep resource utilization below the provided value. Can only be manually configured when Profile is set to _Custom_.
* CPU/RAM percentile: Only configurable when Profile is set to _Custom_ and their corresponding CPU/RAM recommendation algorithm is configured as _Percentile_.

Select _Save_ to confirm your configuration.

After making changes, the table of deployments should update to show which will be affected. Select _Create Action_ to finalize.

### Cluster Sizing

{% hint style="info" %}
Cluster Sizing is a beta feature.
{% endhint %}

Cluster Sizing will provide right-sizing recommendations for your cluster by determining the cluster's needs based on the type of work running, and the resource requirements. You will receive a simple (uses one node type) and a complex (uses two or more node types) recommendation.

{% hint style="info" %}
Kubecost may hide the complex recommendation when it is more expensive than the simple recommendation, and present a single recommendation instead.
{% endhint %}

Visiting the Cluster Sizing Recommendations page from the Create New Action window will immediately prompt you with a suggested recommendation that will replace your current node pools with the displayed node pools. You can select _Adopt_ to immediately resize, or select _Cancel_ if you want to continue exploring.

Learn more about cluster right-sizing functionality [here](/using-kubecost/navigating-the-kubecost-ui/savings/cluster-right-sizing-recommendations.md).

### Namespace Turndown

Namespace turndown allows you to take action to delete your abandoned workloads. Instead of requiring the user to manually size down or delete their unused workloads, Kubecost can delete namespaces full of idle pods in one moment or on a continual basis. This can be helpful for routine cleanup of neglected resources. Namespace turndown is supported on all cluster types.

{% hint style="warning" %}
When turning down namespaces, Kubecost will perform a `helm uninstall` command to remove the release(s) from the namespace before it is deleted. Take precaution when using this feature to avoid irreversible changes being made to your environment.
{% endhint %}

Selecting _Namespace Turndown_ from the 'Create New Action' window will open the Namespace Turndown page.

Begin by providing a name for your Action in the 'Action Name' field.

For 'Namespace turndown type', select _Scheduled_ or _Smart_ from the dropdown.

* Scheduled turndown will delete all non-ignored namespaces.
* Smart turndown will confirm that all workloads in the namespace are idle before deleting.

'Schedule' determines how often Kubecost will check for unused workloads. It supports _Daily_, _Weekly_, or _Custom_, which will require you to provide a cron string that determines when the turndown occurs (leave this field as `0 0 * * *` by default to perform turndown every night at midnight). Namespaces can have multiple schedules applied to them (but will require separate Actions to be created for them).

Then you can provide optional values for the following fields:

* 'Namespaces to ignore': Filter out namespaces you don't want turned down. Namespace turndown will ignore namespaces named `kube-*`, the `default` namespace, and the namespace the Cluster Controller is enabled on. Allows multiple namespaces to be ignored in one Action. Note that there are, almost certainly, other critical namespaces that should be ignored.
* 'Namespace labels to ignore': Filter out key-value labels that you don't want turned down.

Select _Preview_ to view a list of all namespaces that will be turned down. This list is configurable; you can manually check individual namespaces you wish to be ignored.

Select _Create Action_ to finalize.

### Guided Sizing

{% hint style="info" %}
Guided Sizing is a beta feature.
{% endhint %}

Guided Kubernetes Sizing provides a one-click or continuous right-sizing solution in two steps, request sizing and then cluster sizing. These implementations function exactly like Kubecost's existing [container](/using-kubecost/navigating-the-kubecost-ui/savings/container-request-right-sizing-recommendations.md) and [cluster right-sizing](/using-kubecost/navigating-the-kubecost-ui/savings/cluster-right-sizing-recommendations.md) features.

#### 1. Request Sizing

In the first collapsible tab, you can configure your container request sizing.

* The Auto resizing toggle switch will determine whether you want to perform a one-time resize, or a continuous auto-resize. Default is one-time (off).
* Frequency: Only available when Auto resizing is toggled on. Determines how frequently right-sizing will occur. Options are _Day_, _Week_, _Monthly_, or _Quarterly._
* Start Time: Only available when Auto resizing is toggled on. Determines the day, and time of day, that auto-resizing will begin occurring. Will default to the current date and time if left blank.

Select _Start One-Time Resize/Start Auto-Resizing Now_ to finalize.

#### 2. Cluster Sizing

In the second collapsible tab, you can configure continuous cluster sizing.

* Architecture: Supports _x86_ or _ARM_.
* Target Utilization: How much excess resource nodes should be configured with to account for variable or increasing resource consumption. Default is 0.8.
* Frequency: Determines how frequently right-sizing will occur. Options are _Day_, _Week_, _Monthly_, or _Quarterly._
* Start Time: Determines the day, and time of day, that auto-resizing will begin occurring. Will default to the current date and time if left blank.

Select _Enable Auto-Resizing Now_ to finalize.

## Creating an action via Helm values

You can also optionally configure Actions (except for Guided Sizing) via your Kubecost [values](/install-and-configure/install/helm-install-params.md) file. Configure the following section as needed for any actions you wish to set up (leave unconfigured actions as is). For more information of any action-specific field, see the individual UI configuration sections above for more information.

```yaml
actionConfigs:
  clusterTurndown:
    - name: my-schedule
      start: "2024-02-09T00:00:00Z"
      end: "2024-02-09T12:00:00Z"
      repeat: daily
    - name: my-schedule2
      start: "2024-02-09T00:00:00Z"
      end: "2024-02-09T01:00:00Z"
      repeat: weekly
  namespaceTurndown:
    - name: my-ns-turndown-action
      dryRun: false
      schedule: "0 0 * * *"
      type: Scheduled
      targetObjs:
        - namespace
      keepPatterns:
        - ignorednamespace
      keepLabels:
        turndown: ignore
      params:
        minNamespaceAge: 4h
  clusterRightsize:
    startTime: '2024-01-02T15:04:05Z'
    frequencyMinutes: 1440
    lastCompleted: ''
    recommendationParams:
      window: 48h
      architecture: ''
      targetUtilization: 0.8
      minNodeCount: 1
      allowSharedCore: false
    allowCostIncrease: false
    recommendationType: ''
  containerRightsize:
    workloads:
      - clusterID: cluster-one
        namespace: my-namespace
        controllerKind: deployment
        controllerName: my-controller
    schedule:
      start: "2024-01-30T15:04:05Z"
      frequencyMinutes: 5
      recommendationQueryWindow: "48h"
      lastModified: ''
      targetUtilizationCPU: 0.8
      targetUtilizationMemory: 0.8
```

## Managing Actions

Once you have successfully created an Action, you will see it on the Actions page under Scheduled Actions. Here you will be able to view a Schedule, the Next Run, Affected Workloads, and the Status. You can select _Details_ to view more information about a specific Action, or delete the scheduled Action by selecting the trash can icon.
