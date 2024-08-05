# Cloud Billing Integrations

Integration with cloud service providers (CSPs) via their respective billing APIs allows Kubecost to display out-of-cluster (OOC) costs (e.g. AWS S3, Google Cloud Storage, Azure Storage Account). Additionally, it allows Kubecost to reconcile Kubecost's in-cluster predictions with actual billing data to improve accuracy.

{% hint style="danger" %}
If you are using Kubecost Cloud, do not attempt to modify your install using information from this article. You need to consult Kubecost Cloud's specific cloud integration procedures which can be found in its [Cloud Billing Integrations](https://docs.kubecost.com/v/kubecost-cloud/cloud-billing-integrations/cloud-billing-integrations) doc.
{% endhint %}

## Kubecost's cloud processes

As indicated above, setting up a cloud integration with your CSP allows Kubecost to pull in additional billing data. The two processes that incorporate this information are **reconciliation** and **Cloud Costs** (formerly known as CloudUsage).

### Reconciliation

Reconciliation matches in-cluster assets with items found in the billing data pulled from the CSP. This allows Kubecost to display the most accurate depiction of your in-cluster spending. Additionally, the reconciliation process creates `Network` assets for in-cluster nodes based on the information in the billing data. The main drawback of this process is that the CSPs have between a 6 to 24-hour delay in releasing billing data, and reconciliation requires a complete day of cost data to reconcile with the in-cluster assets. This requires a 48-hour window between resource usage and reconciliation. If reconciliation is performed within this window, asset cost is deflated to the partially complete cost shown in the billing data.

Cost-based metrics are based on on-demand pricing unless there is definitive data from a CSP that the node is not on-demand. This way estimates are as accurate as possible. If a new reserved instance is provisioned or a node joins a savings plan:

1. Kubecost continues to emit on-demand pricing until the node is added to the cloud bill.
2. Once the node is added to the cloud bill, Kubecost starts emitting something closer to the actual price.
3. For the time period where Kubecost assumed the node was on-demand but it was actually reserved, reconciliation fixes the price in ETL.

{% hint style="info" %}
The reconciled assets will inherit the labels from the corresponding items in the billing data. If there exist identical label keys between the original assets and those of the billing data items, the label value of the original asset will take precedence.
{% endhint %}

#### Visualize unreconciled costs

Visit _Settings_, then toggle on _Highlight Unreconciled Costs_, then select _Save_ at the bottom of the page to apply changes. Now, when you visit your Allocations or Assets dashboards, the most recent 36 hours of data will display hatching to signify unreconciled costs.

![Allocations dashboard with highlighted unreconciled costs](/images/unreconciled.png)

### Short-term cost estimation

After Kubecost performs reconciliation, the remaining daily and hourly node costs are estimated by calculating the average node cost for the node's runtime in Kubecost data for the last 7 days from the end of midnight the day before. For this reason, Kubecost needs this amount of existing data before performing this short-term cost estimation.

### Cloud Costs

Cloud Costs allow Kubecost to pull in OOC cloud spend from your CSP's billing data, including any services run by the CSP as well as compute resources. By labelling OOC costs, their value can be distributed to your Allocations data as external costs. This allows you to better understand the proportion of OOC cloud spend that your in-cluster usage depends on.

Your cloud billing data is reflected in the aggregate costs of `Account`, `Provider`, `Invoice Entity`, and `Service`. Aggregating and drilling down into any of these categories will provide a subset of the entire bill.

Cloud Costs become available as soon as they appear in the billing data, with the 6 to 24-hour delay mentioned above, and are updated as they become more complete.

## Managing cloud integrations

You can view your existing cloud integrations and their success status in the Kubecost UI by visiting _Settings_, then scrolling to Cloud Integrations. To create a new integration or learn more about existing integrations, select _View additional details_ to go to the Cloud Integrations page.

![Cloud Integrations page](/.gitbook/assets/cloudintegration.png)

Here, you can view your integrations and filter by successful or failed integrations. For non-successful integrations, Kubecost will display a diagnostic error message in the Status column to contextualize steps toward successful integration.

Select an individual integration to view a side panel that contains the most recent run, next run, refresh rate, and an exportable YAML of Helm configs for its CSP's integration values.

### Adding a cloud integration

You can add a new cloud integration by selecting _Add Integration._ For guides on how to set up an integration for a specific CSP, follow these links to helpful Kubecost documentation:

* [Multi-Cloud](multi-cloud.md)
* [AWS](aws-cloud-integrations/aws-cloud-integrations.md)
* [GCP](gcp-out-of-cluster/README.md)
* [Azure](azure-out-of-cluster/azure-out-of-cluster.md)

### Deleting a cloud integration

Select an existing cloud integration, then in the slide panel that appears, select _Delete_.

## Cloud integration configurations

The Kubecost Helm chart provides values that can enable or disable each cloud process on the deployment once a cloud integration has been set up. Turning off either of these processes will disable all the benefits provided by them.

| Value                                                   | Default | Description                                                                                                                                                                                                                  |
|---------------------------------------------------------|---------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| `.Values.kubecostAggregator.cloudCost.refreshRateHours` | 6       | How frequently to fetch your cloud billing data. Reducing this value will decrease resource usage and billing data access costs, but will result in a larger delay in the most current data being displayed. This Helm value corresponds to the `ETL_CLOUD_REFRESH_RATE_HOURS` environment variable. |
| `.Values.kubecostAggregator.cloudCost.runWindowDays`    | 3       | The number of days into the past each run loop will query. Reducing this value will reduce memory load, however, it can cause Kubecost to miss updates to the CUR, if this has happened the day will need to be manually repaired. This Helm value corresponds to the `ETL_CLOUD_RUN_WINDOW_DAYS` environment variable. |
| `.Values.kubecostAggregator.cloudCost.queryWindowDays`  | 7       | The maximum number of days that will be queried from a cloud integration in a single query. Reducing this value can help to reduce memory usage during the build process, but will also result in more queries which can drive up billing data access costs. This Helm value corresponds to the `ETL_CLOUD_QUERY_WINDOW_DAYS` environment variable. |

## Cloud account name aliasing

Often an integrated cloud account name may be a series of random letter and numbers which do not reflect the account's owner, team, or function. Kubecost allows you to rename cloud accounts to create more readable cloud metrics in your Kubecost UI. After you have successfully integrated your cloud account (see above), you need to manually edit your *values.yaml* and provide the original account name and your intended rename:

```
kubecostProductConfigs:
  cloudAccountMapping:
    ACCOUNT_ID: "ACCOUNT_NAME"
```

You will see these changes reflected in Kubecost's UI on the Overview page under Cloud Costs Breakdown. These example account IDs could benefit from being renamed:

![Cloud Costs Breakdown](/images/cloudcostsbreakdown.png)

## Cloud Stores

The ETL contains a Map of Cloud Stores, each representing an integration with a CSP. Each Cloud Store is responsible for the Cloud Cost and Reconciliation pipelines which add OOC costs and adjust Kubecost's estimated cost respectively by cost and usage data pulled from the CSP. Each Cloud Store has a unique identifier called the `ProviderKey` which varies depending on which CSP is being connected to and ensures that duplicate configurations are not introduced into the ETL. The value of the `ProviderKey` is the following for each CSP at a scope that the billing data is being for:

* AWS: Account Id
* GCP: Project Id
* Azure: Subscription Id

The `ProviderKey` can be used as an argument for the endpoints for Cloud Cost and Reconciliation repair APIs, to indicate that the specified operation should only be done on a single Cloud Store rather than all of them, which is the default behavior. Additionally, the Cloud Store keeps track of the Status of the Cloud Connection Diagnostics for each of the Cloud Cost and Reconciliation. The Cloud Connection Status is meant to be used as a tool in determining the health of the Cloud Connection that is the basis of each Cloud Store. The Cloud Connection Status has various failure states that are meant to provide actionable information on how to get your Cloud Connection running properly. These are the Cloud Connection Statuses:

* _INITIAL\_STATUS_: The zero value of Cloud Connection Status means that the cloud connection is untested. Once Cloud Connection Status has been changed and it should not return to this value. This status is assigned on creation to the Cloud Store
* _MISSING\_CONFIGURATION_: Kubecost has not detected any method of Cloud Configuration. This value is only possible on the first Cloud Store that is created as a wrapper for the open-source CSP. This status is assigned during failures in Configuration Retrieval.
* _INCOMPLETE\_CONFIGURATION_: Cloud Configuration is missing the required values to connect to the cloud provider. This status is assigned during failures in Configuration Retrieval.
* _FAILED\_CONNECTION_: All required Cloud Configuration values are filled in, but a connection with the CSP cannot be established. This is indicative of a typo in one of the Cloud Configuration values or an issue in how the connection was set up in the CSP's Console. The assignment of this status varies between CSPs but should happen if there if an error is thrown when an interaction with an object from the CSP's SDK occurs.
* _MISSING\_DATA_: The Cloud Integration is properly configured, but the CSP is not returning billing/cost and usage data. This status is indicative of the billing/cost and usage data export of the CSP being incorrectly set up or the export being set up in the last 48 hours and not having started populating data yet. This status is set when a query has been successfully made but the results come back empty. If the CSP already has a SUCCESSFUL\_CONNECTION status, then this status should not be set because this indicates that the specific query made may have been empty.
* _SUCCESSFUL\_CONNECTION_: The Cloud Integration is properly configured and returning data. This status is set on any successful query where data is returned

After starting or restarting Cloud Cost or Reconciliation, two subprocesses are started: one which fills in historic data over the coverage of the Daily Cloud Cost and Asset Store, and one which runs periodically on a predefined interval to collect and process new cost and usage data as it is made available by the CSP. The ETL's status endpoint contains a cloud object that provides information about each Cloud Store including the Cloud Connection Status and diagnostic information about Cloud Cost and Reconciliation. The diagnostic items on the Cloud Cost and Reconciliation are:

* Coverage: The window of time that the historical subprocess has covered
* LastRun: The last time that the process ran, updates each time the periodic subprocess runs
* NextRun: Next scheduled run of the periodic subprocess
* Progress: Ratio of Coverage to Total amount of time to be covered
* RefreshRate: The interval that the periodic subprocess runs
* Resolution: The window size of the process
* StartTime: When the Cloud Process was started
