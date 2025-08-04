# Cloud Installation and Onboarding

This doc will show you how to register for Kubecost Cloud, invite members to and manage your team(s), and create and remove clusters.

## Accessing Kubecost Cloud

### Creating a user account

You can create a new user account in moments. On the [login page](http://app.kubecost.com), provide a Name, Email, and Password to register. You can also register using an active Google, Microsoft, Okta, or GitHub account via SSO.

## **Managing teams**

You can access information about your team by selecting _Settings_ from the left navigation. You should see all teams you either own or are a member of. Here you will be able to create a team, manage existing members, and invite new members.

Begin by selecting _Create Team_. You will be prompted to choose a name for your team, then you can immediately begin inviting others to join.

### Creating an invitation

In the row of the team you’d like to create an invite for, select _Invite Members_. Then, add your team member’s email to the Invite Member box, then select _Invite_.

There is currently no limit to the number of members that can be added to a team.

### Accepting an invitation

Invitations to join are sent out via email. To join a team, you must follow the invitation link and register for Kubecost Cloud (see above). Once logged in, you will see a banner at the top of your page which will allow you to officially join the team. You can also accept an invite on the Settings page under Manage Teams.

### Editing your team

When you select _Invite Member_, the Edit Team window appears. Here, you can see a list of all active members, as well as emails with pending invitations. You can remove members and cancel outgoing invitations. Members will not be alerted when they are removed from a team.

If you are a member of multiple teams, you will see a green checkmark icon next to the team you are currently viewing cost data for. You can switch teams by selecting _Switch_ next to the team name, or by selecting _Switch Team_ in the lower left navigation.

## Managing clusters

### Adding a cluster

#### Install prerequisites

* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* [Helm v3.1+](https://helm.sh/docs/intro/quickstart/)

#### Agent install

If no clusters are currently under management, you will find instructions on the Allocations page for installing the Kubecost Agent on your cluster. You can also find these instructions in _Settings_ > _Add Cluster_.

Choose a unique ID for your cluster. This does not need to be the same name as your cluster, but it does need to be unique within your team.

Execute the following command to install the Kubecost Cloud agent to your cluster. The agent key will be pre-populated in the install command in the Kubecost Cloud UI.

{% hint style="info" %} Using an existing Prometheus deployment is not currently supported. {% endhint %}

{% code overflow="wrap" %}

```bash
helm upgrade --install kubecost-cloud \
--repo https://kubecost.github.io/kubecost-cloud-agent/ kubecost-cloud-agent \
--namespace kubecost-cloud --create-namespace \
-f https://raw.githubusercontent.com/kubecost/kubecost-cloud-agent/main/values-cloud-agent.yaml \
--set imageVersion="lunar-sandwich.v0.1.2" \
--set cloudAgentKey="AGENTKEY" \
--set cloudAgentClusterId="cluster-1" \
--set cloudReportingServer="collector.app.kubecost.com:31357" \
--set networkCosts.enabled=true
```

{% endcode %}

After 5-10 minutes, you should see your cluster connected. Data should automatically begin appearing in your Allocations and Assets dashboards.

You can view your connected clusters in the Settings page under Manage Clusters, which will display the unique ID, Provider, and Agent version.

### Removing a cluster

Remove the agent from the cluster to stop reporting new metrics to Kubecost Cloud.&#x20;

Example based on default Helm install command:

```bash
export release=kubecost-cloud
export namespace=kubecost-cloud
helm uninstall ${release} --namespace ${namespace}
```

If you modified the Helm release name or namespace, you will need to update the command accordingly.

After five minutes of no longer receiving data, the cluster will disappear from Manage Clusters. Any data previously received will be available for the remainder of the retention period.

## Troubleshooting

### GKE Autopilot rejects Kubecost Cloud agent

When attempting to install the Kubecost Cloud agent on a [GKE Autopilot](https://cloud.google.com/kubernetes-engine/docs/concepts/autopilot-overview) cluster, you may receive an error related to the network costs daemonSet:

{% code overflow="wrap" %}

```console
Error: admission webhook "
gkepolicy.common-webhooks.networking.gke.io
" denied the request: GKE Warden rejected the request because it violates one or more constraints.
```

{% endcode %}

To work around this problem, modify your install command to disable the network costs daemonSet. That setting change will look like this:

```text
--set networkCosts.enabled=false
```

Without network costs installed, you will be missing visibility into the networking layer in your environment. Kubecost is actively working with GCP to get our agent added to [this list of autopilot partner workloads](https://cloud.google.com/kubernetes-engine/docs/resources/autopilot-partners).
