To enable 90+ days of data retention in Kubecost, we recommend deploying with durable storage enabled. 
This functionality also powers the Enterprise multi-cluster view, where data across clusters can be viewed in aggregate, as well as simple backup & restore capabilities.

To enable long-term storage, complete the following:

1. **Helm chart configuration** -- in [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) set the following attribute 
to true `remoteWrite.postgres.enabled`
 
2. **Verify successful install** -- Deploy or upgrade via install instructions at <http://kubecost.com/install>, passing this updated values.yaml file, and verify pods with the prefix `kubecost-cost-analyzer-adapter`
and `kubecost-cost-analyzer-postgres` are Running.

3. **Confirm data is availabile**

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Vist this endpoint `http://<kubecost-address>/model/costDataModelRangeLarge`

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Here's an example use: `http://localhost:9090/model/costDataModelRangeLarge`

Note: this feature today requires an Enterprise license. 
