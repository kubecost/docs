To enable 90+ days of data retention in Kubecost, we recommend deploying with durable storage enabled. We provide two options for doing this: 1) in your cluster and 2) out of cluster. This functionality also powers the Enterprise multi-cluster view, where data across clusters can be viewed in aggregate, as well as simple backup & restore capabilities.

**Note:** this feature today requires an Enterprise license. 

## Option A: In cluster storage (Postgres)

To enable Postgres-based long-term storage, complete the following:

1. **Helm chart configuration** -- in [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) set the `remoteWrite.postgres.enabled` attribute 
to true. The default backing disk is `200gb` but this can also be directly configured in values.yaml. 
 
2. **Verify successful install** -- Deploy or upgrade via install instructions at <http://kubecost.com/install>, passing this updated values.yaml file, and verify pods with the prefix `kubecost-cost-analyzer-adapter`
and `kubecost-cost-analyzer-postgres` are Running.

3. **Confirm data is availabile**

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Vist this endpoint `http://<kubecost-address>/model/costDataModelRangeLarge`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Here's an example use: `http://localhost:9090/model/costDataModelRangeLarge`

## Option B: Out of cluster storage (Thanos)

Thanos-based durable storage provides long-term storage written directly to a user-controlled bucket (e.g. S3 or GCS bucket) and can be enabled with the following steps:

Step 1: **Create object store yaml file** 

This step creates a yaml file that contains your durable storage target (e.g. GCS, S3, etc.) configuration and access credentials. The details of this file are documented thoroughly in Thanos documentation: https://thanos.io/storage.md/

__Google Cloud Storage__

Start by creating a new Google Cloud Storage bucket, the following example uses a bucket named `thanos-bucket`. Next, download a service account JSON file from Google's service account manager ([instructions](/google-service-account-thanos.md)).

Now create a yaml file named `object-store.yaml` with contents similar to the following:

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

__AWS/S3__

Start by creating a new S3 bucket with all public access blocked. No other bucket configuration changes should be required. The following example uses a bucket named `kc-thanos-store`. See region to endpoint mappings here: https://docs.aws.amazon.com/general/latest/gr/rande.html#s3_region

Next, add an IAM policy to access this bucket ([instructions](/aws-service-account-thanos.md)).

Now create a yaml file named `object-store.yaml` with contents similar to the following:

```
type: S3
config:
  bucket: "kc-thanos-store"
  endpoint: "s3.amazonaws.com"
  region: "us-east-1"
  access_key: "AKIAXW6UVLRRTDSCCU4D"
  insecure: false
  signature_version2: false
  encrypt_sse: false
  secret_key: "<your-secret-key>"
  put_user_metadata: {}
  http_config:
    idle_conn_timeout: 90s
    response_header_timeout: 2m
    insecure_skip_verify: false
  trace:
    enable: true
  part_size: 134217728
```

**Note:** given that this is yaml, it requires this specific indention. 

Step 2: **Create object store secret**   

The final step prior to installation is to create a secret with the yaml file generated in the previous step:
```
$ kubectl create secret generic kubecost-thanos -n kubecost --from-file=./object-store.yaml
```

Step 3: **Deploying Kubecost with Thanos**

The Thanos subchart includes `thanos-bucket`, `thanos-query`, `thanos-store`,  `thanos-compact`, and service discovery for `thanos-sidecar`. These components are recommended when deploying Thanos on multiple clusters.

These values can be adjusted under the `thanos` block in `values-thanos.yaml` - Available options can be observed here: [thanos/values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/charts/thanos/values.yaml)

It's *important* to note that when running `helm install`, you must provide the base `values.yaml` followed by the override [values-thanos.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values-thanos.yaml). For example:

```
$ helm install kubecost/cost-analyzer \
    --name kubecost \
    --namespace kubecost \
    -f values.yaml \
    -f values-thanos.yaml
```

Your deployment should now have Thanos enabled!

<a name="verify-thanos"></a>
**Verify Installation**  
In order to verify a correct installation, start by ensuring all pods are running without issue. If the pods mentioned above are not running successfully, then view pod logs for more detail. A common error is as follows, which means you do not have the correct access to the supplied bucket: 

```
thanos-svc-account@project-227514.iam.gserviceaccount.com does not have storage.objects.list access to thanos-bucket., forbidden"
```

Assuming pods are running, use port forwarding to connect to the `thanos-query-http` endpoint:
```
$ kubectl port-forward svc/kubecost-thanos-query-http 8080:10902 --namespace kubecost
```
Then navigate to http://localhost:8080 in your browser. This page should look very similar to the Prometheus console.

![image](https://user-images.githubusercontent.com/334480/66616984-1076e480-eba1-11e9-8dd2-7c20541ad0b1.png)

If you navigate to the *Stores* using the top navigation bar, you should be able to see the status of both the `thanos-store` and `thanos-sidecar` which accompanied prometheus server:

![image](https://user-images.githubusercontent.com/334480/66617048-58960700-eba1-11e9-9f68-d007fcb11410.png)

Also note that the sidecar should identify with the unique `cluster_id` provided in your values.yaml in the previous step. Default value is `cluster-one`.

The default retention period for when data is moved into the object storage is currently *2h* - This configuration is based on Thanos suggested values. So it will be at least 2 hours before data is stored in the provided bucket. 

Instead of waiting *2h* to ensure that thanos was configured correctly, the default log level for the thanos workloads is `debug` (it's very light logging even on debug). You can get logs for the `thanos-sidecar`, which is part of the `prometheus-server` container, and `thanos-store`. The logs should give you a clear indication whether or not there was a problem consuming the secret and what the issue is. 
