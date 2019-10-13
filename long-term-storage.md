To enable 90+ days of data retention in Kubecost, we recommend deploying with durable storage enabled. We provide two options for doing this: 1) in your cluster and 2) out of cluster. This functionality also powers the Enterprise multi-cluster view, where data across clusters can be viewed in aggregate, as well as simple backup & restore capabilities.

**Note:** this feature today requires an Enterprise license. 

## Option A: In cluster storage (Postgres)

To enable Postgres-based long-term storage, complete the following:

1. **Helm chart configuration** -- in [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) set the `remoteWrite.postgres.enabled` attribute 
to true. The default backing disk is `200gb` but this can also be directly configured in values.yaml. 
 
2. **Verify successful install** -- Deploy or upgrade via install instructions at <http://kubecost.com/install>, passing this updated values.yaml file, and verify pods with the prefix `kubecost-cost-analyzer-adapter`
and `kubecost-cost-analyzer-postgres` are Running.

3. **Confirm data is availabile**

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Vist this endpoint `http://<kubecost-address>/model/costDataModelRangeLarge`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Here's an example use: `http://localhost:9090/model/costDataModelRangeLarge`

## Option B: Out of cluster storage (Thanos)

Coming soon. 
