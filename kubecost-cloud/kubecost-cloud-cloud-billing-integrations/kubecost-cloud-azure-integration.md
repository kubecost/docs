# Kubecost Cloud Azure Integration

{% hint style="info" %}
This documentation should only be consulted when using Kubecost Cloud. For information about the configuring an Azure integration with self-hosted Kubecost, see [here](/install-and-configure/install/cloud-integration/azure-out-of-cluster/azure-out-of-cluster.md).
{% endhint %}

Kubecost Cloud provides the ability to allocate out of cluster (OOC) costs back to Kubernetes concepts like namespaces and deployments. The following guide provides the steps required for allocating OOC costs in Azure.

## Adding an integration

In the Kubecost Cloud UI, begin by selecting _Settings_ in the left navigation. Scroll down to Cloud Integrations, then select _View Additional Details_. The Cloud Integrations dashboard opens. Select _+ Add Integration_. Then, select _Azure Integration_ from the slide panel.

### Step 1: Export Azure Cost Report

Read [Microsoft's tutorial](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-export-acm-data?tabs=azure-portal) for creating and managing exported data. Follow the on-screen instructions in the Kubecost Cloud UI when exporting your cost report to ensure it's properly configured. Then, select _Continue_.

### Step 2: Provide access to Azure Storage API

In the UI, provide Kubecost with the following values which can be located in the Azure Portal by selecting _Storage Accounts:_

* Azure Subscription ID: Subscription ID belonging to the Storage Account which stores your exported Azure cost report data.
* Azure Storage Account: Name of the Storage account where the exported Azure cost report data is being stored.
* Azure Access Key: Found by selecting _Access keys_ in the Storage account left navigation under "Security + networking".
* Azure Storage Container: The name that you chose for the exported cost report when you set it up. This is the name of the container where the CSV cost reports are saved in your Storage account.
* Azure Container Path (optional): An optional value which should be used if there is more than one billing report that is exported to the configured container. The path provided should have only one billing export because Kubecost will retrieve the most recent billing report for a given month found within the path.
* Azure Cloud (optional): An optional value which denotes the cloud where the storage account exist, possible values are `public` and `gov`. The default is `public`.

When all required values have been provided, select _Create Integration_. Be patient while your integration is set up. The Status should initially display as Unknown. This is normal. You should eventually see the integration's Status change from Pending to Successful.
