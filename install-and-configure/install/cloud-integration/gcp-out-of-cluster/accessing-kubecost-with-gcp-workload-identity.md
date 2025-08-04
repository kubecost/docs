# Accessing Kubecost with GCP Workload Identity

Certain features of Kubecost, including Savings Insights like Orphaned Resources and Reserved Instances, require access to the cluster's GCP account. This is usually indicated by a 403 error from Google APIs which is due to 'insufficient authentication scopes'. Viewing this error in the Kubecost UI will display the cause of the error as `"ACCESS_TOKEN_SCOPE_INSUFFICIENT"`.

To obtain access to these features, follow this tutorial which will show you how to configure your Google IAM Service Account and Workload Identity for your application.

## Creating a GCP IAM Service Account

### 1. Creating an API Key

Go to your GCP Console and select _APIs & Services_ > _Credentials_ from the left navigation. Select _+ Create Credentials_ > _API Key_.

On the Credentials page, select the icon in the Actions column for your newly-created API key, then select _Edit API key_. The Edit API key page opens.

Under ‘API restrictions’, select _Restrict key_, then from the dropdown, select only _Cloud Billing API_. Select _OK_ to confirm. Then select _Save_ at the bottom of the page.

### 2. Configuring Workload Identity

From here, consult Google Cloud's guide [Use Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity) to perform the following steps:

* Enable Workload Identity on an existing GCP cluster, or spin up a new cluster which will have Workload Identity enabled by default
* Migrate any existing workloads to Workload Identity
* Configure your applications to use Workload Identity
* Create both a Kubernetes service account (KSA) and an IAM service account (GSA).
* Annotate the KSA with the email of the GSA.
* Update your pod spec to use the annotated KSA, and ensure all nodes on that workload use Workload Identity.

You can stop once you have modified your pod spec (before 'Verify the Workload Identity Setup'). You should now have a GCP cluster with Workload Identity enabled, and both a KSA and a GSA, which are connected via the role `roles/iam.workloadIdentityUser`.

### 3. Updating your IAM service account

{% tabs %}
{% tab title="Console" %}
In the GCP Console, select _IAM & Admin_ > _IAM_. Find your newly-created GSA and select the _Edit Principal_ pencil icon. You will need to provide the following roles to this service account:

* BigQuery Data Viewer
* BigQuery Job User
* BigQuery User
* Compute Viewer
* Service Account Token Creator

Select _Save_.
{% endtab %}

{% tab title="gcloud" %}
The following roles need to be added to your IAM service account:

* `roles/bigquery.user`
* `roles/compute.viewer`
* `roles/bigquery.dataViewer`
* `roles/bigquery.jobUser`
* `roles/iam.serviceAccountTokenCreator`

Use this command to add each role individually to the GSA:

{% code overflow="wrap" %}
```bash
gcloud projects add-iam-policy-binding --member=serviceAccount:<your-iam-service-account-email>@<your-project>.iam.gserviceaccount.com --role=<role/foo.bar>
```
{% endcode %}
{% endtab %}
{% endtabs %}

From here, restart the pod(s) to confirm your changes. You should now have access to all expected Kubecost functionality through your service account with Identity Workload.
