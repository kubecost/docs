# Azure Cloud Integration

Connecting your Azure account to Kubecost allows you to view Kubernetes metrics side-by-side with out-of-cluster (OOC) costs (e.g. Azure Database Services). Additionally, it allows Kubecost to reconcile measured Kubernetes spend with your actual Azure bill. This gives teams running Kubernetes a complete and accurate picture of costs. For more information, read the cloud integrations [doc](/install-and-configure/advanced-configuration/cloud-integration) and [blog post](https://blog.kubecost.com/blog/complete-picture-when-monitoring-kubernetes-costs/).

To configure Kubecost's Azure Cloud Integration, you will need to set up daily exports of cost reports to Azure storage. Kubecost will then access your cost reports through the Azure Storage API to display your out-of-cluster cost data alongside your in-cluster costs.

> **Note**: A GitHub repository with sample files used in below instructions can be found here: [https://github.com/kubecost/poc-common-configurations/tree/main/azure](https://github.com/kubecost/poc-common-configurations/tree/main/azure)

## Step 1: Export Azure cost report

Follow this [Azure guide](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-export-acm-data) to export cost reports. Ensure you select the "Daily export of month-to-date costs" and "Amortized cost (Usage and Purchases)" options while leaving off "File Partitioning". Also take note of the "StorageAccount" and "StorageContainer" specified when choosing where to export the data to.

Alternatively, you can follow this [Kubecost guide](https://github.com/kubecost/azure-hackfest-lab/tree/a51fad1b9640b5991e5d567941f5086eb626a83f/0\_create-azure-cost-export).

It will take a few hours to generate the first report, after which Kubecost can use the Azure Storage API to pull that data.

Once the cost export has successfully executed, verify that a non-empty CSV file has been created at this path: `<STORAGE_ACCOUNT>/<CONTAINER_NAME>/<OPTIONAL_CONTAINER_PATH>/<COST_EXPORT_NAME>/<DATE_RANGE>/<CSV_FILE>`.

> **Note**: If you have sensitive data in an existing Azure Storage account, it is recommended to create a separate Azure Storage account to store your cost data export.

> **Note**: For more granular billing data it is possible to [scope Azure cost exports](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/understand-work-scopes) to resource groups, management groups, departments, or enrollments. AKS clusters will create their own resource groups which can be used. This functionality can then be combined with Kubecost [multi-cloud](/install-and-configure/advanced-configuration/cloud-integration/multi-cloud) to ingest multiple scoped billing exports.

## Step 2: Provide access to Azure Storage API

The following values can be located in the Azure Portal under "Cost Management -> Exports" or "Storage accounts":

* `azureSubscriptionID` is the "Subscription ID" belonging to the Storage account which stores your exported Azure cost report data.
* `azureStorageAccount` is the name of the Storage account where the exported Azure cost report data is being stored.
* `azureStorageAccessKey` can be found by selecting the "Access Keys" option from the navigation sidebar then selecting "Show Keys". Using either of the two keys will work.
* `azureStorageContainer` is the name that you chose for the exported cost report when you set it up. This is the name of the container where the CSV cost reports are saved in your Storage account.
* `azureContainerPath` is an optional value which should be used if there is more than one billing report that is exported to the configured container. The path provided should have only one billing export because kubecost will retrieve the most recent billing report for a given month found within the path.
* `azureCloud` is an optional value which denotes the cloud where the storage account exist, possible values are `public` and `gov`. The default is `public`.

Next, create a JSON file which _**must**_ be named `cloud-integration.json` with the following format:

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

> **NOTE:** Additional details about the `cloud-integration.json` file can be found in our [multi-cloud integration](/install-and-configure/advanced-configuration/cloud-integration/multi-cloud) documentation.

Next, create the secret:

```bash
$ kubectl create secret generic <SECRET_NAME> --from-file=cloud-integration.json -n kubecost
```

Next, ensure the following are set in your Helm values:

```yaml
kubecostProductConfigs:
  cloudIntegrationSecret: <SECRET_NAME>
```

Next, upgrade Kubecost via Helm:

```bash
$ helm upgrade kubecost kubecost/cost-analyzer -n kubecost -f values.yaml
```

You can verify a successful configuration by checking the following:

* The "/assets" view will be broken down by cloud service (e.g. "Microsoft.compute", "Microsoft.storage")
* The "/assets" view will no longer show a banner that says "External cloud cost not configured"
* The "/diagnostics" view will show a green checkmark under "Cloud Integrations"

## Step 3: Tagging Azure resources

Kubecost utilizes Azure tagging to allocate the costs of Azure resources outside of the Kubernetes cluster to specific Kubernetes concepts, such as namespaces, pods, etc. These costs are then shown in a unified dashboard within the Kubecost interface.

To allocate external Azure resources to a Kubernetes concept, use the following tag naming scheme:

| Kubernetes Concept | Azure Tag Key             | Azure Tag Value |
| ------------------ | ------------------------- | --------------- |
| Cluster            | kubernetes\_cluster       | cluster-name    |
| Namespace          | kubernetes\_namespace     | namespace-name  |
| Deployment         | kubernetes\_deployment    | deployment-name |
| Label              | kubernetes\_label\_NAME\* | label-value     |
| DaemonSet          | kubernetes\_daemonset     | daemonset-name  |
| Pod                | kubernetes\_pod           | pod-name        |
| Container          | kubernetes\_container     | container-name  |

_\*In the `kubernetes_label_NAME` tag key, the NAME portion should appear exactly as the tag appears inside of Kubernetes. For example, for the tag `app.kubernetes.io/name`, this tag key would appear as `kubernetes_label_app.kubernetes.io/name.`_

To use an alternative or existing Azure tag schema, you may supply these in your values.yaml under the `kubecostProductConfigs.labelMappingConfigs.<aggregation>_external_label` . Also be sure to set `kubecostProductConfigs.labelMappingConfigs.enabled = true`

For more details on what Azure resources support tagging, along with what resource type tags are available in cost reports, please review the official Microsoft documentation [here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-support).

## Troubleshooting and debugging

To validate that the configuration was successful:

* The "/assets" view will be broken down by cloud service (e.g. "Microsoft.compute", "Microsoft.storage")
* The "/assets" view will no longer show a banner that says "External cloud cost not configured"
* The "/diagnostics" view will show a green checkmark under "Cloud Integrations"

> **Note**: if there are no in-cluster costs for a particular day, then there will not be out-of-cluster costs either

To troubleshoot a configuration that is not yet working:

* `$ kubectl get secrets -n kubecost` to verify you've properly configured `cloud-integration.json`.
* `$ helm get values kubecost` to verify you've properly set `.Values.kubecostProductConfigs.cloudIntegrationSecret`
* Verify that a non-empty CSV file has been created at this path in your Azure Portal Storage Account: `<STORAGE_ACCOUNT>/<CONTAINER_NAME>/<OPTIONAL_CONTAINER_PATH>/<COST_EXPORT_NAME>/<DATE_RANGE>/<CSV_FILE>`. Ensure new CSVs are being generated every day.
* When opening a cost report CSV, ensure that there are rows in the file that do not have a MeterCategory of “Virtual Machines” or “Storage” as these items are ignored because they are in cluster costs. Additionally, make sure that there are items with a UsageDateTime that matches the date you are interested in.

When reviewing logs:

* The following error is reflective of Kubecost's previous Azure Cloud Integration method and can be safely disregarded.
  
  ```ERR Error, Failed to locate azure storage config file: /var/azure-storage-config/azure-storage-config.json```
