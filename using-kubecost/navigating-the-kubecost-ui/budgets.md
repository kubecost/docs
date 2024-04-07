# Budgets

Budgets are a way of establishing spend limits for your clusters, namespaces, or labels. They can be created in moments using the Budgets dashboard.

## Creating a budget

Begin by selecting the _New Budget_ button in the top right corner of the dashboard. A new window will display from the right side of your screen.

![New budget dialog](/.gitbook/assets/new-budget.png)

Provide the following fields:

* _Budget name_: The name of your budget
* Budget cap: The allotted amount of your budget per interval

{% hint style="info" %}
The currency of your budget is unchangeable in the Budgets dashboard. To change currency type, go to _Settings >_ Currency. Then, select _Save_ at the bottom of the Settings page to apply changes. Changing currency type will affect cost displays across all of your Kubecost, not just the Budgets dashboard. Kubecost does **not** convert spending costs to other currency types; it will only change the symbol displayed next to cost. For best results, configure your currency to what matches your spend.
{% endhint %}

Determine the length of your budget and reset date using the two dropdowns under the Budget cap text box. Budgets can be either _Weekly_ or _Monthly_, and can reset on any day of the week/month. This means you don't need to recreate your budgets repeatedly and can align them with your schedules or processes.

### Workloads

From the first dropdown, select whether this budget will apply to a namespace, cluster, or a label. In the second dropdown, choose the individual item in that category. When _Namespace_ or _Cluster_ has been selected, the dropdown menu should attempt to autocomplete by searching for all potential items.

{% hint style="info" %}
Labels need to be provided in a key:value format that describes the object where the budget applies to.
{% endhint %}

### **Actions**

Budget Actions are an optional method of better monitoring your budgets. You can use Actions to create an alert when your budget hits a certain percentage threshold, and send out an email, Slack, and/or Microsoft Teams alert.

{% hint style="info" %}
Budget Actions by default check against the limits every 8 hours.
{% endhint %}

To begin, select _New Action_. Select your _Trigger percentage_ value (leaving your _Trigger percentage_ at _100_ will only alert you once the budget has been exceeded). Then, provide any emails or webhooks where you would like to receive your alerts. Select _Save_.

{% hint style="info" %}
If you are interested in implementing additional alerts to monitor further spending or Kubecost health, read our [Alerts](/using-kubecost/navigating-the-kubecost-ui/alerts.md) doc.
{% endhint %}

Finalize your budget by selecting _Save_. Your budget has been created and should appear on the dashboard.

## Budget options

Once your budget has been created, it will immediately display your current spending. There are multiple ways of inspecting or adjusting your existing budgets.

### Details

Selecting _Details_ in the row of a specific budget will open a window displaying all details for your budget, including current spending, budget remaining, reset date, and any existing Actions.

You can also select _View detailed breakdown_ to display an [Allocations](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/README.md) query for your budgeted item, or _Download Budget Report_ to download your budget as a PDF file.

### Editing a budget

Selecting _Edit_ in the row of a specific budget will open a window allowing you to edit all details about your budget, similar to when you initially created it. All details are able to be changed here.

### Deleting a budget

Selecting _Delete_ will open the Delete Budget window. Confirm by selecting _Delete_.

## Use cases

For how to use budgets in a use case preventing cost overruns before they occur, see the guide [here](/using-kubecost/proactive-cost-controls.md).
