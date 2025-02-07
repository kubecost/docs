# ETL Federation

{% hint style="info" %}
Federated ETL is only supported for Kubecost Enterprise plans.
{% endhint %}

Federated extract, transform, load (ETL) is Kubecost's method to aggregate all cluster information back to a single display described in our [Multi-Cluster](/install-and-configure/install/multi-cluster/multi-cluster.md#enterprise-federation) doc. Federated ETL gives teams the benefit of combining multiple Kubecost installations into one view.

As of Kubecost v2, a multi-cluster setup will also require running the [Aggregator](/install-and-configure/install/multi-cluster/federated-etl/aggregator.md) on the primary cluster.

## Sample configurations

This guide has specific details on how ETL Configuration works and deployment options.

Alternatively, the most common configurations can be found in our [poc-common-configurations](https://github.com/kubecost/poc-common-configurations/tree/main/etl-federation-aggregator) repo.

### Clusters

Federated ETL is composed of two types of clusters.

* Federated cluster: The clusters which are being federated (clusters whose data will be combined and viewable at the end of the federated ETL pipeline). These clusters upload their ETL files after they have built them to Federated Storage.
* Primary cluster: A cluster where you can see the total Federated data that was combined from your federated clusters. These clusters use [Aggregator](/install-and-configure/install/multi-cluster/federated-etl/aggregator.md) to read from combined storage and serve queries on the combined data.

These cluster designations can overlap, in that some clusters may be several types at once. A cluster that is a federated cluster and primary cluster will perform the following functions:

* As a federated cluster, push local cluster cost data from its local ETL build pipeline.
* As a primary cluster, run the Aggregator to pull cluster data from storage and serve it via Kubecost APIs and the Kubecost frontend.

### Other components

The Storages referred to here are an S3 (or GCP/Azure equivalent) storage bucket which acts as remote storage for the Federated ETL Pipeline.

* **Federated Storage**: A set of folders on paths `<bucket>/federated/<cluster id>` which are essentially ETL backup data, holding a “copy” of federated cluster data. Federated clusters push this data to Federated Storage to be combined by the Aggregator. Federated clusters write this data, and the Aggregator reads this data.
* **Aggregator**: The component running on the primary cluster which serves queries based on data in Federated Storage.
* **Federated ETL**: The pipeline containing the above components.

## Federated ETL architecture

This diagram shows an example setup of the Federated ETL with:

* One primary cluster that is also federated. Aggregator is running on this cluster, and is what allows the user to query all multi-cluster Kubecost data.
* Three secondary federated clusters 

The result is four clusters federated together. All clusters push their local cost data to the Federated Storage, but only the primary cluster via Aggregator interacts with the total Federated data for querying. This includes querying via API or through the Kubecost UI.

![Federated ETL diagram](/images/diagrams/fed-etl-agg-arch.png)

## Setup

### Prerequisites

Before starting, ensure each federated cluster has a unique `clusterName` and `cluster_id`:

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

For all monitored clusters (federated or primary), create a file *federated-store.yaml*. Refer to the following documentation for setup:

* [AWS](/install-and-configure/install/multi-cluster/long-term-storage-configuration/long-term-storage-aws.md)
* [Azure](/install-and-configure/install/multi-cluster/long-term-storage-configuration/long-term-storage-azure.md)
* [GCP](/install-and-configure/install/multi-cluster/long-term-storage-configuration/long-term-storage-gcp.md)

The file _must_ be named named *federated-store.yaml*. then set the following configs:

```sh
kubectl create secret generic federated-store -n kubecost --from-file=federated-store.yaml
```

```yaml
kubecostModel:
  federatedStorageConfigSecret: "federated-store"
```

### Step 2: Cluster configuration (Federated)

For all monitored clusters, set the following configs:

```yaml
federatedETL:
  federatedCluster: true
```

If it is not the primary cluster, additionally set the following:

```yaml
kubecostAggregator:
  deployMethod: disabled
```

### Step 3: Cluster configuration (Primary)

In Kubecost, the primary cluster serves the UI and API endpoints as well as reconciling cloud billing (cloud integrations). Follow the instructions in our [Aggregator doc](/install-and-configure/install/multi-cluster/federated-etl/aggregator.md) to set up the primary cluster.

### Step 4: Verifying successful configuration

After some time, you should see multi-cluster data in your bucket and in your Kubecost UI. If not, you can proceed to verify the following:

* Check the object-store to see if data is being written to the `/federated/<cluster_id>` path.
* Check the container logs on a Federated Cluster. It should log federated uploads when ETL build steps run.
* In a default configuration, Aggregator will ingest new data from federated clusters every ten minutes, but new data may not be available for as much as multiple hours in extremely high-scale deployment. Check the Aggregator logs for information.
* To verify the entire pipeline is working, either query `Allocations/Assets` or view the respective views on the frontend. Multi-cluster data should appear after:
  * Federated clusters have uploaded data to storage.
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

In the event of missing or inaccurate data, you may need to rebuild your ETL pipelines. See the [Repair Kubecost ETLs](/troubleshooting/etl-repair.md) doc for information and troubleshooting steps.

## Setup with Azure workload Identities

For an environment using Azure Workload Identities, the following configuration must be included in the Kubecost Deployment in the Helm values file on both the primary and secondary clusters:

```yaml
kubecostDeployment:
  labels:
    azure.workload.identity/use: "true"
serviceAccount:
  annotations:
    azure.workload.identity/client-id: <azure_client_id>
```
