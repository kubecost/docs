GCP Cloud Integration
=====================

Kubecost provides the ability to allocate out of cluster costs, e.g. Cloud SQL instances and Cloud Storage buckets, back to Kubernetes concepts like namespace and deployment.

Read the [Cloud Integrations](https://github.com/kubecost/docs/blob/main/cloud-integration.md) documentation for more information on how Kubecost connects with Cloud Service Providers.

The following guide provides the steps required for allocating out-of-cluster costs in GCP.

> **Note**: A GitHub repository with sample files used in below instructions can be found here: [https://github.com/kubecost/poc-common-configurations/tree/main/gcp](https://github.com/kubecost/poc-common-configurations/tree/main/gcp)

## Step 1: Enable billing data export

[https://cloud.google.com/billing/docs/how-to/export-data-bigquery](https://cloud.google.com/billing/docs/how-to/export-data-bigquery)

GCP users should create [detailed billing export](https://cloud.google.com/billing/docs/how-to/export-data-bigquery-tables#detailed-usage-cost-data-schema) to gain access to all of Kubecost cloud integration features including [reconciliation](https://github.com/kubecost/docs/blob/main/cloud-integration.md#reconciliation)

## Step 2:  Visit Kubecost setup page and provide configuration info


> **Note:** If you are using the alternative [multi-cloud integration](/install-and-configure/advanced-configuration/cloud-integration/multi-cloud) method, Step 2 is not required.

If your Big Query dataset is in a different project than the one where Kubecost is installed, please see the section on [Cross-Project Service Accounts](#cross-project-service-account-configuration)

Add a service account key to allocate out of cluster resources (e.g. storage buckets and managed databases) back to their Kubernetes owners. The service account needs the following:

```
roles/bigquery.user
roles/compute.viewer
roles/bigquery.dataViewer
roles/bigquery.jobUser
```

If you don't already have a GCP service account with the appropriate rights, you can run the following commands in your command line to generate and export one. Make sure your gcloud project is where your external costs are being run.

```sh
export PROJECT_ID=$(gcloud config get-value project)
gcloud iam service-accounts create compute-viewer-kubecost --display-name "Compute Read Only Account Created For Kubecost" --format json
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/compute.viewer
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.user
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.dataViewer
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.jobUser
```

Once you've created the GCP service account, you can connect it to Kubecost in one of two ways:

### Connect using Workload Identity federation (recommended)
You can set up an [IAM policy binding](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity#authenticating_to) to bind a Kubernetes service account to your GCP service account.
```sh
gcloud iam service-accounts add-iam-policy-binding compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/iam.workloadIdentityUser --member "serviceAccount:$PROJECT_ID.svc.id.goog[NAMESPACE/KSA_NAME]"
```
where `NAMESPACE` and `KSA_NAME` are the namespace Kubecost is installed into and the name of the service account attributed to the Kubecost deployment

You will also need to enable the [IAM Service Account Credentials API](https://cloud.google.com/iam/docs/reference/credentials/rest) in the gcloud project.

### Connect using a service account key
Create a service account key:
```sh
gcloud iam service-accounts keys create ./compute-viewer-kubecost-key.json --iam-account compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com
```

Once the GCP service account has been connected, set up the remaining configuration parameters:

### Configuring via the Kubecost UI
In Kubecost, select _Settings_ from the left navigation, and under External Cloud Cost Configuration (GCP), select _Update_, then follow the remaining instructions found at the "Add Key" link:

![GCP out-of-cluster key entry](https://raw.githubusercontent.com/kubecost/docs/main/images/gcp-out-of-cluster-config-wo-shell.png)

<a name="bq-name"></a>**BigQuery dataset** requires a BigQuery dataset prefix (e.g. billing_data) in addition to the BigQuery table name. A full example is `billing_data.gcp_billing_export_v1_018AIF_74KD1D_534A2`

<a name="bq-name"></a>**Service key** If you've connected using Workload Identity federation, you should leave this box empty. If you've created a service account key, copy the contents of the `compute-viewer-kubecost-key.json` file and paste them here (be careful with this!)

### Configuring using values.yaml (Recommended)

It is recommended to provide the GCP details in the [values file](https://github.com/kubecost/cost-analyzer-helm-chart/blob/c10e9475b51612d36da8f04618174a98cc62f8fd/cost-analyzer/values.yaml#L572-L574) to ensure they are retained during an upgrade or redeploy.

* Set `.Values.kubecostProductConfigs.projectID = <GCP Project ID that contains the BigQuery Export>`
* Set `.Values.kubecostProductConfigs.bigQueryBillingDataDataset = <DATASET.TABLE_NAME that contains the billing export>`

If you've connected using Workload Identity federation:
* Set `.Values.nodeSelector = iam.gke.io/gke-metadata-server-enabled: "true"` to update the Kubecost deployment to run on nodes that use Workload Identity
* Set `.Values.serviceAccount.annotations = iam.gke.io/gcp-service-account: compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com` where $PROJECT_ID defined in the `gcloud` commands above

Otherwise, if you've connected using a service account key, create a secret for the GCP service account key you've created:
```sh
kubectl create secret generic gcp-secret -n kubecost --from-file=./compute-viewer-kubecost-key.json
```
Then, set `.Values.kubecostProductConfigs.gcpSecretName = <Name of the Kubernetes secret that contains the compute-viewer-kubecost-key.json file>`

> **Note**: When managing the service account key as a Kubernetes secret, the secret must reference the service account key json file, and that file must be named `compute-viewer-kubecost-key.json`.

## Step 3: Label cloud assets

You can now label assets with the following schema to allocate costs back to their appropriate Kubernetes owner.
Learn more [here](https://cloud.google.com/compute/docs/labeling-resources#adding_or_updating_labels_to_existing_resources) on updating GCP asset labels.

<pre>
Cluster:    "kubernetes_cluster" :   &lt;clusterID>
Namespace:  "kubernetes_namespace" : &lt;namespace>
Deployment: "kubernetes_deployment": &lt;deployment>
Label:      "kubernetes_label_NAME": &lt;label>
Pod:        "kubernetes_pod":        &lt;pod>
Daemonset:  "kubernetes_daemonset":  &lt;daemonset>
Container:  "kubernetes_container":  &lt;container>
</pre>

To use an alternative or existing label schema for GCP cloud assets, you may supply these in your [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) under the "kubecostProductConfigs.labelMappingConfigs.\<aggregation\>\_external_label"

> **Note**: Google generates special labels for GKE resources (e.g. "goog-gke-node", "goog-gke-volume"). Values with these labels are excluded from out-of-cluster costs because Kubecost already includes them as in-cluster assets. Thus, to make sure all cloud assets are included, we recommend installing Kubecost on each cluster where insights into costs are required.

### Viewing project-level labels

Project-level labels are applied to all the Assets built from resources defined under a given GCP project. You can filter GCP resources in the Kubecost Assets View (or API) by project-level labels by adding them ('label:value') in the Label/Tag filter.

If a resource has a label with the same name as a project-level label, the resource label value will take precedence.

Modifications incurred on project-level labels may take several hours to update on Kubecost.

## Cross-Project Service Account Configuration

Due to organizational constraints, it is common that Kubecost must be run in a separate project from the project containing the billing data Big Query dataset which is needed for Cloud Integration. It is still possible to configure Kubecost in this scenario, but some of the values in the above script will need to be changed. First you will need the project id of the projects where Kubecost is installed and where the Big Query dataset is located. Additionally you will need a `gcloud` user with the permissions `iam.serviceAccounts.setIamPolicy` for the kubecost project and the ability to manage the roles listed above for the Big Query Project. With these fill in the following script to set the relevant variables:

```sh
export KUBECOST_PROJECT_ID=<Project ID where kubecost is installed>
export BIG_QUERY_PROJECT_ID=<Project ID where bigquery data is stored>
export SERVICE_ACCOUNT_NAME=<Unique name for your service account>
```

Once these values have been set, this script can be run and will create the service account needed for this configuration.

```sh
gcloud config set project KUBECOST_PROJECT_ID
gcloud iam service-accounts create $SERVICE_ACCOUNT_NAME --display-name "Cross Project CUR" --format json
gcloud projects add-iam-policy-binding $BIG_QUERY_PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT_NAME@$KUBECOST_PROJECT_ID.iam.gserviceaccount.com --role roles/compute.viewer
gcloud projects add-iam-policy-binding $BIG_QUERY_PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT_NAME@$KUBECOST_PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.user
gcloud projects add-iam-policy-binding $BIG_QUERY_PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT_NAME@$KUBECOST_PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.dataViewer
gcloud projects add-iam-policy-binding $BIG_QUERY_PROJECT_ID --member serviceAccount:$SERVICE_ACCOUNT_NAME@$KUBECOST_PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.jobUser
```

Now that your service account is created, follow the normal configuration instructions.

## Common configuration issues:
* Account labels not showing up in partitions: there are cases where labels applied at the account label do not show up in the date-partitioned data. If account level labels are not showing up, you can switch to querying them unpartitioned by setting an extraEnv in kubecost of name: GCP_ACCOUNT_LABELS_NOT_PARTITIONED  value: true: https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.98.0-rc.1/cost-analyzer/values.yaml#L304
