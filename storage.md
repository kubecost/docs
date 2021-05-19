## Cost Analyzer Persistent Volume

As of v1.67, the persistent volume attached to Kubecost's primary pod (cost-analyzer) contains [ETL cache data](https://github.com/kubecost/docs/blob/master/allocation-api.md#caching-overview) as well as product configuration data. While it's technically optional, because all configurations can be set via configmap, it dramatically reduces the load against your Prometheus/Thanos installations on pod restart/redeploy. For this reason, it's strongly encouraged on larger clusters.

**If you are creating a new installation of kubecost:**

We recommend that you back Kubecost with at least a 32GiB disk. This is the default as of 1.72.0.

**If you are upgrading an existing version of Kubecost**

  * If your provisioner does supports volume expansion, we will automatically resize you to a 32GB disk in upgrade to 1.72.0
  * If your provisioner does not support volume expansion:
    * If all your configs are supplied via values.yaml in helm or via configmap and have not been added from the frontend, you can safely delete the PV and upgrade.
      * We suggest you delete the old PV, then run Kubecost with a 32GB disk. This is the default in 1.72.0
    * If you cannot safely delete the PV storing your configs and configure them on a new PV:
      * If you are not on a regional cluster, we recommend that you provision a second PV by setting `persistentVolume.dbPVEnabled=true`
      * If you are on a regional cluster,  we recommend that you provision a second PV using a topology-aware storage class ([more info](https://kubernetes.io/blog/2018/10/11/topology-aware-volume-provisioning-in-kubernetes/#getting-started)). You can set this disk’s storage class by setting persistentVolume.dbStorageClass=your-topology-aware-storage-class-name


#### Regional Cluster bindings

If you're using just one PV and still seeing issues with Kubecost being rescheduled on zones outside of your disk, consider using a [topology aware storage class](https://kubernetes.io/blog/2018/10/11/topology-aware-volume-provisioning-in-kubernetes/#getting-started). You can set the Kubecost disk’s storage class by setting 
`persistentVolume.storageClass=your-topology-aware-storage-class-name` 


