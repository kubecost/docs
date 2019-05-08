Kubecost provides the ability to allocate out of clusters costs, e.g. Cloud SQL instances and Cloud Storage buckets, back to Kubernetes concepts like namespace and deployment. All data remains on your cluster when using this functionality and is not shared externally.

The following guide provides the steps required for allocating out of cluster costs.

## Step 1: Enable billing data export

https://cloud.google.com/billing/docs/how-to/export-data-bigquery

## Step 2:  Visit Kubecost setup page and provide configuration info

In Kubecost, vist the Cost Allocation page and select "Add Key".
On this page, you will see instructions for providing a service key, project ID, and the Big Query dataset that you have chosen to export data to.

[SCREENSHOT TO COME]


## Step 3: Label cloud assets

You can now label assets with the following schema to allocate costs back to their appropriate Kubernetes owner. 
Learn more [here](https://cloud.google.com/compute/docs/labeling-resources) on GCP labeling.

<pre>
Namespace:  "kubernetes_namespace" : &lt;namespace>
Deployment: "kubernetes_deployment": &lt;deployment>
Pod:        "kubernetes_pod":        &lt;pod>
Daemonset:  "kubernetes_daemonset":  &lt;daemonset>
Container:  "kubernetes_container":  &lt;container>
</pre>
