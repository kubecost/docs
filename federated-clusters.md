To view data from multipe clusters simultaneously, cluster federation must be enabled. 
This documents walks though the necessary steps for enabling this feature.


# For the master cluster

1. Follow steps [here](long-term-storage.md) to enable long-term storage.
2. Ensure `remoteWrite.postgres.installLocal` is set to `true` in values.yaml 
3. Provide a unique identifier for your cluster in `prometheus.server.global.exernal_labels.cluster_id`
4. Create a service definition to make Postgres accessible by your other clusters. Below is a sample service definition. 
Warning: this service defition may expose your database externally with just basic auth protecting. 
Be sure the follow the guideline of your organiztion. 

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

# Other clusters

Following these steps for clusters that send data to the master cluster: 

1. Same as you did for the master, follow steps [here](long-term-storage.md) to enable long-term storage.
2. Set `remoteWrite.postgres.installLocal` to `false` in values.yaml so you do not redeploy Postgres in this cluster. 
3. Set `prometheus.server.global.exernal_labels.cluster_id` to any unique identifier of your cluster, e.g. dev-cluster-7.
4. Set `prometheus.remoteWrite.postgres.remotePostgresAddress` to the externally accessible IP from master cluster.
5. Ensure `postgres.auth.password` is updated to reflect the value set at the master.
6. Helm upgrade with the new values.

# Verification

Connect to the master cluster and complete the folllowing:

Vist this endpoint `http://<master-kubecost-address>/model/costDataModelRangeLarge`

Here’s an example use: http://localhost:9090/model/costDataModelRangeLarge

You should see data with both `cluster_id` values in this response.

