# Kubernetes Cost Allocation

The Kubecost Allocation view allows you to quickly see allocated spend across all native Kubernetes concepts, e.g. namespace and service. It also allows for allocating cost to organizational concepts like team, product/project, department, or environment. This document explains the metrics presented and describes how you can control the data displayed in this view.

![Cost allocation view](cost-allocation.png)

### 1. Cost metrics  
View either cumulative costs measured over the selected time window or run rate (e.g. hourly, daily, monthly) based on the resources allocated. Costs allocations are based on the following:

1) resources allocated, i.e. max of requests and usage
2) the cost of each resource
3) the amount of time resources were provisioned

For more information, refer to this [FAQ](https://github.com/kubecost/cost-model#frequently-asked-questions) on how each of these inputs is determined based on your environment.

### 2. Aggregation  
Aggregate cost by namespace, deployment, service and other native Kubernetes concepts. Costs are also visible by other meaningful organizational concepts, e.g. Team, Department, or Product. These aggregations are based on Kubernetes labels or annotations, referenced at both the pod and namespace-level, with labels at the pod-level being favored over the namespace label when both are present. The label name used for these concepts can be configured in Settings. Resources without a label/annotation will be shown as _unassigned_.

### 3. Time window  
The designated time window for measuring costs. Results for 1d, 2d, 7d, and 30d queries are cached by default.

### 4. Filter  
Filter resources by namespace, clusterId, and Kubernetes label to more closely investigate a rise in spend or key cost drivers at different aggregations, e.g. Deployments or Pods.
   
### 5. Allocate Idle Cost  
Allocating idle costs proportionately distributes slack or idle _cluster costs_ to tenants. As an example, if your cluster is only 25% utilized, as measured by the max of resource usage and requests, applying idle costs would increase the cost of each pod/namespace/deployment by 4x.

### 6. Chart selection  
Toggle to the bar chart view to see aggregated costs over the selected window, or the time series view to see cost changes over time.

### 7. Additional options  
View other options to export cost data to CSV or view help documentation.

### Cost metrics

Cost allocation metrics are available for both in-cluster and out-of-cluster resources. Here are short descriptions of each metric:

| Metric 	| Description         	|
|--------------------	|---------------------	|
| Memory cost        	| The total cost of memory allocated to this object, e.g. namespace or deployment. The amount of memory allocated is the greater of memory usage and memory requested over the measured time window. The price of allocated memory is based on cloud billing APIs or custom pricing sheets. [Learn more](https://github.com/kubecost/cost-model#questions)|
| CPU Cost        	| The total cost of CPU allocated to this object, e.g. namespace or deployment. The amount of CPU allocated is the greater of CPU usage and CPU requested over the measured time window. The price of allocated CPU is based on cloud billing APIs or custom pricing sheets. [Learn more](https://github.com/kubecost/cost-model#questions) |
| Network Cost        	| The cost of network traffic based on internet egress, cross-zone egress, and other billed transfer. Note: these costs must be enabled. [Learn more](http://docs.kubecost.com/network-allocation)|
| PV Cost        	| The cost of persistent storage volumes claimed by this object. Prices are based on cloud billing prices or custom pricing sheets for on-prem deployments. |
| GPU Cost        	| The cost of GPUs requested by this object, as measured by [resource limits](https://kubernetes.io/docs/concepts/configuration/manage-compute-resources-container/). Prices are based on cloud billing prices or custom pricing sheets for on-prem deployments. |
| External Cost        	| The cost of out-of-cluster resources allocated to this object. For example, S3 buckets allocated to a particular Kubernetes deployment. Prices are based on cloud billing data and require a key. This feature is currently available for AWS ([learn more](http://docs.kubecost.com/aws-out-of-cluster.html)) and GCP ([learn more](http://docs.kubecost.com/gcp-out-of-cluster.html)). |
