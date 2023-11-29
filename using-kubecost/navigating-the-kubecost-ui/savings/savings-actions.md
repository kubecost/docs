# Actions

{% hint style="warning" %}
Actions is currently in beta. Please read the documentation carefully.
{% endhint %}

{% hint style="info" %}
Actions is only available with a Kubecost Enterprise plan.
{% endhint %}

The Actions page is where you can create scheduled savings actions that Kubecost will execute for you. The Actions page supports creating actions for multiple turndown and right-sizing features.

{% hint style="info" %}
Actions are only able to be applied to your primary cluster. To use Actions on a secondary cluster, you must manually switch to that cluster via front end.
{% endhint %}

## Enabling Kubecost Actions

The Actions page will exist inside the Savings folder in the left navigation, but must first be enabled before it appears. The two steps below which enable Kubecost Actions do not need to be performed sequentially as written.

### Step 1. Enable experimental features

Because the Actions page is currently a beta feature, it does not appear as part of Kubecost's base functionality. To enable alpha features, select _Settings_ from the left navigation. Then toggle on the _Enable experimental features_ switch. Select _Save_ at the bottom of the Settings page to confirm your changes. The Actions page will now appear in your left navigation, but you will not be able to perform any actions until you've enabled the Cluster Controller (see below).

### Step 2. Enable the Cluster Controller

Write access to your cluster is also required to access Kubecost Actions. To enable the Cluster Controller, see our [Cluster Controller](https://docs.kubecost.com/install-and-configure/advanced-configuration/controller) doc for full instructions. Once you have completed this, you should have full accessibility.

{% hint style="warning" %}
Some features included in Kubecost Actions are only available in GKE/EKS environments. See the Cluster Controller doc for more clarity on which features you will have access to after enabling the Cluster Controller.
{% endhint %}

## Creating an Action

On the Actions page, select _Create Action_ in the top right. The Create New Action window opens.

You will have the option to perform one of several available Actions:

* Cluster Turndown: Schedule clusters to spin down when unused and back up when needed&#x20;
* Request Sizing: Ensure your containers aren't over-provisioned
* Cluster Sizing: Configure your cluster in the most cost-effective way
* Namespace Turndown: Schedule unused workloads to spin down
* Guided Sizing: Continuous container and node right-sizing

Selecting one of these Actions will take you off the Actions page to a Action-specific page which will allow to perform the action in moments.

{% hint style="info" %}
If the Cluster Controller was not properly enabled, the Create New Action window will inform you and limit functionality until the Cluster Controller has been successfully enabled.
{% endhint %}

### Cluster Turndown

Cluster Turndown is a scheduling feature that allows you to reduce costs for clusters when they are not actively being used, without spinning them down completely. This is done by temporarily removing all existing nodes except for master nodes. The Cluster Turndown page allows you to create a schedule for when to turn your cluster down and up again.

Selecting _Cluster Turndown_ from the Create new action window will take you to the Cluster Turndown page. The page should display available clusters for turndown. Begin by selecting _Create Schedule_ next to the cluster you wish to turn down. Select what date and time you wish to turn down the cluster, and what date and time you wish to turn it back up. Select _Apply_ to finalize.

You can delete an existing turndown schedule by selecting the trash can icon.

Learn more about cluster turndown's advanced functionality [here](/install-and-configure/advanced-configuration/controller/cluster-turndown.md).

### Request Sizing

See the existing documentation on [Automatic Request Right-Sizing](/using-kubecost/navigating-the-kubecost-ui/savings/container-request-right-sizing-recommendations.md) to learn more about this feature. If you have successfully enabled the Cluster Controller, you can skip the Setup section of that article.

### Cluster Sizing

Cluster Sizing will provide right-sizing recommendations for your cluster by determining the cluster's needs based on the type of work running, and the resource requirements. You will receive a simple (uses one node type) and a complex (uses two or more node types) recommendation.

{% hint style="info" %}
Kubecost may hide the complex recommendation when it is more expensive than the simple recommendation, and present a single recommendation instead.
{% endhint %}

Visiting the Cluster Sizing Recommendations page from the Create New Action window will immediately prompt you with a suggested recommendation that will replace your current node pools with the displayed node pools. You can select _Adopt_ to immediately resize, or select _Cancel_ if you want to continue exploring.

Learn more about cluster right-sizing functionality [here](/using-kubecost/navigating-the-kubecost-ui/savings/cluster-right-sizing-recommendations.md).

### Namespace Turndown

Namespace turndown allows you to take action to delete your abandoned workloads. Instead of requiring the user to manually size down or delete their unused workloads, Kubecost can delete namespaces full of idle pods in one moment or on a continual basis. This can be helpful for routine cleanup of neglected resources. Namespace turndown is supported on all cluster types.&#x20;

Selecting _Namespace Turndown_ from the Create new action window will open the Namespace Turndown page.

Begin by providing a name for your Action in the Job Name field. For the schedule, provide a cron string that determines when the turndown occurs (leave this field as `0 0 * * *` by default to perform turndown every night at midnight).

For schedule type, select _Scheduled_ or _Smart_ from the dropdown.

* Scheduled turndown will delete all non-ignored namespaces.
* Smart turndown will confirm that all workloads in the namespace are idle before deleting.

Then you can provide optional values for the following fields:

* Ignore Targets: Filter out namespaces you don't want turned down. Supports "wildcard" filtering: by ending your filter with `*`, you can filter for multiple namespaces which include that filter. For example, entering `kube*` will prevent any namespace featuring `kube` from being turned down. Namespace turndown will ignore namespaces named `kube-*`, the `default` namespace, and the namespace the Cluster Controller is enabled on.
* Ignore labels: Filter out key-alue labels that you don't want turned down.

Select _Create Schedule_ to finalize.

### Guided Sizing

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

## Managing Actions

Once you have successfully created an Action, you will see it on the Actions page under Scheduled Actions. Here you will be able to view a Schedule, the Next Run, Affected Workloads, and the Status. You can select _Details_ to view more information about a specific Action, or delete the scheduled Action by selecting the trash can icon.
