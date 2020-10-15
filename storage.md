### Cost Analyzer Persistent Volume

#### Persisting data to disk cache
Kubecost now supports persisting its cache of data to disk. This dramatically reduces the load on startup against your Prometheus/Thanos installations on pod restart/redeploy.

* If you are creating a new installation of kubecost:
  * It is recommended that you back kubecost with a 32GB disk. Set persistentVolume.storage.size = “32Gi”
* If you are upgrading
  * If you are storing your configs on a PV and your provisioner supports volume expansion:
    * It is recommended that you resize to a 32GB disk
  * If you are storing your configs on a PV and your provisioner does not support volume expansion:
    * If you can safely delete your configs and re-add them on another PV, it is suggested you delete the old PV and run kubecost with a 32GB disk
    * If you cannot safely delete your configs and re-add them on another PV
      * If you are not on a regional cluster you can store data on a second disk by setting persistentVolume.dbPVEnabled=true in values.yaml
      * If you are on a regional cluster, you will need to provision this disk using a topology-aware storage class (more info). You can set this disk’s storage class by setting persistentVolume.dbStorageClass = your-topology-aware-storage-class-name



