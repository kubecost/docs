# Budgets

Budgets are a way of establishing spend limits for your workloads. They can be created in moments using the Budgets dashboard.

## Creating a budget

Begin by selecting the _New Budget_ button in the top right corner of the dashboard. A new window will display from the right side of your screen.

![New budget dialog](/.gitbook/assets/new-budget.png)

Provide the following fields:

* __Budget name__: The name of your budget
* __Budget type__: The type of workloads monitored under the budget; the supported options are Allocations, Assets, Cloud and Collection
* __Budget cap__: The allotted amount of your budget per interval

{% hint style="info" %}
The currency of your budget cannot be changed directly in the Budgets dashboard. To change currency type, go to _Settings >_ Currency. Then, select _Save_ at the bottom of the Settings page to apply changes. Changing currency type will affect cost displays across all of your Kubecost, not just the Budgets dashboard. Kubecost does **not** convert spending costs to other currency types; it will only change the symbol displayed next to the cost. For best results, configure your currency to what matches your spend.
{% endhint %}

Determine the length of your budget and reset date using the two dropdowns under the Budget cap text box. Budgets can be either _Weekly_ or _Monthly_, and can reset on any day of the week/month. This means you don't need to recreate your budgets repeatedly and can align them with your schedules or processes.

### Workloads

You can configure one or more workload(s) to be targeted by the budget. From the first dropdown, select the desired workload category. Once the workload category has been selected, the dropdown menu should display all possible values for that category. Select 'Add Filter' to persist your choice. You can repeat for as many workload categories as you need to. 
The workload properties available will change depending on the selected budget type:

#### Allocations
- Cluster 
- Namespace 
- Label

#### Assets

- Name 
- Asset Type 
- Cluster 
- Provider 
- ProviderID 
- Account 
- Label

#### Cloud

- Account ID
- Account Name
- Availability Zone
- Provider
- ProviderID
- Region
- Invoice Entity Name
- Invoice Entity ID
- Category
- Service
- Label

#### Collection

For Collection budgets, you can select one collection from the dropdown displaying all available collections. At the moment, Kubecost can only track spend for a single collection per budget.

{% hint style="info" %}
Labels need to be provided in a `key:value` format that describes the object that the budget applies to.
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

Once your budget has been created, it will immediately display your current spending. There are multiple ways of inspecting or adjusting your existing budgets:

### Details

Selecting _Details_ in the row of a specific budget will open a window displaying all details for your budget including current spend, remaining budget, reset date and any existing Actions.

You can select _View detailed breakdown_ to be redirected to the corresponding view on the Monitor page, or _Download Budget Report_ to download a PDF report of the budget.

### Editing a budget

Selecting _Edit_ in the row of a specific budget will open a window allowing you to edit all details about your budget, similar to when you initially created it.

### Deleting a budget

Selecting _Delete_ will open the Delete Budget window. Confirm by selecting _Delete_.

## Use cases

[Enforce Kubecost Budgets to prevent overruns before they occur](/using-kubecost/proactive-cost-controls.md).
