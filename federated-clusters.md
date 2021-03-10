To view data from multiple clusters simultaneously, Kubecost cluster federation must be enabled.
This document walks through the necessary steps for enabling this feature.


**Note:** This feature today requires an Enterprise license.

# Master cluster (Postgres)

1. Follow steps [here](long-term-storage.md) to enable long-term storage.  
2. Ensure `remoteWrite.postgres.installLocal` is set to `true` in values.yaml  
3. Provide a unique identifier for your cluster in `prometheus.server.global.exernal_labels.cluster_id`  
4. Create a service definition to make Postgres accessible by your other clusters. Below is a sample service definition.  
Warning: this specific service definition may expose your database externally with just basic auth protecting.
Be sure the follow the necessary guidelines of your organization.  

```
apiVersion: v1
kind: Service
metadata:
  labels:
    app: cost-analyzer
    app.kubernetes.io/instance: kubecost
    app.kubernetes.io/name: cost-analyzer
  name: pgprometheus-remote
  namespace: kubecost
spec:
  ports:
  - name: server
    port: 5432
    protocol: TCP
    targetPort: 5432
  selector:
    app: postgres
  type: LoadBalancer
```  
5. Helm upgrade with the new values.  

# Secondary clusters (Postgres)

Following these steps for clusters that send data to the master cluster:

1. Same as you did for the master, follow steps [here](long-term-storage.md) to enable long-term storage.  
2. Set `remoteWrite.postgres.installLocal` to `false` in values.yaml so you do not redeploy Postgres in this cluster.  
3. Set `prometheus.server.global.exernal_labels.cluster_id` to any unique identifier of your cluster, e.g. dev-cluster-7.  
4. Set `prometheus.remoteWrite.postgres.remotePostgresAddress` to the externally accessible IP from master cluster.  
5. Ensure `postgres.auth.password` is updated to reflect the value set at the master.  
6. Helm upgrade with the new values.  

# Verification of Postgres multi-cluster

Connect to the master cluster and complete the folllowing:

Visit this endpoint `http://<master-kubecost-address>/model/costDataModelRangeLarge`

Here’s an example use: http://localhost:9090/model/costDataModelRangeLarge

You should see data with both `cluster_id` values in this response.


# Federated Clusters (Thanos)

1. Follow steps [here](long-term-storage.md#option-b-out-of-cluster-storage-thanos) to enable Thanos durable storage on a Master cluster.  

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

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
You can also optionally disable `thanos.store`, `thanos.query` and `thanos.queryFrontend` with thanos/values.yaml or with these flags:  

```
  --set thanos.query.enabled=false --set thanos.store.enabled=false --set thanos.queryFrontend.enabled=false
```

3. Ensure you provide a unique identifier for `prometheus.server.global.external_labels.cluster_id` to have additional clusters be visible in the Kubecost product, e.g. `cluster-two`.  

4. Follow the same verification steps available [here](long-term-storage.md#verify-thanos).  
