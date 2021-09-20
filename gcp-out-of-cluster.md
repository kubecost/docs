GCP Out of Cluster
==================

Kubecost provides the ability to allocate out of clusters costs, e.g. Cloud SQL instances and Cloud Storage buckets, back to Kubernetes concepts like namespace and deployment. All data remains on your cluster when using this functionality and is not shared externally.

The following guide provides the steps required for allocating out of cluster costs.

## Step 1: Enable billing data export

[https://cloud.google.com/billing/docs/how-to/export-data-bigquery](https://cloud.google.com/billing/docs/how-to/export-data-bigquery)

## Step 2:  Visit Kubecost setup page and provide configuration info


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
gcloud iam service-accounts keys create ./compute-viewer-kubecost-key.json --iam-account compute-viewer-kubecost@$PROJECT_ID.iam.gserviceaccount.com 
```

You can then get your service account key to paste into the UI (be careful with this!):
```sh
 cat compute-viewer-kubecost-key.json 
```

In Kubecost, navigate to the settings page and click "update" for the "External Cloud Cost Configuration (GCP)" setting, then follow the remaining instructions found at the "Add Key" link:

![GCP out of cluster key entry](https://raw.githubusercontent.com/kubecost/docs/master/images/gcp-out-of-cluster-config-wo-shell.png)


<a name="bq-name"></a>**BigQuery dataset** requires a BigQuery dataset prefix (e.g. billing_data) in addition to the BigQuery table name. A full example is `billing_data.gcp_billing_export_v1_018AIF_74KD1D_534A2`.

### Configuring using values.yaml (Recommended)

We recommending providing the GCP details in the [values file](https://github.com/kubecost/cost-analyzer-helm-chart/blob/c10e9475b51612d36da8f04618174a98cc62f8fd/cost-analyzer/values.yaml#L572-L574)  to ensure they are retained during a upgrade or redeploy.

* Set `.Values.kubecostProductConfigs.projectID = <GCP Project ID that contains the BigQuery Export>`
* Set `.Values.kubecostProductConfigs.gcpSecretName = <Name of the Kubernetes secret that contains the compute-viewer-kubecost-key.json file>`
* Set `.Values.kubecostProductConfigs.bigQueryBillingDataDataset = <DATASET.TABLE_NAME that contains the billing export>`

Create a secret for the GCP service account key
> Note: When managing the service account key as a Kubernetes secret, the secret must reference the service account key json file, and that file must be named `compute-viewer-kubecost-key.json`.

``` sh
kubectl create secret generic gcp-secret -n kubecost --from-file=./compute-viewer-kubecost-key.json
```

## Step 3: Label cloud assets

You can now label assets with the following schema to allocate costs back to their appropriate Kubernetes owner.
Learn more [here](https://cloud.google.com/compute/docs/labeling-resources#adding_or_updating_labels_to_existing_resources) on updating GCP asset labels.

<pre>
Cluster:    "kubernetes_cluster" :   clusterID>
Namespace:  "kubernetes_namespace" : namespace>
Deployment: "kubernetes_deployment": deployment>
Label:      "kubernetes_label_NAME": label>
Pod:        "kubernetes_pod":        pod>
Daemonset:  "kubernetes_daemonset":  daemonset>
Container:  "kubernetes_container":  container>
</pre>

To use an alternative or existing label schema for GCP cloud assets, you may supply these in your [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) under the "kubecostProductConfigs.labelMappingConfigs.\<aggregation\>\_external_label" 

> Note: Google generates special labels for GKE resources (e.g. "goog-gke-node", "goog-gke-volume"). Values with these labels are excluded from out-of-cluster costs because Kubecost already includes them as in-cluster assets. Thus, to make sure all cloud assets are included, we recommend installing Kubecost on each cluster where insights into costs are required.

Edit this doc on [Github](https://github.com/kubecost/docs/blob/main/gcp-out-of-cluster.md)

<!--- {"article":"4407601816087","section":"4402815680407","permissiongroup":"1500001277122"} --->