# Azure Cloud Billing Integration

Connecting your Azure account to Kubecost allows you to view Kubernetes metrics side-by-side with out-of-cluster (OOC) costs (e.g. Azure Database Services). Additionally, it allows Kubecost to reconcile measured Kubernetes spend with your actual Azure bill. This gives teams running Kubernetes a complete and accurate picture of costs. For more information, read [Cloud Billing Integrations](/install-and-configure/install/cloud-integration/README.md) and this [blog post](https://blog.kubecost.com/blog/complete-picture-when-monitoring-kubernetes-costs/).

To configure Kubecost's Azure Cloud Integration, you will need to set up daily exports of cost reports to Azure storage. Kubecost will then access your cost reports through the Azure Storage API to reconcile Kubernetes costs and display your cloud cost data.

A GitHub repository with sample files used in below instructions can be found [here](https://github.com/kubecost/poc-common-configurations/tree/main/azure).

## Step 1: Export Azure cost report

{% hint style="warning" %}
Azure Cost Management is not available for all offer types. Review the Azure documentation, [Understand Cost Management data](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/understand-cost-mgt-data#supported-microsoft-azure-offers), to learn more.
{% endhint %}

Follow Azure's [Create and Manage Exported Data](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-export-acm-data?tabs=azure-portal) tutorial to export cost reports and use the following configuration:

* For 'Type of data' select `Cost and usage details (amortized)`
* Provide a meaningful name for the 'Export name'
* For 'Dataset version' select `2021-10-01`
* For 'Frequency' select `Daily export of month-to-date costs`

Take note of the Storage Account name and Container specified when choosing where to export the data to. Note that a successful cost export will require [`Microsoft.CostManagementExports`](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-services-resource-providers) to be registered in your subscription.

It will take a few hours to generate the first report, after which Kubecost can use the Azure Storage API to pull that data.

Once the cost export has successfully executed, verify that a non-empty CSV file has been created at this path: `<STORAGE_ACCOUNT>/<CONTAINER_NAME>/<OPTIONAL_CONTAINER_PATH>/<COST_EXPORT_NAME>/<DATE_RANGE>/<CSV_FILE>`.

{% hint style="info" %}
If you have sensitive data in an existing Azure Storage account, it is recommended to create a separate Azure Storage account to store your cost data export.
{% endhint %}

{% hint style="info" %}
For more granular billing data it is possible to [scope Azure cost exports](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/understand-work-scopes) to resource groups, management groups, departments, or enrollments. AKS clusters will create their own resource groups which can be used. This functionality can then be combined with Kubecost [multi-cloud](/install-and-configure/install/cloud-integration/multi-cloud.md) to ingest multiple scoped billing exports.
{% endhint %}

## Step 2: Provide access to Azure Storage API

Obtain the following values from Azure to provide to Kubecost. These values can be located in the Azure Portal by selecting _Storage Accounts_, then selecting your specific Storage account for details.

* `azureSubscriptionID` is the "Subscription ID" belonging to the Storage account which stores your exported Azure cost report data.
* `azureStorageAccount` is the name of the Storage account where the exported Azure cost report data is being stored.
* `azureStorageAccessKey` can be found by selecting _Access keys_ in your Storage account left navigation under "Security + networking". Using either of the two keys will work.
* `azureStorageContainer` is the name that you chose for the exported cost report when you set it up. This is the name of the container where the CSV cost reports are saved in your Storage account.
* `azureContainerPath` is an optional value which should be used if there is more than one billing report that is exported to the configured container. The path provided should have only one billing export because Kubecost will retrieve the most recent billing report for a given month found within the path.
* `azureCloud` is an optional value which denotes the cloud where the storage account exist, possible values are `public` and `gov`. The default is `public`.

Next, create a JSON file which **must** be named _cloud-integration.json_ with the following format:

```json
{
    "azure": [
        {
            "azureSubscriptionID": "AZ_cloud_integration_subscriptionId",
            "azureStorageAccount": "AZ_cloud_integration_azureStorageAccount",
            "azureStorageAccessKey": "AZ_cloud_integration_azureStorageAccessKey",
            "azureStorageContainer": "AZ_cloud_integration_azureStorageContainer",
            "azureContainerPath": "",
            "azureCloud": "public/gov"
        }
    ]
}
```

{% hint style="info" %}
Additional details about the `cloud-integration.json` file can be found in our [multi-cloud integration](/install-and-configure/install/cloud-integration/multi-cloud.md) doc.
{% endhint %}

Next, create the Secret:

{% code overflow="wrap" %}
```bash
$ kubectl create secret generic <SECRET_NAME> --from-file=cloud-integration.json -n kubecost
```
{% endcode %}

Next, ensure the following are set in your Helm values:

```yaml
kubecostProductConfigs:
  cloudIntegrationSecret: <SECRET_NAME>
```

Next, upgrade Kubecost via Helm:

```bash
$ helm upgrade kubecost kubecost/cost-analyzer -n kubecost -f values.yaml
```

You can verify a successful configuration by checking the following in the Kubecost UI:

* The Assets dashboard will be broken down by Kubernetes assets.
* The Assets dashboard will no longer show a banner that says "External cloud cost not configured".
* The Diagnostics page (via _Settings_ > _View Full Diagnostics_) view will show a green checkmark under Cloud Integrations.

{% hint style="info" %}
If there are no in-cluster costs for a particular day, then there will not be out-of-cluster costs either
{% endhint %}

## Troubleshooting and debugging

To troubleshoot a configuration that is not yet working:

* `$ kubectl get secrets -n kubecost` to verify you've properly configured `cloud-integration.json`.
* `$ helm get values kubecost` to verify you've properly set `.Values.kubecostProductConfigs.cloudIntegrationSecret`
* Verify that a non-empty CSV file has been created at this path in your Azure Portal Storage Account: `<STORAGE_ACCOUNT>/<CONTAINER_NAME>/<OPTIONAL_CONTAINER_PATH>/<COST_EXPORT_NAME>/<DATE_RANGE>/<CSV_FILE>`. Ensure new CSVs are being generated every day.
* When opening a cost report CSV, ensure that there are rows in the file that do not have a MeterCategory of “Virtual Machines” or “Storage” as these items are ignored because they are in cluster costs. Additionally, make sure that there are items with a UsageDateTime that matches the date you are interested in.
