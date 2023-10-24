# Azure Cloud Billing Integration

Connecting your Azure account to Kubecost allows you to view Kubernetes metrics side-by-side with out-of-cluster (OOC) costs (e.g. Azure Database Services). Additionally, it allows Kubecost to reconcile measured Kubernetes spend with your actual Azure bill. This gives teams running Kubernetes a complete and accurate picture of costs. For more information, read [Cloud Billing Integrations](https://docs.kubecost.com/install-and-configure/install/cloud-integration) and this [blog post](https://blog.kubecost.com/blog/complete-picture-when-monitoring-kubernetes-costs/).

To configure Kubecost's Azure Cloud Integration, you will need to set up daily exports of cost reports to Azure storage. Kubecost will then access your cost reports through the Azure Storage API to display your OOC cost data alongside your in-cluster costs.

A GitHub repository with sample files used in below instructions can be found [here](https://github.com/kubecost/poc-common-configurations/tree/main/azure).

## Step 1: Export Azure cost report

Follow Azure's [Create and Manage Exported Data](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-export-acm-data?tabs=azure-portal) tutorial to export cost reports. For Metric, make sure you select _Amortized cost (Usage and Purchases)._ For Export type, make sure you select _Daily export of month-to-date costs._ Do not select _File Partitioning_. Also, take note of the Account name and Container specified when choosing where to export the data to. Note that a successful cost export will require [`Microsoft.CostManagementExports`](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/azure-services-resource-providers) to be registered in your subscription.

Alternatively, you can follow this [Kubecost guide](https://github.com/kubecost/azure-hackfest-lab/tree/a51fad1b9640b5991e5d567941f5086eb626a83f/0\_create-azure-cost-export).

It will take a few hours to generate the first report, after which Kubecost can use the Azure Storage API to pull that data.

Once the cost export has successfully executed, verify that a non-empty CSV file has been created at this path: `<STORAGE_ACCOUNT>/<CONTAINER_NAME>/<OPTIONAL_CONTAINER_PATH>/<COST_EXPORT_NAME>/<DATE_RANGE>/<CSV_FILE>`.

{% hint style="info" %}
If you have sensitive data in an existing Azure Storage account, it is recommended to create a separate Azure Storage account to store your cost data export.
{% endhint %}

{% hint style="info" %}
For more granular billing data it is possible to [scope Azure cost exports](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/understand-work-scopes) to resource groups, management groups, departments, or enrollments. AKS clusters will create their own resource groups which can be used. This functionality can then be combined with Kubecost [multi-cloud](multi-cloud.md) to ingest multiple scoped billing exports.
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
Additional details about the `cloud-integration.json` file can be found in our [multi-cloud integration](multi-cloud.md) doc.
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

## Step 3: Tagging Azure resources

Kubecost utilizes Azure tagging to allocate the costs of Azure resources outside of the Kubernetes cluster to specific Kubernetes concepts, such as namespaces, pods, etc. These costs are then shown in a unified dashboard within the Kubecost interface.

To allocate external Azure resources to a Kubernetes concept, use the following tag naming scheme:

<table><thead><tr><th width="227.33333333333331">Kubernetes Concept</th><th>Azure Tag Key</th><th>Azure Tag Value</th></tr></thead><tbody><tr><td>Cluster</td><td><code>kubernetes_cluster</code></td><td><code>cluster-name</code></td></tr><tr><td>Namespace</td><td><code>kubernetes_namespace</code></td><td><code>namespace-name</code></td></tr><tr><td>Deployment</td><td><code>kubernetes_deployment</code></td><td><code>deployment-name</code></td></tr><tr><td>Label</td><td><code>kubernetes_label_NAME*</code></td><td><code>label-value</code></td></tr><tr><td>DaemonSet</td><td><code>kubernetes_daemonset</code></td><td><code>daemonset-name</code></td></tr><tr><td>Pod</td><td><code>kubernetes_pod</code></td><td><code>pod-name</code></td></tr><tr><td>Container</td><td><code>kubernetes_container</code></td><td><code>container-name</code></td></tr></tbody></table>

In the `kubernetes_label_NAME` tag key, the NAME portion should appear exactly as the tag appears inside of Kubernetes. For example, for the tag `app.kubernetes.io/name`, this tag key would appear as `kubernetes_label_app.kubernetes.io/name.`

To use an alternative or existing Azure tag schema, you may supply these in your values.yaml under the `kubecostProductConfigs.labelMappingConfigs.<aggregation>_external_label` . Also be sure to set `kubecostProductConfigs.labelMappingConfigs.enabled = true`

For more details on what Azure resources support tagging, along with what resource type tags are available in cost reports, please review the official Microsoft documentation [here](https://docs.microsoft.com/en-us/azure/azure-resource-manager/management/tag-support).

## Troubleshooting and debugging

To troubleshoot a configuration that is not yet working:

* `$ kubectl get secrets -n kubecost` to verify you've properly configured `cloud-integration.json`.
* `$ helm get values kubecost` to verify you've properly set `.Values.kubecostProductConfigs.cloudIntegrationSecret`
* Verify that a non-empty CSV file has been created at this path in your Azure Portal Storage Account: `<STORAGE_ACCOUNT>/<CONTAINER_NAME>/<OPTIONAL_CONTAINER_PATH>/<COST_EXPORT_NAME>/<DATE_RANGE>/<CSV_FILE>`. Ensure new CSVs are being generated every day.
* When opening a cost report CSV, ensure that there are rows in the file that do not have a MeterCategory of “Virtual Machines” or “Storage” as these items are ignored because they are in cluster costs. Additionally, make sure that there are items with a UsageDateTime that matches the date you are interested in.

When reviewing logs:

*   The following error is reflective of Kubecost's previous Azure Cloud Integration method and can be safely disregarded.

    `ERR Error, Failed to locate azure storage config file: /var/azure-storage-config/azure-storage-config.json`
