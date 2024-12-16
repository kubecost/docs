# GCP/Kubecost Data Audit

## Performing a cluster data audit

First, in the Kubecost UI, view the price of a single node for a single day. This can be done on the [Assets](/using-kubecost/navigating-the-kubecost-ui/assets.md) page by modifying your query with the following requests:

* Select the window range picker and select *Today*
* Select *Filter* and add the filters *Provider is "GCP"* and *Asset Type is "node"*.

![Node cost details](/images/data-auditing/gcp-kubecost-gke-asset.png)

Next, compare this instance's costs with what is found in the GCP export via BigQuery. Use the providerID that's in Kubecost for the node as the `resource.name` in the following query:

```sql
SELECT
  TIMESTAMP_TRUNC(usage_start_time, day) as usage_date, 
  service.description as service,
  resource.name as resource,
  SUM(cost) as cost,
  SUM(cost_at_list) as list_cost,
  ARRAY_CONCAT_AGG(credits) as credits,
  -- OPTIONAL: Use the below line to SUM the credits associated with each resource
  SUM((SELECT SUM(credit.amount) FROM UNNEST(credits) credit)) as total_credits
FROM detailedbilling.gcp_billing_export_resource_v1_0121AC_C6F51B_690771
WHERE 
  usage_start_time >= "2024-03-24" 
  AND usage_start_time < "2024-03-25"
  AND resource.name like '%gke-kc-demo-stage-pool-2-70aa2479-y0yv'
GROUP BY
  usage_date,
  service,
  resource
```

![BigQuery Output](/images/data-auditing/dataaudit-gcp-bigquery-output.png)

{% hint style="info" %}
The example above is auditing the GKE nodes associated with the cluster. BigQuery will return additional items such as network costs and costs associated with the node pool, however you should focus on GKE nodes only.
{% endhint %}

## Performing an Audit against GCP resources (services)

Navigate to the Cloud Cost Explorer page. choose a window with a start date (*Select Start*) and end date (*Select End*) only 24 hours apart from each other, where the end date is greater than 48 hours in the past. Then, select *Filter* and add the filters *Provider is "GCP"* and *Account ID is "<account-name>"*.

![Aggregated by service. Filtered by Provider and Account ID](/images/data-auditing/kubecost-gcp-services.png)

Next, compare the costs of services for the same account in the GCP billing console.

{% hint style="info" %}
Total costs aren't always precise and may have a deviation of 1-2%.
{% endhint %}

![GCP Billing Console](/images/data-auditing/dataaudit-gcp-console.png)
