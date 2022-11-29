# Azure Cloud Integration

Connecting your Azure account to Kubecost allows you to view Kubernetes metrics side-by-side with out-of-cluster costs (e.g. Azure Database Services). Additionally, it allows Kubecost to reconcile measured Kubernetes spend with your actual Azure bill. This gives teams running Kubernetes a complete and accurate picture of costs.

For more information, read the cloud integrations [doc](https://docs.kubecost.com/install-and-configure/advanced-configuration/cloud-integration) and [blog post](https://blog.kubecost.com/blog/complete-picture-when-monitoring-kubernetes-costs/).

To configure Kubecost's Azure Cloud Integration, you will need to set up daily exports of cost reports to Azure storage. Kubecost will then access your cost reports through the Azure Storage API to display your out-of-cluster cost data alongside your in-cluster costs.

> **Note**: A GitHub repository with sample files used in below instructions can be found here: [https://github.com/kubecost/poc-common-configurations/tree/main/azure](https://github.com/kubecost/poc-common-configurations/tree/main/azure)

## Step 1: Export Azure cost report

Follow this [Azure guide](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-export-acm-data) to export cost reports. Ensure you select the "Daily export of month-to-date costs" and "Amortized cost (Usage and Purchases)" options. Also take note of the "StorageAccount" and "StorageContainer" specified when choosing where to export the data to.

Alternatively, you can follow this [Kubecost guide](https://github.com/kubecost/azure-hackfest-lab/tree/a51fad1b9640b5991e5d567941f5086eb626a83f/0\_create-azure-cost-export).

It will take a few hours to generate the first report, after which Kubecost can use the Azure Storage API to pull that data.

> **Note**: If you have sensitive data in an existing Azure Storage account, it is recommended to create a separate Azure Storage account to store your cost data export.

## Step 2: Provide access to Azure Storage API

> **NOTE:** If you are using the alternative [multi-cloud integration](https://docs.kubecost.com/install-and-configure/advanced-configuration/cloud-integration/multi-cloud) method **step 2** is not required.

They following values can be located in the Azure Portal under "Cost Managent -> Exports" or "Storage accounts":

* `<SUBSCRIPTION_ID>` is the id of the subscription that the exported files are being generated for.
* `<STORAGE_ACCOUNT_NAME>` is the name of the Storage account where the exported CSV is being stored.
* `<STORE_ACCESS_KEY>` can be found by selecting the “Access Keys” option from the navigation sidebar then selecting “Show Keys”. Using either of the two keys will work.
* `<REPORT_CONTAINER_NAME>` is the name that you choose for the exported cost report when you set it up. This is the name of the container where the CSV cost reports are saved in your Storage account.
* `<AZURE_CONTAINER_PATH>` is an optional value which should be used if there is more than one billing report that is exported to the configured container. The path provided should be have only one billing export because kubecost will retrieve the most recent billing report for a given month found within the path.
* `<AZURE_CLOUD>` is an optional value which denotes the cloud where the storage account exist, possible values are `public` and `gov`. The default is `public`.

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

Next, create the secret:

```bash
$ kubectl create secret generic <SECRET_NAME> --from-file=cloud-integration.json -n kubecost
```

Next, ensure the following are set in your Helm values:

```yaml
kubecostProductConfigs:
  cloudIntegrationSecret: <SECRET_NAME>
```

Next, upgrade Kubecost via Helm.

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

If you were unable to see your OOC costs on the dashboard, here are some steps you can take to attempt to address the issue. First, check that you used the correct values in the JSON file used to create your secret. Additionally, if there are no in-cluster costs for a particular day then OOC cost will not show for that day either.

### Validate exported cost report and content

Check your Azure Storage account where your cost report is being exported and locate the CSV corresponding to the month that you are trying to query. Find the most recent version of the CSV as a new one should be created every day. Download and open the file and verify that the file is being populated. Ensure that there are rows in the file that do not have a MeterCategory of “Virtual Machines” or “Storage” as these items are ignored because they are in cluster costs. Additionally, make sure that there are items with a UsageDateTime that matches the date you are interested in.

### Validate secret configuration

A failed configuration may be due to the secret not being present on your cluster in the correct namespace. Use the command `kubectl get secrets -n kubecost` to retrieve a list of secrets on your cluster. If you do not see the secret that you created in the list, create the secret again using the JSON file you filled out and the command above. If your secret is present then take note of the name as it appears in the list. Next check your values.yaml file using `helm get values kubecost -a` and find the value of kubecostProductConfigs.azureStorageSecretName and check that it matches the name of the secret as it was listed above. If this is not the case, then update the value using the helm upgrade command using either the `--set` flag to set the value directly of the `-f` flag to provide your values.yaml file.

### Check Kubernetes logs

To get a concise view of the logs generated by Kubecost to create the assets page use `kubectl <KUBECOST_PODNAME> -f | grep "Asset ETL"`. \<KUBECOST\_PODNAME> can be retrieved using `kubectl get pods -n kubecost -l app=cost-analyzer -o json | jq '.items[] | select(.status.phase=="Running") | .metadata.name' | tr -d \"`.
