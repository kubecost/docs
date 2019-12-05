Kubecost exposes multiple APIs to obtain cost, resource allocation, and utilization data. Below is documentation on two options: the cost model API and aggregated cost model API.  

# Cost model API

The full cost model API exposes pricing model inputs at the individual container/workload level and is available at:

`http://<kubecost-address>/model/costDataModel`

Here's an example use:

`http://localhost:9090/model/costDataModel?timeWindow=7d&offset=7d`

API parameters include the following:

* `timeWindow` dictates the applicable window for measuring cost metrics. Supported units are d, h, and m.  
* `offset` shifts timeWindow backwards relative to the current time. Supported units are d, h, and m.

This API returns a set of JSON elements in this format:

```
{
  cpuallocated: [{timestamp: 1567531940, value: 0.01}]
  cpureq: [{timestamp: 1567531940, value: 0.01}]
  cpuused: [{timestamp: 1567531940, value: 0.006}]
  deployments: ["cost-model"]
  gpureq: [{timestamp: 0, value: 0}]
  labels: {app: "cost-model", pod-template-hash: "1576869057"}
  name: "cost-model"
  namespace: "cost-model"
  node: {hourlyCost: "", CPU: "2", CPUHourlyCost: "0.031611", RAM: "13335256Ki",…}
  nodeName: "gke-kc-demo-highmem-pool-b1faa4fc-fs6g"
  podName: "cost-model-59cbdbf49c-rbr2t"
  pvcData: [{class: "standard", claim: "kubecost-model", namespace: "kubecost",…}]
  ramallocated: [{timestamp: 1567531940, value: 55000000}]
  ramreq: [{timestamp: 1567531940, value: 55000000}]
  ramused: [{timestamp: 1567531940, value: 19463457.32}]
  services: ["cost-model"]
}  
```
<a name="optional-params"></a>  
Optional request parameters include the following:  

Field | Description 
--------- | ----------- 
`filterFields` | Blacklist of fields to be filtered from response. For example, appending `&filterFields=cpuused,cpureq,ramreq,ramused` will remove request and usage data.
`namespace` | Filter results by namespace. For example, appending `&namespace=kubecost` only returns data for the `kubecost` namespace


# Aggregated cost model API

The aggregated cost model API retrieves data similiar to the Kubecost Allocation frontend view (e.g. cost by namespace, label, deployment and more) and is available at the following endpoint:

`http://<kubecost-address>/model/aggregatedCostModel`

Here are example uses:

* `http://localhost:9090/model/aggregatedCostModel?window=1d&aggregation=namespace`  
* `http://localhost:9090/model/aggregatedCostModel?window=1d&aggregation=label&aggregationSubfield=product`
* `http://localhost:9090/model/aggregatedCostModel?window=1d&aggregation=namespace&sharedNamespaces=kube-system`

API parameters include the following:

* `window` dictates the applicable window for measuring cost metrics. Supported units are d, h, m, and s.  
* `offset` (optional) shifts window backwards from current time. Supported units are d, h, m, and s.  
* `aggregation` is the field used to consolidate cost model data. Supported types are cluster, namespace, deployment, service, and label.  
* `aggregationSubfield` used for aggregation types that require sub fields, e.g. aggregation type equals `label` and the value of the label (aggregationSubfield) equals `app`.
* `allocateIdle` (optional) when set to `true` applies the cost of all idle compute resources to tenants, default `false`.
* `sharedNamespaces` (optional) provide a comma separated list of namespaces (e.g. kube-system) to be allocated to other tenants. These resources are evenly allocated to other tenants as `sharedCost`.
* `sharedLabelNames` (optional) provide a comma separated list of kubernetes labels (e.g. app) to be allocated to other tenants. Must provide corresponding set of label values in `sharedLabelValues`.
* `sharedLabelValues` (optional) label value (e.g. prometheus) associated with `sharedLabelNames` parameter. 
* `disableCache` this API caches recently fetched data by default. Set this variable to `false` to avoid cache entirely. 

<a name="filter-params"></a>  
Optional filter parameters include the following:  

Filter | Description 
--------- | ----------- 
`cluster` | Filter results by cluster ID. For example, appending `&cluster=cluster-one` will restrict data only to the `cluster-one` cluster. Note: cluster ID is generated from `cluster_id` provided during installation. 
`namespace` | Filter results by namespace. For example, appending `&namespace=kubecost` only returns data for the `kubecost` namespace.
`labels` | Filter results by label. For example, appending `&labels=app%3Dcost-analyzer` only returns data for pods with label `app=cost-analyzer`. CSV list of label values supported. Note that parameters must be url encoded. 

This API returns a set of JSON objects in this format:

```
{
  aggregation: "namespace"
  subfields: ""             // value(s) of aggregationSubfield parameter
  cluster: "cluster-1"
  cpuCost: 100.031611       
  environment: "default"    // value of aggregation field
  gpuCost: 0
  networkCost: 0
  pvCost: 10.000000
  ramCost: 70.000529625
  sharedCost: 0             // value of costs allocated via sharedNamespaces or sharedLabelNames
  totalCost: 180.032140625
}  
```

Have questions? Email us at <team@kubecost.com>.
