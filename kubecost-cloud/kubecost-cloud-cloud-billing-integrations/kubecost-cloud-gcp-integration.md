# Kubecost Cloud GCP Integration

{% hint style="info" %}
This documentation should only be consulted when using Kubecost Cloud. For information about the configuring a GCP integration with self-hosted Kubecost, see [here](/install-and-configure/install/cloud-integration/gcp-out-of-cluster/README.md).
{% endhint %}

Kubecost Cloud provides the ability to allocate out of cluster (OOC) costs back to Kubernetes concepts like namespaces and deployments. The following guide provides the steps required for allocating OOC costs in GCP.

## Prerequisites

Before you interact with Kubecost Cloud, you will need to export your cloud billing data in GCP to BigQuery. For help, consult [Google's documentation](https://cloud.google.com/billing/docs/how-to/export-data-bigquery) on the subject.

After this, it is also recommend to use a [detailed billing export](https://cloud.google.com/billing/docs/how-to/export-data-bigquery-tables#detailed-usage-cost-data-schema) in order to gain access to Kubecost's cloud integration functionality such as reconciliation for the most accurate spend data.

You will need to prepare the following fields:

* GCP Project Id: The ID of your GCP project.
* GCP Dataset: BigQuery dataset prefix
* GCP Table: BigQuery table name.

If you are having trouble determining these values, consider this example. A dataset `billing_data.gcp_billing_export_v1_018AIF_74KD1D_534A2` under a project `project-1` will have the following values:

* Project ID: `project-1`
* Dataset Name: `billing_data`
* Table: `gcp_billing_export_v1_018AIF_74KD1D_534A2`

## Adding an integration

In the Kubecost Cloud UI, begin by selecting _Settings_ in the left navigation. Scroll down to Cloud Integrations, then select _View Additional Details_. The Cloud Integrations dashboard opens. Select _+ Add Integration_. Then, select _GCP Integration_ from the slide panel.

### Step 1: Enable billing data export

After completing the Prerequisites section, you will fill out the three fields in this step with the respective values (Project Id, Dataset, and Table). All fields are mandatory. Then, select _Continue._

### Step 2: Create a GCP service account

You will need to give your Kubecost GCP service account certain permissions in your project `roles/bigquery.jobUser`. This can be performed either through the [gcloud CLI](https://cloud.google.com/sdk/gcloud) or the GCP Console. Follow the instructions as they appear directly in the UI. Then, select Continue.

### Step 3: Assign Kubecost service account access to BigQuery dataset

Finally, you must give the Kubecost service account direct access to your BigQuery dataset via the BigQuery Data Viewer role. Like Step 2, this can be performed either through the gcloud CLI or the GCP Console. Follow the instructions as they appear directly in the UI. Then, select Continue.

### Finalizing your integration

After completing Step 3, you will see an overview of details for your integration. You can correct any details by selecting _Edit_. The Status should initially display as Unknown. This is normal. If everything looks correct, select _Close_ to return to the Cloud Integrations dashboard. Your integration will now appear as a line item.
