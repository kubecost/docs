## Cost Analyzer Persistent Volume

As of v1.67, Kubecost supports persisting its cache to disk. This dramatically reduces the load on startup against your Prometheus/Thanos installations on pod restart/redeploy, but commonly requires more storage. 

**If you are creating a new installation of kubecost:**

We recommend that you back Kubecost with at least a 32GiB disk. Set `persistentVolume.storage.size = “32Gi”`. (To support upgrades from legacy versions, this is not the default value.)

**If you are upgrading an existing version of Kubecost**

  * If your provisioner does supports volume expansion, we recommend that you resize to a 32GB disk by setting `persistentVolume.storage.size = “32Gi”`
  * If your provisioner does not support volume expansion:
  * If you are storing your configs on a PV and your provisioner does not support volume expansion:
    * If you can safely delete the PV storing your configs and configure them on a new PV:
      * We suggest you delete the old PV, then run Kubecost with a 32GB disk by setting persistentVolume.storage.size = “32Gi”
    * If you cannot safely delete the PV storing your configs and configure them on a new PV:
      * If you are not on a regional cluster, we recommend that you provision a second PV by setting `persistentVolume.dbPVEnabled=true`
      * If you are on a regional cluster,  we recommend that you provision a second PV using a topology-aware storage class ([more info](https://kubernetes.io/blog/2018/10/11/topology-aware-volume-provisioning-in-kubernetes/#getting-started)). You can set this disk’s storage class by setting persistentVolume.dbStorageClass=your-topology-aware-storage-class-name



