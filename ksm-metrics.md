# Kube-State-Metrics (KSM) Emission

Since the Kubecost cost-model depends on a number of metrics emitted by kube-state-metrics, any schema changes to the expected metrics pose a long-term reliability challenge. In order to become resilient to said changes, the cost-model emits all required kube-state-metrics by default. While the result could yield double emission for some KSM metrics, it guarantees compatibility if KSM were to branch/drop specific metrics (as seen in KSM v2).

## KSM metrics emitted by Kubecost cost-model

The following table shows all KSM metrics required by and implemented in the cost-model, which are also the metrics being replicated:

| Category       | KSM Metric                                                   |
| -------------- | ------------------------------------------------------------ |
| **Node**       | `kube_node_status_condition`                                 |
|                | `kube_node_status_capacity`                                  |
|                | `kube_node_status_capacity_memory_bytes`                     |
|                | `kube_node_status_capacity_cpu_cores`                        |
|                | `kube_node_status_allocatable`                               |
|                | `kube_node_status_allocatable_cpu_cores`                     |
|                | `kube_node_status_allocatable_memory_bytes`                  |
|                | `kube_node_labels`                                           |
| **Namespace**  | `kube_namespace_labels`                                      |
|                | `kube_namespace_annotations`                                 |
| **Deployment** | `kube_deployment_spec_replicas`                              |
|                | `kube_deployment_status_replicas_available`                  |
| **Pod**        | `kube_pod_owner`                                             |
|                | `kube_pod_labels`                                            |
|                | `kube_pod_container_status_running`                          |
|                | `kube_pod_container_resource_requests`                       |
|                | `kube_pod_annotations`                                       |
|                | `kube_pod_status_phase`                                      |
|                | `kube_pod_container_status_terminated_reason`                |
|                | `kube_pod_container_status_restarts_total`                   |
|                | `kube_pod_container_resource_limits`                         |
|                | `kube_pod_container_resource_limits_cpu_cores`               |
|                | `kube_pod_container_resource_limits_memory_bytes`            |
| **PV**         | `kube_persistentvolume_capacity_bytes`                       |
|                | `kube_persistentvolume_status_phase`                         |
| **PVC**        | `kube_persistentvolumeclaim_info`                            |
|                | `kube_persistentvolumeclaim_resource_requests_storage_bytes` |
| **Job**        | `kube_job_status_failed`                                     |

## Disabling Kubecost-based KSM deployment

{% hint style="warning" %}
Disabling the KSM deployment is not recommended, and will require higher up-time on the Kubecost cost-model to ensure accuracy of Kubecost data.
{% endhint %}

One of the more obvious questions here is: _"If the metrics you are emitting cover all of the KSM requirements, could the KSM deployment be dropped?"_ The long-term plan is to drop our dependency on KSM, and while it is possible to omit the KSM deployment today, doing so would require higher up-time on the cost-model to ensure the accuracy of these metrics. Part of reaching this long-term goal requires the deployment of a pod responsible for all Kubecost metric emissions separate from the cost-model to ensure reliability and high uptime.&#x20;

```yaml
prometheus.kube-state-metrics:
    disabled: false
```

## Disabling Kubecost cost-model's KSM emission

{% hint style="warning" %}
While not recommended, you can disable Kubecost cost-model's emission of KSM if you are already running your own KSM.
{% endhint %}

{% code overflow="wrap" %}
```yaml
kubecostMetrics:
  emitKsmV1Metrics: false
  # If you are running KSMv2, you must set the below config as well. More details below.
  emitKsmV1MetricsOnly: true
```
{% endcode %}

## Disabling individual metrics

{% hint style="warning" %}
Disabling individual metrics is not recommended, as disabling metrics required by Kubecost to function may lead to unexpected behavior.
{% endhint %}

It is possible to disable individual metrics emitted by Kubecost if a more fine-grained approach is required. This can be done by setting the related [Helm chart parameter](https://github.com/kubecost/cost-analyzer-helm-chart/blob/f9a8f3326a540e1b0ece714c52f100fa085bf0b8/cost-analyzer/values.yaml#L928-L929):

```yaml
kubecostProductConfigs:
  ...
  metricsConfigs:
    disabledMetrics:
      - <metric-to-be-disabled>
      - <metric-to-be-disabled>
      etc.
```

## External KSM deployments resulting in duplicated metrics

If your Prometheus deployment is scraping both Kubecost _and_ an external KSM deployment outside of Kubecost, there will be duplicated KSM metrics.

Kubecost itself is resilient to duplicate metrics, but other services or queries could be affected. There are several approaches for handling this problem:

* Remove the external KSM from the cluster. If you do this, only the Kubecost-emitted metrics listed above should be available. However, This could cause other services that depend on KSM metrics to fail.
* Rewrite queries that cannot handle duplicate metrics to include a filter on `job=<external-KSM-scrape-job>` or to be generally resilient to duplication using query functions like `avg_over_time`.
* Run a separate Prometheus for Kubecost alone (the default installation behavior of Kubecost) and disable the scraping of Kubecost's metrics in your other Prometheus configurations.
*   We support reducing some duplication from Kubecost via config. To reduce the emission of metrics that overlap with metrics provided by KSM v2 you can set the following Helm values ([code ref](https://github.com/kubecost/cost-model/blob/0a0793ec040013fe44c058ff37f032449a2f1191/pkg/metrics/kubemetrics.go#L110-L123)):

    ```yaml
    kubecostMetrics:
      emitKsmV1MetricsOnly: true
      emitKsmV1Metrics: false
    ```

    * The metrics that will still be emitted include:
      * Node metrics ([code ref](https://github.com/kubecost/cost-model/blob/0a0793ec040013fe44c058ff37f032449a2f1191/pkg/metrics/nodemetrics.go#L30-L57))
        * `kube_node_status_capacity`
        * `kube_node_status_capacity_memory_bytes`
        * `kube_node_status_capacity_cpu_cores`
        * `kube_node_status_allocatable`
        * `kube_node_status_allocatable_memory_bytes`
        * `kube_node_status_allocatable_cpu_cores`
        * `kube_node_labels`
        * `kube_node_status_condition`
      * Namespace metrics ([code ref](https://github.com/kubecost/cost-model/blob/0a0793ec040013fe44c058ff37f032449a2f1191/pkg/metrics/namespacemetrics.go#L121-L129))
        * `kube_namespace_labels`
      * Pod metrics ([code ref](https://github.com/kubecost/cost-model/blob/0a0793ec040013fe44c058ff37f032449a2f1191/pkg/metrics/podlabelmetrics.go#L51-L60))
        * `kube_pod_labels`
        * `kube_pod_owner`
    * If you are already running KSM v2, and have set the helm value to only emit KSM v1 metrics, you can also disable the Kubecost-based KSM deployment by setting the helm value `prometheus.kube-state-metrics.disabled` to `true`.
