Missing GPU Costs
=================

GPUs should be allocated to containers requesting them, then those containers should roll up their costs when aggregated into services. The configurable label set within kubecost applies to a node that has a GPU, then kubecost will use the limit/request of resource "nvidia.com/gpu" to determine how much a container is requesting.

If the GPU cost is being pushed into idle, it is possible that containers aren't requesting GPU or kubecost is not picking up the container GPU requests. 

To check that nodes have GPU assigned fetch a list of the nodes from the asset API. Query the returned json for "gpuCost" and "gpuCount" parameters. 

```
$ curl -skL http://localhost:9090/model/assets\?window\=today\&filterTypes\=Node
```

To check that GPU metrics exist in prometheus. Query prometheus directly for the metric `node_gpu_hourly_cost`. 

```
kube_pod_container_resource_requests{resource="nvidia_com_gpu", container!="",container!="POD", node!=""}"
```

If both endpoints return GPU related data reach out to support@kubecost.com for further help. 


