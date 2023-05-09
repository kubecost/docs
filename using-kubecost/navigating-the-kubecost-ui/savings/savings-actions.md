# Savings Actions

{% hint style="warning" %}
The Actions page is currently in alpha. Please read the documentation carefully.
{% endhint %}

The Actions page is where you can create scheduled savings actions which Kubecost will execute for you. The Actions page currently supports creating actions for cluster turndown, request sizing, and cluster sizing.

## Enabling Kubecost Actions

The Actions page will exist inside the Savings folder in the left navigation, but must first be enabled before it appears. The two steps below which enable Kubecost Actions do not need to be performed sequentially as written.

### Step 1. Enable alpha features

Because the Actions page is currently an alpha feature, it does not appear as part of Kubecost's base functionality. To enable alpha features, select _Settings_ from the left navigation. Then toggle on the _Enable alpha features_ switch. Select _Save_ at the bottom of the Settings page to confirm your changes. The Actions page will now appear in your left navigation, but you will not be able to perform any actions until you've enabled the Cluster Controller (see below).

### Step 2. Enable the Cluster Controller

Write access to your cluster is also required to access Kubecost Actions. To enable the Cluster Controller, see our [Cluster Controller](https://docs.kubecost.com/install-and-configure/advanced-configuration/controller) doc for full instructions. Once you have completed this, you should have full accessibility.

{% hint style="warning" %}
Some features included in Kubecost Actions are only available in GKE/EKS environments. See the Cluster Controller doc for more clarity on which features you will have access to after enabling the Cluster Controller.
{% endhint %}

## Creating an Action

On the Actions page, select _Create Action_ in the top right. The Create New Action window opens.

You will have the option to perform one of several available Actions:

* Cluster Turndown: Schedule clusters to spin up or down
* Request Sizing: Ensure your containers aren't over provisioned
* Cluster Sizing: Configure your cluster in the most cost effective way

<figure><img src="../../../.gitbook/assets/image (2).png" alt=""><figcaption></figcaption></figure>

Selecting one of these Actions will take you off the Actions page to a Action-specific page which will allow to perform the action in moments.

{% hint style="info" %}
If the Cluster Controller was not properly enabled, the Create New Action window will inform you and limit functionality until the Cluster Controller has been successfully enabled.
{% endhint %}

### Cluster Turndown

Cluster Turndown is a scheduling feature which allows you to reduce costs for clusters when they are not actively being used, without spinning them down completely. This is done by temporarily removing all existing nodes except for master nodes. The Cluster Turndown page allows you to create a schedule for when to turn your cluster down and up again.

Selecting _Cluster Turndown_ from the Create New Action window will take you to the Cluster Turndown page. The page should display available clusters for turndown. Begin by selecting _Create Schedule_ next to the cluster you wish to turndown. Select what date and time you wish to turndown the cluster, and what date and time you wish to turn it back up. Select _Apply_ to finalize.

You can delete an existing turndown schedule by selecting the trash can icon.

Learn more about cluster turndown's advanced functionality [here](https://docs.kubecost.com/install-and-configure/advanced-configuration/controller/cluster-turndown).

### Request Sizing

See the existing documentation on [Automatic Request Right-Sizing](https://docs.kubecost.com/using-kubecost/navigating-the-kubecost-ui/savings/auto-request-sizing) to learn more about this feature. If you have successfully enabled the Cluster Controller, you can skip the Setup section of this article.

### Cluster Sizing

Cluster Sizing will provide right-sizing recommendations for your cluster by determining the cluster's needs based on type of work running, and the resource requirements. You will receive a simple (uses one node type) and a complex (uses two or more node types) recommendation.

{% hint style="info" %}
Kubecost may hide the complex recommendation when it is more expensive than the simple recommendation, and present a single recommendation instead.
{% endhint %}

Visiting the Cluster Sizing Recommendations page from the Create New Action window will immediately prompt you with a suggested recommendation which will replace your current node pools with the displayed node pools. You can select _Adopt_ to immediately resize, or select _Cancel_ if you want to continue exploring.
