# Navigating the Kubecost UI

This grouping of docs explains how to navigate the Kubecost UI. The UI is composed of several primary dashboards which provide cost visualization, as well as multiple savings and governance tools. Below is the main Overview page, which contains several helpful panels for observing workload stats and trends. Individual pages have their own dedicated documentation for explaining all features which can be interacted with, as well as how they work.

![Kubecost overview](/images/overview.png)

To obtain access to the Kubecost UI following a successful installation, enable port-forwarding with the following command:

```
kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090
```

You can now access the UI by visiting `http://localhost:9090` in your web browser.

## Monitor

In the left navigation, you will see a section called *Monitor*, which comprises multiple key monitoring dashboards, as well as other pages to provide you with cost metrics. The following pages can be found in this section:

* [Allocations](cost-allocation/README.md)
* [Assets](assets.md)
* [Cloud Costs](cloud-costs-explorer/cloud-costs-explorer.md)
* [Clusters](clusters-dashboard.md)
* [External Costs](external-costs.md)
* [Network](network-monitoring.md)

## Collections

[Collections](collections.md) allows users to combine groups of Kubernetes and out-of-cluster/cloud costs to create a unified view of spend which eliminates duplicate costs.

## Reports

[Reports](reports.md) are predefined queries from your primary monitoring dashboards (Allocations, Assets, and Cloud Costs). These can be saved and exported for easy viewing.

## Savings

Selecting [*Savings*](savings/savings.md) > *Insights* will open the Savings page which contains multiple Insights, different functions which estimate possible savings and allow you to detect and manage resources which are either underutilized or too costly. Each Insight is able to perform a monthly savings estimate, which are all combined and generated into a total at the top of the Savings page. The following Savings Insights are supported:

* [Right-size your cluster nodes](savings/cluster-right-sizing-recommendations.md)
* [Right-size your container requests](savings/container-request-right-sizing-recommendations.md)
* [Manage abandoned workloads](savings/abandoned-workloads.md)
* [Manage unclaimed volumes](savings/unclaimed-volumes.md)
* [Manage local disks](savings/local-disks.md)
* [Manage underutilized nodes](savings/underutilized-nodes.md)
* [Manage orphaned resources](savings/orphaned-resources.md)
* [Spot Commander](savings/spot-commander.md)
* [Right-size your persistent volumes](savings/pv-right-sizing-rec.md)

Selecting *Savings* > *Actions* will open the [Actions](savings/savings-actions.md) page, which utilizes multiple Insights in a streamlined, and reoccurring way to ensure your environment is regular being maintained to prevent excessive spend.

## Alerts

[Alerts](alerts.md) allow you to establish Slack, Microsoft Teams, and email alerts when spending within your environment exceeds established thresholds, or changes drastically through efficiency or spend.

## Govern

The Govern section contains multiple pages which can provide proactive means of regulating spend within your environment:

* [Budgets](budgets.md) allows you to establish spend rules at the cluster, namespace, or label level which can alert you via Slack, Microsoft Teams, or email.
* [Anomaly Detection](anomaly-detection.md) uses historical spend data to generate a learning model capable of detecting irregular spending referred to as anomalies. These anomalies are listed and sourced for further inspection.
* [Audits](audits.md) provides a log of changes recently made to your deployment. It must first be enabled through the [Cost Events Audit API](/apis/governance-apis/cost-events-audit-api.md#enabling-the-cost-events-audit-api) before it will appear in the left navigation.

## Teams

{% hint style="info" %}
Features in the Teams section are Kubecost Enterprise only features.
{% endhint %}

The Teams section allows for configuration of user roles and service accounts in your environment:

* [Teams](teams.md) allows you to configure RBAC within the UI.
* [Service Accounts](service-accounts.md) allows you to configure access to the Kubecost API while having SAML or OIDC enabled.