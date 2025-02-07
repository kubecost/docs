# Turbonomic Actions 

{% hint style="warning" %}
This feature is in beta. Please read the documentation carefully.
{% endhint %}

The [IBM Turbonomic Action Center](https://www.ibm.com/docs/en/tarm/8.14.3?topic=reference-turbonomic-actions) offers multiple types of actions destined to improve the overall performance of your cluster(s). The integration between Kubecost and Turbonomic allows you to view the estimated savings incurred by executing these actions.

## Prerequisites
To be able to see the savings cards, you must first enable the [Turbonomic Integration](../../../integrations/turbonomic-integration.md). This is required for Kubecost to be able to pull action data from your Turbonomic client.

## Actions
![Savings cards: Turbonomic Actions](../../../images/savings-turbo-actions.png)

### Resize Workload Controllers
![Resize Workload Controllers](../../../images/savings-turbo-actions-rwc.png)

The Resize Workload Controllers page shows workloads which would benefit from changes to their resource requests, as recommended by Turbonomic. 
The Current and Predicted cost columns are calculated using the [Spec Cost Prediction API](../../../apis/governance-apis/spec-cost-prediction-api.md): the Current column is calculated by inferring the CPU and/or memory requests on all Containers in the workload, while the Predicted column is calculated by using the new request values recommended by Turbonomic for each container. Please note that at the moment, this functionality is only available for Deployments and StatefulSets.

### Suspend Container Pods
![Suspend Container Pods](../../../images/savings-turbo-actions-scp.png)

The Suspend Container Pods page shows pods that Turbonomic recommends to be suspended. 
The Current cost column represents the monthly rate for the Pod in question, queried over a period of `7d offset 48h` to account for reconciliation.
The Predicted cost column is zero for suspension actions.

### Suspend Virtual Machines
![Suspend Virtual Machines](../../../images/savings-turbo-actions-svm.png)

The Suspend Virtual Machines page shows virtual machines (nodes) that Turbonomic recommends to be suspended.
The Current cost column represents the monthly rate for the node in question, queried over a period of `7d offset 48h` to account for reconciliation.
The Predicted cost column is zero for suspension actions.

### Move Container Pods
![Move Container Pods](../../../images/savings-turbo-actions-mcp.png)

The Move Container Pods page shows pods that Turbonomic recommends to be moved from one node to another.
The Current cost column represents the monthly rate for the destination node, queried over a period of `7d offset 48h` to account for reconciliation.
The Efficiency column contains a hyperlink to the Efficiency page for the destination node, highlighting the infrastructure idle corresponding to it.  
