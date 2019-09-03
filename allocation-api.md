Use the following API to get cost, resource allocation, and utilization data. This API is available at:

`http://<kubecost-address>/model/costDataModel`

Here's an example use:

`http://localhost:9090/model/costDataModel?timeWindow=7d&offset=7d`

You should receive a list of JSON elements in this format:

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
  ramallocated: [{timestamp: 1567531940, value: 55000000}]
  ramreq: [{timestamp: 1567531940, value: 55000000}]
  ramused: [{timestamp: 1567531940, value: 19463457.32}]
  services: ["cost-model"]
}  
```
