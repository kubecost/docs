### Metrics consumed

| Category       | Metric |
| -------------- | ---------- |
| **Node**       | `kube_node_status_condition` |
|                | `kube_node_status_capacity` |
|                | `kube_node_status_capacity_memory_bytes` |
|                | `kube_node_status_capacity_cpu_cores` |
|                | `kube_node_status_allocatable` |
|                | `kube_node_status_allocatable_cpu_cores` |
|                | `kube_node_status_allocatable_memory_bytes` |
|                | `kube_node_labels` |
| **Namespace**  | `kube_namespace_labels` |
|                | `kube_namespace_annotations` |
| **Deployment** | `kube_deployment_spec_replicas` |
|                | `kube_deployment_status_replicas_available` |
| **Pod**        | `kube_pod_owner` |
|                | `kube_pod_labels` |
|                | `kube_pod_container_status_running` |
|                | `kube_pod_container_resource_requests` |
|                | `kube_pod_annotations` |
|                | `kube_pod_status_phase` |
|                | `kube_pod_container_status_terminated_reason` |
|                | `kube_pod_container_status_restarts_total` |
|                | `kube_pod_container_resource_limits` |
|                | `kube_pod_container_resource_limits_cpu_cores` |
|                | `kube_pod_container_resource_limits_memory_bytes` |
| **PV**         | `kube_persistentvolume_capacity_bytes` |
|                | `kube_persistentvolume_status_phase` |
| **PVC**        | `kube_persistentvolumeclaim_info` |
|                | `kube_persistentvolumeclaim_resource_requests_storage_bytes` |
| **Job**        | `kube_job_status_failed` |


### Whitelisted but Unused 
We have a number of KSM metrics that have been whitelisted in our [Prometheus Chart](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/charts/prometheus/values.yaml#L1262) but are currently not being used in our stack:

| Unused KSM Metric | Notes |
| ----------------- | ----- |
| `kube_daemonset_status_desired_number_scheduled` | |
| `kube_replicaset_owner` | |
| `kube_pod_container_info` | |
| `kube_statefulset_replicas` | |
| `kube_daemonset_status_number_ready` | |
| `kube_statefulset_status_replicas` | |
| `kube_deployment_status_replicas` | |
| `kube_daemonset_status_desired_number_scheduled` | |
| `kube_node_info` | |

<!--- {"article":"4425134686743","section":"1500002777682","permissiongroup":"1500001277122"} --->