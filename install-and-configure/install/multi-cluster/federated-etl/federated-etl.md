# ETL Federation (preferred)

{% hint style="info" %}
Federated ETL is only officially supported for Kubecost Enterprise plans.
{% endhint %}

Federated extract, transform, load (ETL) is one of two methods to aggregate all cluster information back to a single display described in our [Multi-Cluster](/install-and-configure/install/multi-cluster/multi-cluster.md#enterprise-federation) doc. Federated ETL gives teams the benefit of combining multiple Kubecost installations into one view without dependency on Thanos.

There are two primary advantages for using ETL Federation:

1. For environments that already have a Prometheus instance, Kubecost only requires a single pod per monitored cluster
2. Many solutions that aggregate Prometheus metrics (like Thanos), are often expensive to scale in large environments

## Kubecost ETL Federation diagram

![ETL Federation Overview](/images/kubecost-ETL-Federated-Architecture.png)

## Sample configurations

This guide has specific detail on how ETL Configuration works and deployment options.

Alternatively, the most common configurations can be found in our [poc-common-configurations](https://github.com/kubecost/poc-common-configurations/tree/main/etl-federation) repo.

### Clusters

The federated ETL is composed of three types of clusters.

* **Federated Clusters**: The clusters which are being federated (clusters whose data will be combined and viewable at the end of the federated ETL pipeline). These clusters upload their ETL files after they have built them to Federated Storage.
* **Federator Clusters**: The cluster on which the Federator (see in Other components) is set to run within the core cost-analyzer container. This cluster combines the Federated Cluster data uploaded to federated storage into combined storage.
* **Primary Cluster**: A cluster where you can see the total Federated data that was combined from your Federated Clusters. These clusters read from combined storage.

These cluster designations can overlap, in that some clusters may be several types at once. A cluster that is a Federated Cluster, Federator Cluster, and Primary Cluster will perform the following functions:

* As a Federated Cluster, push local cluster cost data to be combined from its local ETL build pipeline.
* As a Federator Cluster, run the Federator inside the cost-analyzer, which pulls this local cluster data from S3, combines them, then pushes them back to combined storage.
* As a Primary Cluster, pull back this combined data from combined storage to serve it on Kubecost APIs and/or the Kubecost frontend.

### Other components

The Storages referred to here are an S3 (or GCP/Azure equivalent) storage bucket which acts as remote storage for the Federated ETL Pipeline.

* **Federated Storage**: A set of folders on paths `<bucket>/federated/<cluster id>` which are essentially ETL backup data, holding a “copy” of Federated Cluster data. Federated Clusters push this data to Federated Storage to be combined by the Federator. Federated Clusters write this data, and the Federator reads this data.
* **Combined Storage**: A folder on S3 on the path `<bucket>/federated/combined` which holds one set of ETL data containing all the `allocations/assets` in all the ETL data from Federated Storage. The Federator takes files from Federated Storage and combines them, adding a single set of combined ETL files to Combined Storage to be read by the Primary Cluster. The Federator writes this data, and the Primary Cluster reads this data.
* **The Federator**: A component of the cost-model which is run on the Federator Cluster, which can be a Federated Cluster, a Primary Cluster, or neither. The Federator takes the ETL binaries from Federated Storage and merges them, adding them to Combined Storage.
* **Federated ETL**: The pipeline containing the above components.

## Federated ETL architecture

This diagram shows an example setup of the Federated ETL with:

* Three pure Federated Clusters (not classified as any other cluster type): Cluster 1, Cluster 2, and Cluster 3
* One Federator Cluster that is also a Federated Cluster: Cluster 4
* One Primary Cluster that is also a Federated Cluster: Cluster 5

The result is 5 clusters federated together.

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

1. For any cluster in the pipeline (Federator, Federated, Primary, or any combination of the three), create a file _federated-store.yaml_ with the same format used for Thanos/S3 backup.
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

### Step 2: Cluster configuration (Federated/Federator)

1. For all clusters you want to federate together (i.e. see their data on the Primary Cluster), set `.Values.federatedETL.federatedCluster` to `true`. This cluster is now a Federated Cluster, and can also be a Federator or Primary Cluster.
2. For the cluster “hosting” the Federator, set `.Values.federatedETL.federator.enabled` to `true`. This cluster is now a Federator Cluster, and can also be a Federated or Primary Cluster.
   * Optional: If you have any Federated Clusters pushing to a store that you do not want a Federator Cluster to federate, add the cluster id under the Federator config section `.Values.federatedETL.federator.clusters`. If this parameter is empty or not set, the Federator will take all ETL files in the `/federated` directory and federate them automatically.
   * Multiple Federators federating from the same source will not break, but it’s not recommended.

### Step 3: Cluster configuration (Primary)

In Kubecost, the `Primary Cluster` serves the UI and API endpoints as well as reconciling cloud billing (cloud-integration).

1. For the cluster that will be the Primary Cluster, set `.Values.federatedETL.primaryCluster` to `true`. This cluster is now a Primary Cluster, and can also be a Federator or Federated Cluster.
2. Cloud-integration requires `.Values.federatedETL.federator.primaryClusterID` set to the same value used for `.Values.kubecostProductConfigs.clusterName`
   * **Important**: If the Primary Cluster is also to be federated, please wait 2-3 hours for data to populate Federated Storage before setting a Federated Cluster to primary (i.e. set `.Values.federatedETL.federatedCluster` to `true`, then wait to set `.Values.federatedETL.primaryCluster` to `true`). This allows for maximum certainty of data consistency.
   * If you do not set this cluster to be federated as well as primary, you will not see local data for this cluster.
   * The Primary Cluster’s local ETL will be overwritten with combined federated data.
     * This can be undone by unsetting it as a Primary Cluster and rebuilding ETL.
     * Setting a Primary Cluster may result in a loss of the cluster’s local ETL data, so it is recommended to back up any filestore data that one would want to save to S3 before designating the cluster as primary.
     * Alternatively, a fresh Kubecost install can be used as a consumer of combined federated data by setting it as the Primary but not a Federated Cluster.

### Step 4: Verifying successful configuration

1. The Federated ETL should begin functioning. On any ETL action on a Federated Cluster (Load/Put into local ETL store) the Federated Clusters will add data to Federated Storage. The Federator will run 5 minutes after the Federator Cluster startup, and then every 30 minutes after that. The data is merged into the Combined Storage, where it can be read by the Primary.
   * To verify Federated Clusters are uploading their data correctly, check the container logs on a Federated Cluster. It should log federated uploads when ETL build steps run. The S3 bucket can also be checked to see if data is being written to the `/federated/<cluster_id>` path.
   * To verify the Federator is functioning, check the container logs on the Federator Cluster. The S3 bucket can also be checked to verify that data is being written to `/federated/combined`.
   * To verify the entire pipeline is working, either query `Allocations/Assets` or view the respective views on the frontend. Multi-cluster data should appear after:
     * The Federator has run at least once.
     * There was data in the Federated Storage for the Federator to have combined.

## Setup with internal certificate authority

If you are using an internal certificate authority (CA), follow this tutorial instead of the above Setup section.

Begin by creating a ConfigMap with the certificate provided by the CA on every agent, including the Federator and any federated clusters, and name the file _kubecost-federator-certs.yaml_.

```
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

`kubectl create cm kubecost-federator-certs --from-kubecost-federator-certs.yaml=/path/to/kubecost-federator-certs`

Mount the certification on the Federator and any federated clusters by passing these Helm flags to your _values.yaml_/manifest:

```
extraVolumes:
  - name: kubecost-federator-certs
    configMap:
      name: kubecost-federator-certs
extraVolumeMounts:
  - name: kubecost-federator-certs
    mountPath: /path/to/ca-certificates.crt
    subPath: ca-certificates.crt

federatedETL:
  federator:
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

```
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

Now run the following command:

```
kubectl create namespace kubecost
kubectl create secret generic \
  kubecost-object-store -n kubecost \
  --from-file federated-store.yaml  
```

## See also

### Data recovery

When using ETL Federation, there are several methods to recover Kubecost data in the event of data loss. See our [Backups and Alerting](federated-etl-backups-alerting.md) doc for more details regarding these methods.

### Repairing ETL

In the event of missing or inaccurate data, you may need to rebuild your ETL pipelines. This is a documented procedure. See the [Repair Kubecost ETLs](/troubleshooting/etl-repair.md) doc for information and troubleshooting steps.
