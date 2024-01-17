# Kubecost Cloud: Alerts

{% hint style="info" %}
This documentation should only be consulted when using Kubecost Cloud! For information about Alerts for self-hosted Kubecost, see [here](/using-kubecost/navigating-the-kubecost-ui/alerts.md).
{% endhint %}

Alerts allow teams to receive updates on real-time Kubernetes spend. This doc gives an overview of how to configure alerts sent through email, Slack, and Microsoft Teams. Alerts are either created to monitor specific data sets and trends, or they must be toggled on or off.

Currently, only spend changes in allocation costs are supported in Kubecost Cloud. This alert type detects sudden changes in allocation spending (spending relating to any Kubernetes objects) when compared to a previous interval.

![Kubecost Cloud Alerts page](/images/kc-cloud-alerts.png)

## Creating an alert

To begin, select _Create Alert_. The 'Create New Alert' slide panel opens. Provide the following fields:

* Alert Type: Currently only can be set to _Allocation Spend Change_.
* Window: Spend over selected interval will be compared against the previous interval. Supports _Daily_, _Weekly_, and _Monthly_.
* Cost Threshold (%): Percent change to trigger alert. Must be configured as a negative value to detect sudden decreases in spend.
* Aggregation: The Kubernetes object type to monitor spend for.
* Filter: Optional, filter to a specific selected Kubernetes object.
* Recipients: Choose which platform(s) you want your alert sent through. Kubecost Alerts can be sent via Slack/Microsoft Teams webhook URLs, or by email. All three platforms do not need values provided for them, but may trigger global recipients if left blank (see below).

Before you finalize your alert, you can select _Test Alert_, which will send a test alert across the provided webhooks/emails. This is useful for ensuring your alert has been configured correctly. If the alert was sent successfully, you can finalize your changes by selecting _Submit_. Your alert will now appear on the Alerts page, and can be tested, edited, or deleted at any time by selecting the corresponding icons in your alert's line.

## Global recipients

Global recipients specify a default fallback recipient for each type of message. If an alert does not define any email recipients, its messages will be sent to any emails specified in the Global Recipients email list. Likewise, if an alert does not define a webhook, its messages will be sent to the webhook, if one is present. Alerts that do define recipients will ignore the global setting for recipients of that type.

You can define global recipients by selecting _Edit_ in the Global Recipients box, then selecting the desired platform type and providing a corresponding value. Confirm by selecting _Save_. You can only provide one webhook per platform as a global recipient.


## Cluster Status Alerts

Cluster Status notifications, if enabled, provide notice if and when the cluster agent(s) installed have stopped reporting data to Kubecost Cloud. 

To configure, select _Add_ in the Cluster Status Alerts box. The 'Cluster Status' slide panel opens. Provide any Slack/Microsoft Teams webhooks or email addresses to which you want the alert sent. Confirm by selecting _Enable_.