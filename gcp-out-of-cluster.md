Kubecost provides the ability to allocate out of clusters costs, e.g. Cloud SQL instances and Cloud Storage buckets, back to Kubernetes concepts like namespace and deployment. All data remains on your cluster when using this functionality and is not shared externally.

The following guide provides the steps required for allocating out of cluster costs.

## Step 1: Enable billing data export

[https://cloud.google.com/billing/docs/how-to/export-data-bigquery](https://cloud.google.com/billing/docs/how-to/export-data-bigquery)

## Step 2:  Visit Kubecost setup page and provide configuration info

In Kubecost, visit the Cost Allocation page and select "Add Key".

![Add key](/add-key.png)

On the "Add Key" page, you will see instructions for providing a service key, project ID, and the BigQuery dataset that you have chosen to export data to:

Add a service key to allocate out of cluster resources (e.g. storage buckets and managed databases) back to their Kubernetes owners. The service account needs the following:
```
roles/bigquery.user
roles/compute.viewer
roles/bigquery.dataViewer
roles/bigquery.jobUser
```
If you don't already have a GCP service key, you can run the following commands in your command line to generate and export one. Make sure your gcloud project is where your external costs are being run. 

```sh
export PROJECT_ID=$(gcloud config get-value project)
gcloud iam service-accounts create compute-viewer-kubecost --display-name "Compute Read Only Account Created For Kubecost" --format json
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/compute.viewer
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.user
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.dataViewer
gcloud projects add-iam-policy-binding $PROJECT_ID --member serviceAccount:compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com --role roles/bigquery.jobUser
gcloud iam service-accounts keys create ./compute-viewer-kubecost-key.json --iam-account compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com 
```

You can then get your service account key to paste into the UI (be careful with this!):
```sh
 cat compute-viewer-kubecost-key.json 
```

Then, follow the remaining instructions found at the "Add Key" link:

![GCP out of cluster key entry](/images/gcp-out-of-cluster-config-wo-shell.png)


<a name="bq-name"></a>**BigQuery dataset** requires a BigQuery dataset prefix (e.g. billing_data) in addition to the BigQuery table name. A full example is `billing_data.gcp_billing_export_v1_018AIF_74KD1D_534A2`.

These config values can alternatively be provided via a [values file](https://github.com/kubecost/cost-analyzer-helm-chart/blob/c10e9475b51612d36da8f04618174a98cc62f8fd/cost-analyzer/values.yaml#L572-L574).

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

> Note: Google generates special labels for GKE resources (e.g. "goog-gke-node", "goog-gke-volume"). Values with these labels are excluded from out-of-cluster costs because Kubecost already includes them as in-cluster assets. Thus, to make sure all cloud assets are included, we recommend installing Kubecost on each cluster where insights into costs are required.
