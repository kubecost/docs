# Cluster Controller
Kubecost cluster controller enables actions like automated cluster scaledown and 1-click cluster resize. 
This document show you how to setup and enable this funtionality in the Kubecost product. 

Note: Cluster controller supports GKE and EKS clusters and is currently in **ALPHA**.

### GKE Setup

The following command performs the steps required to set up a service account.
[More info](https://github.com/kubecost/cluster-turndown/blob/master/scripts/README.md) 
    
```bash
/bin/bash -c "$(curl -fsSL https://github.com/kubecost/cluster-turndown/releases/latest/download/gke-create-service-key.sh)" -- <Project ID> <Service Account Name> <Namespace> cluster-controller-service-key
```

To use [this setup script](https://github.com/kubecost/cluster-turndown/blob/master/scripts/gke-create-service-key.sh) supply the following required parameters:

* **Project ID**: The GCP project identifier you can find via: `gcloud config get-value project`
* **Service Account Name**: The desired service account name to create, e.g. `kubecost-controller`
* **Namespace**: This should be the namespace which Kubecost will be installed, e.g `kubecost`
* **Secret Name**: This should always be set to `cluster-controller-service-key`, which is the secret name mounted by the Kubecost helm chart.

### EKS Setup

Create a new User with **AutoScalingFullAccess** permissions. Create a new file, service-key.json, and use the access key id and secret access key to fill out the following template:

```json
{
    "aws_access_key_id": "<ACCESS_KEY_ID>",
    "aws_secret_access_key": "<SECRET_ACCESS_KEY>"
}
```

Then run the following to create the secret:

```bash
$ kubectl create secret generic cluster-controller-service-key -n <NAMESPACE> --from-file=service-key.json
```

---

## Deploying
Once the secret has been successfully created containing the provider service key, 
you can enable the `cluster-controller` in the helm chart by finding the `clusterController` config block and setting `enabled: true`

```yaml
# Kubecost Cluster Controller for Right Sizing and Cluster Turndown
clusterController:
    enabled: true
```

You may also enable via `--set` when running helm install:
```bash
--set clusterController.enabled=true
```
