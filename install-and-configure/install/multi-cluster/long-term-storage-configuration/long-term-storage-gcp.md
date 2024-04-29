# GCP Multi-Cluster Storage Configuration

{% hint style="info" %}
Usage of a Federated Storage Bucket is only supported for Kubecost Enterprise plans.
{% endhint %}

Start by [creating a new Google Cloud Storage bucket](https://cloud.google.com/storage/docs/creating-buckets). The following example uses a bucket named `kubecost-federated-storage-bucket`. Next, download a service account JSON file from Google's service account manager ([steps](/install-and-configure/install/cloud-integration/gcp-out-of-cluster/google-service-account-thanos.md)).

Now create a YAML file named `federated-store.yaml` in the following format, using your bucket name and service account details:

```yaml
type: GCS
config:
  bucket: "kubecost-federated-storage-bucket"
  service_account: |-
    {
      "type": "service_account",
      "project_id": "...",
      "private_key_id": "...",
      "private_key": "...",
      "client_email": "...",
      "client_id": "...",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": ""
    }
```
