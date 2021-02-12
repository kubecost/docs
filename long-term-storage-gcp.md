__Google Cloud Storage__

Start by [creating a new Google Cloud Storage bucket](https://cloud.google.com/storage/docs/creating-buckets). The following example uses a bucket named `thanos-bucket`. Next, download a service account JSON file from Google's service account manager ([steps](/google-service-account-thanos.md)).

Now create a yaml file named `object-store.yaml` in the following format, using your bucket name and service account details:

```yaml
type: GCS
config:
  bucket: "thanos-bucket"
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
**Note:** given that this is yaml, it requires this specific indention.

**Warning:** do not apply a retention policy to your Thanos bucket, as it will prevent Thanos compaction from completing.