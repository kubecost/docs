Federated Clusters
==================

To view data from multiple clusters simultaneously, Kubecost cluster federation must be enabled.
This document walks through the necessary steps for enabling this feature.


**Note:** This feature today requires an Enterprise license.

# Thanos

1. Follow steps [here](https://github.com/kubecost/docs/blob/main/long-term-storage.md#option-b-out-of-cluster-storage-thanos) to enable Thanos durable storage on a Master cluster.  

2. Repeat the process in Step 1 for each additional secondary cluster, with the following Thanos recommendations: 
   * Reuse your existing storage bucket and access credentials.
   * Do not deploy multiple instances of `thanos-compact`.
   * Optionally deploy `thanos-bucket` in each additional cluster, but it is not required.
   * Optionally disable `thanos.store` and `thanos.query` (Clusters with store/query disabled will only have access to their metrics but will still write to the global bucket.)
     
Thanos modules can be disabled in [thanos/values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/charts/thanos/values.yaml), 
or in [values-thanos.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values-thanos.yaml) if overriding these values from a values-thanos.yaml file supplied from command line (`helm upgrade kubecost -f values.yaml -f values-thanos.yaml`), 
or by passing these parameters directly via helm install or upgrade as follows:  

```
  --set thanos.compact.enabled=false --set thanos.bucket.enabled=false
```

You can also optionally disable `thanos.store`, `thanos.query` and `thanos.queryFrontend` with thanos/values.yaml or with these flags:  

```
  --set thanos.query.enabled=false --set thanos.store.enabled=false --set thanos.queryFrontend.enabled=false
```

3. Ensure you provide a unique identifier for `prometheus.server.global.external_labels.cluster_id` to have additional clusters be visible in the Kubecost product, e.g. `cluster-two`.  

4. Follow the same verification steps available [here](https://github.com/kubecost/docs/blob/main/long-term-storage.md#verify-thanos).  

Edit this doc on [Github](https://github.com/kubecost/docs/blob/main/federated-clusters.md)

<!--- {"article":"4407595946135","section":"4402815636375","permissiongroup":"1500001277122"} --->