High Availability Kubecost
==========================

Running kubecost in high availability mode is a feature that relies on multiple Kubecost replica pods implementing the [ETL Bucket Backup](https://raw.githubusercontent.com/kubecost/docs/main/etl-backup.md) feature combined with a Leader/Follower implementation which ensures that there always exists exactly one leader across all replicas.

> **Note**: High availability mode is only available in Kubecost Enterprise.

## Leader + Follower

The Leader/Follower implementation leverages a `coordination.k8s.io/v1` `Lease` resource to manage the election of a leader when necessary. To control access of the backup from the ETL pipelines, a `RWStorageController` is implemented to ensure the following: 
* Followers block on all backup reads, and poll bucket storage for any backup reads every 30 seconds.
* Followers no-op on any backup writes.
* Followers which receive Queries into a backup store will not stack on pending reads, preventing external queries from blocking.
* Followers promoted to Leader will drop all locks and receive write privileges.
* Leaders behave identically to a single Kubecost install. 

![Leader/Follower](https://raw.githubusercontent.com/kubecost/docs/main/images/leader-follower.png)

## Configuring high availability

In order to enable the leader/follower and high availability features, the following must also be configured:
* Replicas are set to a value greater than 1
* ETL FileStore is Enabled (enabled by default)
* [ETL Bucket Backup](https://raw.githubusercontent.com/kubecost/docs/main/etl-backup.md) is Configured

For example, using our helm chart, the following is an acceptable configuration:
```bash
helm install --name kubecost --namespace kubecost \
	--set kubecostDeployment.leaderFollower.enabled=true \ 
	--set kubecostDeployment.replicas=5 \
	--set kubecostModel.etlBucketConfigSecret=kubecost-bucket-secret
```

This can also be done in the `values.yaml` file within the chart: 
```yaml
kubecostModel:
  image: "gcr.io/kubecost1/cost-model"
  imagePullPolicy: Always
  # ... 
  # ETL should be enabled with etlFileStoreEnabled: true 
  etl: true
  etlFileStoreEnabled: true 
  # ...
  # ETL Bucket Backup should be configured by passing the configuration secret name
  etlBucketConfigSecret: kubecost-bucket-secret

# Used for HA mode in Business & Enterprise tier
kubecostDeployment:
  # Select a number of replicas of Kubecost pods to run 
  replicas: 5
  # Enable Leader/Follower Election 
  leaderFollower:
    enabled: true
```

----




