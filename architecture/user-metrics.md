# Kubecost Metrics

## Kubecost Cost Model

The Cost Model both exports and consumes the following metrics.

| Metric                          | Description              |
| ------------------------------- | ------------------------ |
| `node_cpu_hourly_cost` | Hourly cost per vCPU on this node | 
| `node_gpu_hourly_cost` | Hourly cost per GPU on this node | 
| `node_ram_hourly_cost` | Hourly cost per Gb of memory on this node | 
| `node_total_hourly_cost` | Total node cost per hour | 
| `kubecost_load_balancer_cost` | Hourly cost of a load balancer | 
| `kubecost_cluster_management_cost` | Hourly cost paid as a cluster management fee | 
| `pv_hourly_cost` | Hourly cost per Gb on a persistent volume | 
| `node_gpu_count` | Number of GPUs available on node | 
| `container_cpu_allocation` | Average number of CPUs requested/used over last 1m | 
| `container_gpu_allocation` | Average number of GPUs requested over last 1m | 
| `container_memory_allocation_bytes` | Average bytes of RAM requested/used over last 1m | 
| `pod_pvc_allocation` | Bytes provisioned for a PVC attached to a pod | 
| `kubecost_node_is_spot` | Cloud provider info about node preemptibility | 
| `kubecost_network_zone_egress_cost` | Total cost per GB egress across zones | 
| `kubecost_network_region_egress_cost` | Total cost per GB egress across regions | 
| `kubecost_network_internet_egress_cost` | Total cost per GB of internet egress | 
| `service_selector_labels` | Service Selector Labels | 
| `deployment_match_labels` | Deployment Match Labels | 
| `statefulSet_match_labels` | StatefulSet Match Labels | 
| `kubecost_cluster_memory_working_set_bytes` | (Created by recording rule) | 

## Kubecost Network Costs

The Kubecost network-costs DaemonSet collects node network data and exports the egress, ingress, and performance statistics.

| Metric                          | Description              |
| ------------------------------- | ------------------------ |
| `kubecost_pod_network_egress_bytes_total` | egressed byte counts by pod |
| `kubecost_pod_network_ingress_bytes_total` | ingressed byte counts by pod |
| `kubecost_network_costs_parsed_entries` | total parsed conntrack entries |
| `kubecost_network_costs_parse_time` | total time in milliseconds it took to parse conntrack entries |

## cAdvisor

cAdvisor (Container Advisor) provides container users an understanding of the resource usage and performance characteristics of their running containers. It is a running daemon that collects, aggregates, processes, and exports information about running containers.

GitHub: [https://github.com/google/cadvisor](https://github.com/google/cadvisor)

| Metric                          | Description              |
| ------------------------------- | ------------------------ |
| `container_memory_usage_bytes` | Current memory usage, including all memory regardless of when it was accessed |
| `container_fs_limit_bytes` | Number of bytes that can be consumed by the container on this filesystem |
| `container_fs_usage_bytes` | Number of bytes that are consumed by the container on this filesystem |
| `container_memory_working_set_bytes` | Current working set |
| `container_network_receive_bytes_total` | Cumulative count of bytes received |
| `container_network_transmit_bytes_total` | Cumulative count of bytes transmitted |
| `container_cpu_usage_seconds_total` | Cumulative cpu time consumed |
| `container_cpu_cfs_periods_total` | Number of elapsed enforcement period intervals |
| `container_cpu_cfs_throttled_periods_total` | Number of throttled period intervals |

## Kube-State-Metrics (KSM)

Although the default Kubecost installation does not include a [KSM deployment](https://github.com/kubernetes/kube-state-metrics), Kubecost does calculate & emit the below metrics. The below metrics and labels follow conventions of KSMv1, not KSMv2.

| Metric                          | Description              |
| ------------------------------- | ------------------------ |
| `kube_deployment_spec_replicas` | Number of pods specified for a Deployment |
| `kube_deployment_status_replicas_available` | Number of pods currently available for a Deployment |
| `kube_job_status_failed` | The number of pods which reached Phase Failed and the reason for failure |
| `kube_namespace_annotations` | Kubernetes annotations converted to Prometheus labels |
| `kube_namespace_labels` | Kubernetes labels converted to Prometheus labels |
| `kube_node_labels` | Kubernetes labels converted to Prometheus labels |
| `kube_node_status_allocatable` | The allocatable for different resources of a node that are available for scheduling |
| `kube_node_status_allocatable_cpu_cores` | Total allocatable cpu cores of the node (Deprecated in ksm 2.0.0) |
| `kube_node_status_allocatable_memory_bytes` | Total allocatable memory bytes of the node (Deprecated in ksm 2.0.0) |
| `kube_node_status_capacity` | The capacity for different resources of a node |
| `kube_node_status_capacity_cpu_cores` | Total cpu cores available on the the node (Deprecated in ksm 2.0.0) |
| `kube_node_status_capacity_memory_bytes` | Total memory available on the node (bytes) (Deprecated in ksm 2.0.0) |
| `kube_node_status_condition` | The condition of a cluster node |
| `kube_persistentvolume_capacity_bytes` | Total capacity of a persistent volume (bytes) |
| `kube_persistentvolume_status_phase` | Status of a persistent volume (Bound|Failed|Pending|Available|Released) |
| `kube_persistentvolumeclaim_info` | Information about persistent volume claim |
| `kube_persistentvolumeclaim_resource_requests_storage_bytes` | The capacity of storage requested by the persistent volume claim |
| `kube_pod_annotations` | Kubernetes annotations converted to Prometheus labels |
| `kube_pod_container_resource_limits` | The number of requested limit resource by a container |
| `kube_pod_container_resource_limits_cpu_cores` | Limit on CPU cores that can be used by the container. (Deprecated in ksm 2.0.0) |
| `kube_pod_container_resource_limits_memory_bytes` | Limit on the amount of memory that can be used by the container. (Deprecated in ksm 2.0.0) |
| `kube_pod_container_resource_requests` | The number of requested request resource by a container |
| `kube_pod_container_status_restarts_total` | The number of container restarts per container |
| `kube_pod_container_status_running` | Describes whether the container is currently in running state |
| `kube_pod_container_status_terminated_reason` | Describes the reason the container is currently in terminated state |
| `kube_pod_labels` | Kubernetes labels converted to Prometheus labels |
| `kube_pod_owner` | Information about the Pod's owner |
| `kube_pod_status_phase` | The pods current phase (Pending|Running|Succeeded|Failed|Unknown) |
| `kube_replicaset_owner` | Information about the ReplicaSet's owner |

## Node exporter

Prometheus exporter for hardware and OS metrics exposed by *NIX kernels, written in Go with pluggable metric collectors.

{% hint style="info" %}
The Node Exporter is disabled by default. You can enable it with the flags:

```
--set prometheus.server.nodeExporter.enabled=true
--set prometheus.serviceAccounts.nodeExporter.create=true
```

{% endhint %}

GitHub: [https://github.com/prometheus/node_exporter](https://github.com/prometheus/node_exporter)

| Metric                          | Description              |
| ------------------------------- | ------------------------ |
| `node_cpu_seconds_total` | Seconds the cpus spent in each mode |
| `node_disk_reads_completed` | The total number of reads completed successfully |
| `node_disk_reads_completed_total` | The total number of reads completed successfully |
| `node_disk_writes_completed` | The total number of writes completed successfully |
| `node_disk_writes_completed_total` | The total number of writes completed successfully |
| `node_filesystem_device_error` | Whether an error occurred while getting statistics for the given device |
| `node_memory_Buffers_bytes` | Memory information field Buffers_bytes |
| `node_memory_Cached_bytes` | Memory information field Cached_bytes |
| `node_memory_MemAvailable_bytes` | Memory information field MemAvailable_bytes |
| `node_memory_MemFree_bytes` | Memory information field MemFree_bytes |
| `node_memory_MemTotal_bytes` | Memory information field MemTotal_bytes |
| `node_network_transmit_bytes_total` | Network device statistic transmit_bytes |

## Prometheus

Prometheus emits metrics which are used by Kubecost for diagnostic purposes: 

| Metric                          | Description              |
| ------------------------------- | ------------------------ |
| `up` | Scrape target status |
| `prometheus_target_interval_length_seconds` | Amount of time between target scrapes |

## NVIDIA K8s Device Plugin (GPU)

NVIDIA GPU monitoring support can be explained in more detail in the [Kubecost Docs: NVIDIA GPU Monitoring Configurations](/install-and-configure/advanced-configuration/gpu.md) and on the [Kubecost Blog: Monitoring NVIDIA GPU Usage in Kubernetes with Prometheus](https://blog.kubecost.com/blog/nvidia-gpu-usage/). The following metrics are consumed:

| Metric                          | Description              |
| ------------------------------- | ------------------------ |
| `DCGM_FI_DEV_GPU_UTIL` | GPU utilization | 
