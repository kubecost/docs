Kubecost provides the ability to allocate out of clusters costs, e.g. Cloud SQL instances and Cloud Storage buckets, back to Kubernetes concepts like namespace and deployment. All data remains on your cluster when using this functionality and is not shared externally.

The following guide provides the steps required for allocating out of cluster costs.

## Step 1: Enable billing data export

[https://cloud.google.com/billing/docs/how-to/export-data-bigquery](https://cloud.google.com/billing/docs/how-to/export-data-bigquery)

## Step 2:  Visit Kubecost setup page and provide configuration info

In Kubecost, visit the Cost Allocation page and select "Add Key".

![Add key](/add-key.png)

On this page, you will see instructions for providing a service key, project ID, and the BigQuery dataset that you have chosen to export data to.

![GCP out of cluster](/gcp-out-of-cluster-config.png)


<a name="bq-name"></a>**BigQuery dataset** requires a BigQuery dataset prefix (e.g. billing_data) in addition to the BigQuery table name. A full example is `billing_data.gcp_billing_export_v1_018AIF_74KD1D_534A2`.

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

To use an alternative or existing label schema for GCP cloud assets, you may supply these in your [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml#L403-L414).
