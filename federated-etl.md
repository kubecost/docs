# Federated ETL

Federated ETL gives teams the benefit of federating multiple Kubecost installations into one view without dependency on Thanos.
## Overview

### Clusters
The federated ETL is composed of three types of clusters.

* **Federated Clusters**: The clusters which are being federated (clusters whose data will be combined and viewable at the end of the federated ETL pipeline). These clusters upload their ETL files after they have built them to Federated Storage.
* **Federator Clusters**: The cluster on which the Federator (see in Other Components) is set to run within the core cost-analyzer container. This cluster combines the Federated Cluster data uploaded to federated storage into combined storage.
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

## Example diagram
This diagram shows an example setup of the Federated ETL with:
* Three pure Federated Clusters (not classified as any other cluster type): Cluster 1, Cluster 2, and Cluster 3
* One Federator Cluster that is also a Federated Cluster: Cluster 4
* One Primary Cluster that is also a Federated Cluster: Cluster 5

The result is 5 clusters federated together.

![Federated ETL diagram](https://user-images.githubusercontent.com/32113845/200037732-102f12b4-732b-435c-b3d0-c23018a6a7e6.png)


## Setup
### Step 1: Storage configuration

1. For any cluster in the pipeline (Federator, Federated, Primary, or any combination of the three), create a file *federated-store.yaml* with the same format used for Thanos/S3 backup.
2. Add a secret using that file: `kubectl create secret generic <secret_name> -n kubecost --from-file=federated-store.yaml`.

    * If you would like to use an existing secret already mounted/configured through `kubecostModel.etlBucketConfigSecret`, set `federatedETL.useExistingS3Config` to `true`. This will override any secret configured using the above.
    * If using existing config, be aware that since Federated ETL clusters share an S3 bucket, it is not advised to do this for more than one of the clusters, as Kubecost S3 backup may become unreliable and cause issues with the pipeline. To avoid this, use the separate federated secret as mentioned above.

### Step 2: Cluster configuration (Federated/Federator)

1. For all clusters you want to federate together i.e. see their data on the Primary Cluster, set `.Values.federatedETL.federatedCluster` to `true`. This cluster is now a Federated Cluster, and can also be a Federator or Primary Cluster.

2. For the cluster “hosting” the Federator, set `.Values.federatedETL.federator.enabled` to `true`. This cluster is now a Federator Cluster, and can also be a Federated or Primary Cluster.
    * Optional: If you have any Federated Clusters pushing to a store that you do not want a Federator Cluster to federate, add the cluster id under the Federator config section `.Values.federatedETL.federator.clusters`.
    * If this parameter is empty or not set, the Federator will take all ETL files in the `/federated` directory and federate them automatically.
    * Multiple Federators federating from the same source will not break, but it’s not recommended.

### Step 3: Cluster configuration (Primary)
1. For the cluster that will be the Primary Cluster, set `Values.federatedETL.primaryCluster` to `true`. This cluster is now a Primary Cluster, and can also be a Federator or Federated Cluster.
   * **Important**: If the Primary Cluster is also to be federated, please wait 2-3 hours for data to populate Federated Storage before setting a Federated Cluster to primary (i.e. set `.Values.federatedETL.federatedCluster` to `true`, then wait to set `Values.federatedETL.primaryCluster` to `true`). This allows for maximum certainty of data consistency.
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

