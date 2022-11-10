Kube-State-Metrics (KSM) Emission
=================================

Since the cost-model depends on a number of metrics emitted by kube-state-metrics, any schema changes to the expected metrics pose a long-term reliability challenge. In order to become resilient to said changes, the cost-model emits all required kube-state-metrics by default. While the result could yield double emission for some KSM metrics, it guarantees compatibility if KSM were to branch/drop specific metrics (as seen in KSM v2). 

## Replicated KSM Metrics

The following table shows all KSM metrics required by the cost-model, which are also the metrics being replicated:

| Category       | KSM Metric | Implemented in Cost Model |
| -------------- | ---------- | ------------------------- |
| **Node**       | `kube_node_status_condition` | ✔️ |
|                | `kube_node_status_capacity` | ✔️ |
|                | `kube_node_status_capacity_memory_bytes` | ✔️ |
|                | `kube_node_status_capacity_cpu_cores` | ✔️ |
|                | `kube_node_status_allocatable` | ✔️ |
|                | `kube_node_status_allocatable_cpu_cores` | ✔️ |
|                | `kube_node_status_allocatable_memory_bytes` | ✔️ |
|                | `kube_node_labels` | ✔️ |
| **Namespace**  | `kube_namespace_labels` | ✔️ |
|                | `kube_namespace_annotations` | ✔️ |
| **Deployment** | `kube_deployment_spec_replicas` | ✔️ |
|                | `kube_deployment_status_replicas_available` | ✔️ |
| **Pod**        | `kube_pod_owner` | ✔️ |
|                | `kube_pod_labels` | ✔️ |
|                | `kube_pod_container_status_running` | ✔️ |
|                | `kube_pod_container_resource_requests` | ✔️ |
|                | `kube_pod_annotations` | ✔️ |
|                | `kube_pod_status_phase` | ✔️ |
|                | `kube_pod_container_status_terminated_reason` | ✔️ |
|                | `kube_pod_container_status_restarts_total` | ✔️ |
|                | `kube_pod_container_resource_limits` | ✔️ |
|                | `kube_pod_container_resource_limits_cpu_cores` | ✔️ |
|                | `kube_pod_container_resource_limits_memory_bytes` | ✔️ |
| **PV**         | `kube_persistentvolume_capacity_bytes` | ✔️ |
|                | `kube_persistentvolume_status_phase` | ✔️ |
| **PVC**        | `kube_persistentvolumeclaim_info` | ✔️ |
|                | `kube_persistentvolumeclaim_resource_requests_storage_bytes` | ✔️ |
| **Job**        | `kube_job_status_failed` | ✔️ |

## Long Term Reliability 

One of the more obvious questions here is `If the metrics you are emitting cover all of the KSM requirements, could the KSM deployment be dropped?` The long term plan is to drop our dependency on KSM, and while it is possible to omit the KSM deployment today, doing so would require higher up-time on the cost-model to ensure accuracy of these metrics. Part of reaching this long term goal requires the deployment of a pod responsible for all kubecost metric emission separate from the cost-model to ensure reliability and high up-time.

## Disabling KSM Emission 

If an install is running KSM v1 and does not plan on updating, it is possible to disable the KSM metric replication by passing `--set .kubecostMetrics.emitKsmV1Metrics=false` when installing with helm, or by setting the `EMIT_KSM_V1_METRICS` environment variable passed to the cost-model container to `"false"`.

## Dealing with duplicate metrics when a non-Kubecost KSM is present in the cluster

If there is a deployment of KSM outside of Kubecost, Prometheus deployments that scrape Kubecost and the external KSM will have duplicate metrics for the metrics which both Kubecost and the external KSM emit. Kubecost itself is resilient to duplicate metrics, but other services or queries could be affected. There are a few approaches for handling this problem:

- Remove the external KSM from the cluster. If you do this, only the Kubecost-emitted metrics listed above should be available. This could cause other services that depend on KSM metrics to fail.
- Rewrite queries that cannot handle duplicate metrics to include a filter on `job=<external-KSM-scrape-job>` or to be generally resilient to duplication using query functions like `avg_over_time`.
- Run a separate Prometheus for Kubecost alone (the default installation behavior of Kubecost) and disable the scraping of Kubecost's metrics in your other Prometheus configurations.
- We support reducing some duplication from Kubecost via config. To reduce the emission of metrics that overlap with metrics provided by KSM v2 you can set the following helm values ([code ref](https://github.com/kubecost/cost-model/blob/0a0793ec040013fe44c058ff37f032449a2f1191/pkg/metrics/kubemetrics.go#L110-L123)):

    ```yaml
    kubecostMetrics:
      emitKsmV1MetricsOnly: true 
      emitKsmV1Metrics: false
    ```

  - The metrics that will still be emitted include:
    - Node metrics ([code ref](https://github.com/kubecost/cost-model/blob/0a0793ec040013fe44c058ff37f032449a2f1191/pkg/metrics/nodemetrics.go#L30-L57))
      - `kube_node_status_capacity`
      - `kube_node_status_capacity_memory_bytes`
      - `kube_node_status_capacity_cpu_cores`
      - `kube_node_status_allocatable`
      - `kube_node_status_allocatable_memory_bytes`
      - `kube_node_status_allocatable_cpu_cores`
      - `kube_node_labels`
      - `kube_node_status_condition`
    - Namespace metrics ([code ref](https://github.com/kubecost/cost-model/blob/0a0793ec040013fe44c058ff37f032449a2f1191/pkg/metrics/namespacemetrics.go#L121-L129))
      - `kube_namespace_labels`
    - Pod metrics ([code ref](https://github.com/kubecost/cost-model/blob/0a0793ec040013fe44c058ff37f032449a2f1191/pkg/metrics/podlabelmetrics.go#L51-L60))
      - `kube_pod_labels`
      - `kube_pod_owner`
  - If you are already running KSM v2, and have set the helm value to only emit KSM v1 metrics, you can also disable the Kubecost based KSM deployment by setting the helm value `prometheus.kube-state-metrics.disabled` to `true`.



<!--- {"article":"4408095797911","section":"4402829033367","permissiongroup":"1500001277122"} --->
