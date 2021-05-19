# Integrating Azure Out of Cluster Cluster Costs into Kubecost

Kubecost provides the ability to view Kubernetes metrics side-by-side with external cloud services cost, e.g. Azure Database Services. Additionally, it allows Kubecost to reconcile spend with your actual Azure bill. This gives teams running Kubernetes a complete and accurate picture of costs. [More info on this functionality](http://blog.kubecost.com/blog/complete-picture-when-monitoring-kubernetes-costs/)

To configure out-of-cluster (OOC) costs for Azure in Kubecost, you just need to set up daily exportation of cost reports to Azure storage. Once cost reports are exported to Azure Storage, Kubecost will access them through the Azure Storage API to display your OOC cost data alongside your in cluster costs.

## Step 1: Export Azure Cost Report

Follow this guide taking note of the name that you use for the exported cost report and select the daily month-to-date option for how the reports will be created.

https://docs.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-export-acm-data?tabs=azure-portal

It will take a few hours to generate the first report, after which Kubecost can use the Azure Storage API to pull that data. 

>Note: If you have sensitive data in an Azure Storage account and do not want to give out access to it, create a separate Azure Storage account to store your cost data export.

## Step 2: Provide Access to Azure Storage API

The values needed to provide access to the Azure Storage Account where cost data is being exported can be found in the Azure portal in the Storage account where the cost data is being exported. 
* `<STORAGE_ACCOUNT_NAME>` is the name of the Storage account where the exported CSV is being stored.
* `<STORE_ACCESS_KEY>` can be found by selecting the “Access Keys” option from the navigation sidebar  then selecting “Show Keys”. Using either of the two keys will work. 
* `<REPORT_CONTAINER_NAME>` is the name that you choose for the exported cost report when you set it up. This is the name of the container where the CSV cost reports are saved in your Storage account. 


### Maually add secret to cluster (Recommended)
To create this secret you will need to create a JSON file that must be named azure-storage-config.json
with the following format:

```
{
	"azureStorageAccount": "<STORAGE_ACCOUNT_NAME>",
	"azureStorageAccessKey": "<STORE_ACCESS_KEY>",
	"azureStorageContainer": <REPORT_CONTAINER_NAME>
}
```

Once you have the values filled out use this command to create the secret:

`kubectl create secret generic <SECRET_NAME> --from-file=azure-storage-config.json -n kubecost`

Once the secret is created, set `.Values.kubecostProductConfigs.azureStorageSecretName` to
`<SECRET_NAME>` and upgrade Kubecost via Helm, other values related to Azure Storage (see other method) should not be set.
 
 ### Create a secret from helm values

* Set `.Values.kubecostProductConfigs.azureStorageAccount = <STORAGE_ACCOUNT_NAME>`
* Set `.Values.kubecostProductConfigs.azureStorageAccessKey = <STORE_ACCESS_KEY>`
* Set `.Values.kubecostProductConfigs.azureStorageContainer = <REPORT_CONTAINER_NAME>`
* Set `.Values.kubecostProductConfigs.azureStorageCreateSecret = true`
* Do not set `.Values.kubecostProductConfigs.azureStorageSecretName` if you are using this approach

> Note: that this will leave your secrets unencrypted in values.yaml. Use a Kubernetes secret as in the previous method to avoid this.

After successful set up of Azure OOC costs upon opening the Assets page of Kubecost there will no longer be a banner at the top of the screen will no longer say that OOC is not configured and costs will be broken down by service.

## Step 3: Tagging Azure resources

Kubecost utilizes Azure tagging to allocate the costs of Azure resources outside of the Kubernetes cluster to specific Kubernetes concepts, such as namespaces, pods, etc. These costs are then shown in a unified dashboard within the Kubecost interface.

To allocate external Azure resources to a Kubernetes concept, use the following tag naming scheme:

| Kubernetes Concept 	| Azure Tag Key       	| Azure Tag Value 	|
|--------------------	|---------------------	|---------------	|
| Cluster           	| kubernetes_cluster	| &lt;cluster-name>	|
| Namespace          	| kubernetes_namespace	| &lt;namespace-name> |
| Deployment         	| kubernetes_deployment	| &lt;deployment-name>|
| Label              	| kubernetes_label_NAME*| &lt;label-value>    |
| DaemonSet          	| kubernetes_daemonset	| &lt;daemonset-name> |
| Pod                	| kubernetes_pod	      | &lt;pod-name>     |
| Container          	| kubernetes_container	| &lt;container-name> |


 
*\*In the kubernetes_label_NAME tag key, the NAME portion should appear exactly as the tag appears inside of Kubernetes. For example, for the tag app.kubernetes.io/name, this tag key would appear as kubernetes_label_app.kubernetes.io/name.*

To use an alternative or existing Azure tag schema, you may supply these in your values.yaml under the `kubecostProductConfigs.labelMappingConfigs.<aggregation>_external_label` . Also be sure to set `kubecostProductConfigs.labelMappingConfigs.enabled = true`

More on Azure tagging [here](https://docs.microsoft.com/en-us/azure/virtual-machines/tag-portal)

## Troubleshooting and Debugging

If you were unable to see your OOC costs on the dashboard, here are some steps you can take to attempt to address the issue. First check that you used the correct values in the JSON file used to create your secret. Additionally if there are no in cluster costs for a particular day then OOC cost will not show for that day either.

### Validate Exported Cost Report and Content

Check your Azure Storage account where your cost report is being exported and locate the CSV corresponding to the month that you are trying to query. Find the most recent version of the CSV as a new one should be created every day. Download and open the file and verify that the file is being populated. Ensure that there are rows in the file that do not have a MeterCategory of “Virtual Machines” or “Storage” as these items are ignored, because they are in cluster costs. Additionally make sure that there are items with a UsageDateTime that matches the date you are interested in.

### Validate Secret Configuration

A failed configuration may be due to the secret not being present on your cluster in the correct namespace. Use the command `kubectl get secrets -n kubecost` to retrieve a list of secrets on your cluster. If you do not see the secret that you created in the list, create the secret again using the JSON file you filled out and the command above. If your secret is present then take note of the name as it appears in the list. Next check your values.yaml file using `helm get values kubecost -a` and find the value of kubecostProductConfigs.azureStorageSecretName and check that it matches the name of the secret as it was listed above. If this is not the case, then update the value using the helm upgrade command using either the `--set` flag to set the value directly of the `-f` flag to provide your own values.yaml file.

### Check Kubernetes Logs

To get a concise view of the logs generated by Kubecost to create the assets page use `kubectl <KUBECOST_PODNAME>  -f | grep "Asset ETL"`.
 <KUBECOST_PODNAME> can be retrieved using `kubectl get pods -n kubecost -l app=cost-analyzer -o json | jq '.items[] | select(.status.phase=="Running") | .metadata.name' | tr -d \"`.

