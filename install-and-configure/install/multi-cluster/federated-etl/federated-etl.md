# ETL Federation (preferred)

{% hint style="info" %}
Federated ETL is only supported for Kubecost Enterprise plans. If you are using
a version of Kubecost before v2.0, please refer to a version of this
documentation before January, 2024.
{% endhint %}

Federated extract, transform, load (ETL) is Kubecost's method to aggregate all cluster information back to a single display described in our [Multi-Cluster](/install-and-configure/install/multi-cluster/multi-cluster.md#enterprise-federation) doc. Federated ETL gives teams the benefit of combining multiple Kubecost installations into one view.

There are two primary advantages for using ETL Federation:

1. For environments that already have a Prometheus instance, Kubecost only requires a single pod per monitored cluster
2. Many solutions that aggregate Prometheus metrics (like Thanos), are often expensive to scale in large environments

## Kubecost ETL Federation diagram

TODO: Update this diagram
![ETL Federation Overview](/images/kubecost-ETL-Federated-Architecture.png)

## Sample configurations

This guide has specific detail on how ETL Configuration works and deployment options.

Alternatively, the most common configurations can be found in our [poc-common-configurations](https://github.com/kubecost/poc-common-configurations/tree/main/etl-federation) repo.

### Clusters

The federated ETL is composed of three types of clusters.

* **Federated Clusters**: The clusters which are being federated (clusters whose data will be combined and viewable at the end of the federated ETL pipeline). These clusters upload their ETL files after they have built them to Federated Storage.
* **Primary Cluster**: A cluster where you can see the total Federated data that was combined from your Federated Clusters. These clusters use [Aggregator](/install-and-configure/install/multi-cluster/federated-etl/aggregator.md) to read from combined storage and serve queries on the combined data.

These cluster designations can overlap, in that some clusters may be several types at once. A cluster that is a Federated Cluster and Primary Cluster will perform the following functions:

* As a Federated Cluster, push local cluster cost data from its local ETL build pipeline.
* As a Primary Cluster, run the Aggregator to pull cluster data from storage and serve it via Kubecost APIs and the Kubecost frontend.

### Other components

The Storages referred to here are an S3 (or GCP/Azure equivalent) storage bucket which acts as remote storage for the Federated ETL Pipeline.

* **Federated Storage**: A set of folders on paths `<bucket>/federated/<cluster id>` which are essentially ETL backup data, holding a “copy” of Federated Cluster data. Federated Clusters push this data to Federated Storage to be combined by the Federator. Federated Clusters write this data, and the Federator reads this data.
* **Federated ETL**: The pipeline containing the above components.
* **Aggregator**: The component running on the Primary Cluster which serves queries based on data in Federated Storage.

## Federated ETL architecture

This diagram shows an example setup of the Federated ETL with:

* Three pure Federated Clusters (not classified as any other cluster type): Cluster 1, Cluster 2, and Cluster 3
* One Primary Cluster that is also a Federated Cluster: Cluster 0

The result is 4 clusters federated together.

TODO: Update this diagram
![Federated ETL diagram](/images/kubecost-ETL-Federated-diagram.png)

## Setup

### Step 0: Ensure unique cluster IDs

Ensure each federated cluster has a unique `clusterName` and `cluster_id`:

```yaml
kubecostProductConfigs:
  clusterName: federated-one
prometheus:
  server:
    global:
      external_labels:
        cluster_id: federated-one
```

### Step 1: Storage configuration

1. For any cluster in the pipeline (Federated or Primary), create a file _federated-store.yaml_ with the same format used for Thanos/S3 backup.
   * [AWS](/install-and-configure/install/multi-cluster/long-term-storage-configuration/long-term-storage-aws.md)
   * [Azure](/install-and-configure/install/multi-cluster/long-term-storage-configuration/long-term-storage-azure.md)
   * [GCP](/install-and-configure/install/multi-cluster/long-term-storage-configuration/long-term-storage-gcp.md)
2. Add a secret using that file: `kubectl create secret generic <secret_name> -n kubecost --from-file=federated-store.yaml`. Then set `.Values.kubecostModel.federatedStorageConfigSecret` to the kubernetes secret name.

<details>

<summary>Using an existing `object-store.yaml`</summary>

This method is not recommended, as it would enable the ETL Backup pipeline to run in addition to the the Federated ETL pipeline. If not configured correctly, there may be adverse effects on how ETLs are loaded into your primary.

If you have an existing storage configuration set via `.Values.kubecostModel.etlBucketConfigSecret`, you can re-use that existing config by setting the following values:

```yaml
kubecostModel:
  etlBucketConfigSecret: "my-object-store-secret"
federatedETL:
  useExistingS3Config: true
  redirectS3Backup: true
```

</details>

### Step 2: Cluster configuration (Federated)

1. For all clusters you want to federate together (i.e. see their data on the Primary Cluster), set `.Values.federatedETL.federatedCluster` to `true`. This cluster is now a Federated Cluster, and can also be a Federator or Primary Cluster.
2. For non-primary clusters (clusters not running Aggregator and serving the main Kubecost frontend), set `.Values.kubecostAggregator.deployMethod` to `disabled`.

### Step 3: Cluster configuration (Primary)

In Kubecost, the `Primary Cluster` serves the UI and API endpoints as well as reconciling cloud billing (cloud-integration).

1. Aggregator must be set up in a [different configuration](/install-and-configure/install/multi-cluster/federated-etl/aggregator.md) than the default.

### Step 4: Verifying successful configuration

1. The Federated ETL should begin functioning. On any ETL action on a Federated Cluster (Load/Put into local ETL store) the Federated Clusters will add data to Federated Storage. 
   * To verify Federated Clusters are uploading their data correctly, check the container logs on a Federated Cluster. It should log federated uploads when ETL build steps run. The S3 bucket can also be checked to see if data is being written to the `/federated/<cluster_id>` path.
   * In a default configuration, Aggregator will ingest new data from Federated Clusters every ten minutes, but new data may not be available for as much as multiple hours in extremely high-scale deployment. Check the Aggregator logs for information.
   * To verify the entire pipeline is working, either query `Allocations/Assets` or view the respective views on the frontend. Multi-cluster data should appear after:
     * Federated Clusters have uploaded data to storage.
     * Aggregator has completed a full ingest and derive loop after the upload.

## Setup with internal certificate authority

If you are using an internal certificate authority (CA), follow this tutorial instead of the above Setup section.

Begin by creating a ConfigMap with the certificate provided by the CA on every agent and name the file _kubecost-federator-certs.yaml_.

```yaml
apiVersion: v1
data:
  ca-certificates.crt: |-
    # CA Cert
    -----BEGIN CERTIFICATE-----
    abc . . . . . . . . . . . . . .
    . . . . . . . . . . . . . . . .
    . . . . . . . . . . . . . . . .
    -----END CERTIFICATE-----

    # Root Cert
    -----BEGIN CERTIFICATE-----
    xyz . . . . . . . . . . . . . .
    . . . . . . . . . . . . . . . .
    . . . . . . . . . . . . . . . .
    -----END CERTIFICATE-----

kind: ConfigMap
  name: kubecost-federator-certs
  namespace: kubecost
```

Now run the following command, making sure you specify the location for the ConfigMap you created:

`kubectl create cm kubecost-federator-certs --from-file=/path/to/kubecost-federator-certs.yaml`

Mount the certification on the any federated clusters by passing these Helm flags to your _values.yaml_/manifest:

```yaml
extraVolumes:
  - name: kubecost-federator-certs
    configMap:
      name: kubecost-federator-certs
extraVolumeMounts:
  - name: kubecost-federator-certs
    mountPath: /path/to/ca-certificates.crt
    subPath: ca-certificates.crt
```

Create a file _federated-store.yaml_, which will go on all clusters:

```yaml
type: S3
config:
  bucket: "kubecost-storage"
  endpoint: <S3 endpoint>
  region: <region>
  aws_sdk_auth: true                                      
  insecure: false
  signature_version2: false
  put_user_metadata:
    "X-Amz-Acl": "bucket-owner-full-control"
  http_config:
    idle_conn_timeout: 90s
    response_header_timeout: 2m
    insecure_skip_verify: false
    tls_config:                                          
      ca_file: "/path/to/ca-certificates.crt"            
      cert_file: "CERT.pem"                              
      key_file: "KEY.PEM"                                 
      insecure_skip_verify: false                         
  trace:
    enable: true
  part_size: 134217728          
  sts_endpoint: <STS endpoint>  
```

Now run the following command (omit `kubectl create namespace kubecost` if your `kubecost` namespace already exists, or this command will fail):

```sh
kubectl create namespace kubecost
kubectl create secret generic \
  kubecost-object-store -n kubecost \
  --from-file=federated-store.yaml  
```

## See also

### Data recovery

When using ETL Federation, there are several methods to recover Kubecost data in the event of data loss. See our [Backups and Alerting](federated-etl-backups-alerting.md) doc for more details regarding these methods.

### Repairing ETL

In the event of missing or inaccurate data, you may need to rebuild your ETL pipelines. This is a documented procedure. See the [Repair Kubecost ETLs](/troubleshooting/etl-repair.md) doc for information and troubleshooting steps.
