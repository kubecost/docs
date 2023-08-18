# GCP Cloud Integration

Kubecost provides the ability to allocate out-of-cluster (OOC) costs, e.g. Cloud SQL instances and Cloud Storage buckets, back to Kubernetes concepts like namespaces and deployments.

Read the [Cloud Billing Integrations](cloud-integration.md) doc for more information on how Kubecost connects with cloud service providers.

The following guide provides the steps required for allocating OOC costs in GCP.

{% hint style="info" %}
A GitHub repository with sample files used in the below instructions can be found [here](https://github.com/kubecost/poc-common-configurations/tree/main/gcp).
{% endhint %}

## Step 1: Enable billing data export

Begin by reviewing [Google's documentation](https://cloud.google.com/billing/docs/how-to/export-data-bigquery) on exporting cloud billing data to BigQuery.

GCP users must create a [detailed billing export](https://cloud.google.com/billing/docs/how-to/export-data-bigquery-tables#detailed-usage-cost-data-schema) to gain access to all Kubecost CloudCost features including [reconciliation](cloud-integration.md#reconciliation). Exports of type "Standard usage cost data" and "Pricing Data" do not have the correct information to support CloudCosts.

## Step 2: Create a GCP service account

{% hint style="info" %}
If you are using the alternative [multi-cloud integration](multi-cloud.md) method, Step 2 is not required.
{% endhint %}

If your Big Query dataset is in a different project than the one where Kubecost is installed, please see the section on [Cross-Project Service Accounts](gcp-out-of-cluster.md#cross-project-service-account-configuration).

Add a service account key to allocate OOC resources (e.g. storage buckets and managed databases) back to their Kubernetes owners. The service account needs the following:

```
roles/bigquery.user
roles/compute.viewer
roles/bigquery.dataViewer
roles/bigquery.jobUser
```

If you don't already have a GCP service account with the appropriate rights, you can run the following commands in your command line to generate and export one. Make sure your GCP project is where your external costs are being run.

```
export PROJECT_ID=$(gcloud config get-value project)
gcloud iam service-accounts create compute-viewer-kubecost --display-name "Compute Read Only Account Created For Kubecost" --format json
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/compute.viewer
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.user
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.dataViewer
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.jobUser
```

## Step 3: Connecting GCP service account to Kubecost

After creating the GCP service account, you can connect it to Kubecost in one of two ways before configuring:

### Option 3.1: Connect using Workload Identity Federation (recommended)

You can set up an [IAM policy binding](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#authenticating\_to) to bind a Kubernetes service account to your GCP service account as seen below, where:

* `NAMESPACE` is the namespace Kubecost is installed into
* `KSA_NAME` is the name of the service account attributed to the Kubecost deployment

{% code overflow="wrap" %}
```
gcloud iam service-accounts add-iam-policy-binding compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/iam.workloadIdentityUser --member "serviceAccount:$PROJECT_ID.svc.id.goog[NAMESPACE/KSA_NAME]"
```
{% endcode %}

You will also need to enable the [IAM Service Account Credentials API](https://cloud.google.com/iam/docs/reference/credentials/rest) in the GCP project.

### Option 3.2: Connect using a service account key

Create a service account key:

{% code overflow="wrap" %}
```
gcloud iam service-accounts keys create ./compute-viewer-kubecost-key.json --iam-account compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com
```
{% endcode %}

Once the GCP service account has been connected, set up the remaining configuration parameters.

## Step 4. Configuring GCP for Kubecost

You're almost done. Now it's time to configure Kubecost to finalize your connectivity.

### Option 4.1: Configuring using values.yaml (recommended)

It is recommended to provide the GCP details in your [_values.yaml_](https://github.com/kubecost/cost-analyzer-helm-chart/blob/c10e9475b51612d36da8f04618174a98cc62f8fd/cost-analyzer/values.yaml#L572-L574) to ensure they are retained during an upgrade or redeploy. First, set the following configs:

```yaml
kubecostProductConfigs:
  projectID: "$PROJECT_ID"
  bigQueryBillingDataDataset: "YOUR_DATASET.YOUR_TABLE_NAME"
```

If you've connected using Workload Identity Federation, add these configs:

{% code overflow="wrap" %}
```yaml
# Ensure Kubecost deployment runs on nodes that use Workload Identity
nodeSelector:
  iam.gke.io/gke-metadata-server-enabled: "true"
# Add annotations to all kubecost-related serviceaccounts
serviceAccount:
  annotations:
    iam.gke.io/gcp-service-account: "compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com"
```
{% endcode %}

Otherwise, if you've connected using a service account key, create a secret for the GCP service account key you've created and add the following configs:

{% code overflow="wrap" %}
```sh
kubectl create secret generic gcp-secret -n kubecost --from-file=./compute-viewer-kubecost-key.json
```
{% endcode %}

```yaml
kubecostProductConfigs:
  gcpSecretName: "gcp-secret"
```

{% hint style="info" %}
When managing the service account key as a Kubernetes secret, the secret must reference the service account key JSON file, and that file must be named _compute-viewer-kubecost-key.json_.
{% endhint %}

### Option 4.2: Configuring via the Kubecost UI

In Kubecost, select _Settings_ from the left navigation, and under Cloud Integrations, select _Add Cloud Integration > GCP_, then provide the relevant information in the GCP Billing Data Export Configuration window:

* **GCP Service Key**: If you've connected using Workload Identity Federation in Step 3, you should leave this box empty. If you've created a service account key, copy the contents of the _compute-viewer-kubecost-key.json_ file and paste them here.
* **GCP Project Id**: The ID of your GCP project.
* **GCP Billing Database:** Requires a BigQuery dataset prefix (e.g. `billing_data`) in addition to the BigQuery table name. A full example is `billing_data.gcp_billing_export_resource_v1_XXXXXX_XXXXXX_XXXXX`

{% hint style="warning" %}
Be careful when handling your service key! Ensure you have entered it correctly into Kubecost. Don't lose it or let it become publicly available.
{% endhint %}

## Step 5: Label cloud assets

You can now label assets with the following schema to allocate costs back to their appropriate Kubernetes owner. Learn more [here](https://cloud.google.com/compute/docs/labeling-resources#adding\_or\_updating\_labels\_to\_existing\_resources) on updating GCP asset labels.

```
Cluster:    "kubernetes_cluster" :   <clusterID>
Namespace:  "kubernetes_namespace" : <namespace>
Deployment: "kubernetes_deployment": <deployment>
Label:      "kubernetes_label_NAME": <label>
Pod:        "kubernetes_pod":        <pod>
Daemonset:  "kubernetes_daemonset":  <daemonset>
Container:  "kubernetes_container":  <container>
```

To use an alternative or existing label schema for GCP cloud assets, you may supply these in your [_values.yaml_](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) under the `kubecostProductConfigs.labelMappingConfigs.<aggregation>_external_label`.

{% hint style="info" %}
Google generates special labels for GKE resources (e.g. "goog-gke-node", "goog-gke-volume"). Values with these labels are excluded from OOC costs because Kubecost already includes them as in-cluster assets. Thus, to make sure all cloud assets are included, we recommend installing Kubecost on each cluster where insights into costs are required.
{% endhint %}

### Viewing project-level labels

Project-level labels are applied to all the Assets built from resources defined under a given GCP project. You can filter GCP resources in the Kubecost [Cloud Costs Explorer](https://docs.kubecost.com/using-kubecost/getting-started/cloud-costs-explorer) (or [API](https://docs.kubecost.com/apis/apis-overview/cloud-cost-api)).

If a resource has a label with the same name as a project-level label, the resource label value will take precedence.

Modifications incurred on project-level labels may take several hours to update on Kubecost.

## Cross-project service account configuration

Due to organizational constraints, it is common that Kubecost must be run in a separate project from the project containing the billing data Big Query dataset, which is needed for Cloud Integration. Configuring Kubecost in this scenario is still possible, but some of the values in the above script will need to be changed. First, you will need the project id of the projects where Kubecost is installed, and the Big Query dataset is located. Additionally, you will need a GCP user with the permissions `iam.serviceAccounts.setIamPolicy` for the Kubecost project and the ability to manage the roles listed above for the Big Query Project. With these, fill in the following script to set the relevant variables:

```
export KUBECOST_PROJECT_ID=<Project ID where kubecost is installed>
export BIG_QUERY_PROJECT_ID=<Project ID where bigquery data is stored>
export SERVICE_ACCOUNT_NAME=<Unique name for your service account>
```

Once these values have been set, this script can be run and will create the service account needed for this configuration.

{% code overflow="wrap" %}
```
gcloud config set project $KUBECOST_PROJECT_ID
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME --display-name "Cross Project CUR" --format json
gcloud projects add-iam-policy-binding $BIG_QUERY_PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT_NAME@$KUBECOST_PROJECT_ID.iam.gserviceaccount.com --role roles/compute.viewer
gcloud projects add-iam-policy-binding $BIG_QUERY_PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT_NAME@$KUBECOST_PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.user
gcloud projects add-iam-policy-binding $BIG_QUERY_PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT_NAME@$KUBECOST_PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.dataViewer
gcloud projects add-iam-policy-binding $BIG_QUERY_PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT_NAME@$KUBECOST_PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.jobUser
```
{% endcode %}

Now that your service account is created follow the normal configuration instructions.

## Troubleshooting

#### Account labels not showing up in partitions

In some cases, labels applied at the account label do not show up in the date-partitioned data. If account level labels are not showing up, you can switch to querying them unpartitioned by setting an extraEnv in Kubecost: `GCP_ACCOUNT_LABELS_NOT_PARTITIONED: true`. See [here](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.98.0-rc.1/cost-analyzer/values.yaml#L304).
