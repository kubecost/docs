# Kube-State-Metrics (KSM) Emission

Kubecost no longer includes a bundled [KSM deployment](https://github.com/kubernetes/kube-state-metrics).

Kubecost emits the KSM metrics that it requires and uses these when building the cost-model.

To add all kube-state-metrics, in addition to the metrics provided by default, see the [Adding external KSM metrics to Kubecost](#adding-external-ksm-metrics-to-kubecost) section below.

## KSM metrics emitted by Kubecost

The following are all KSM metrics required by and implemented in Kubecost.

The below metrics and labels follow conventions of KSMv1, not KSMv2.

### Node metrics

* `kube_node_status_condition`
* `kube_node_status_capacity`
* `kube_node_status_capacity_memory_bytes`
* `kube_node_status_capacity_cpu_cores`
* `kube_node_status_allocatable`
* `kube_node_status_allocatable_cpu_cores`
* `kube_node_status_allocatable_memory_bytes`
* `kube_node_labels`

### Namespace metrics

* `kube_namespace_labels`
* `kube_namespace_annotations`

### Deployment metrics

* `kube_deployment_spec_replicas`
* `kube_deployment_status_replicas_available`

### Pod metrics

* `kube_pod_owner`
* `kube_pod_labels`
* `kube_pod_container_status_running`
* `kube_pod_container_resource_requests`
* `kube_pod_annotations`
* `kube_pod_status_phase`
* `kube_pod_container_status_terminated_reason`
* `kube_pod_container_status_restarts_total`
* `kube_pod_container_resource_limits`
* `kube_pod_container_resource_limits_cpu_cores`
* `kube_pod_container_resource_limits_memory_bytes`

### PV metrics

* `kube_persistentvolume_capacity_bytes`
* `kube_persistentvolume_status_phase`

### PVC metrics

* `kube_persistentvolumeclaim_info`
* `kube_persistentvolumeclaim_resource_requests_storage_bytes`

### Job metrics

* `kube_job_status_failed`

## Disabling Kubecost's KSM emission

{% hint style="warning" %}
If these metrics are duplicate, you can disable Kubecost's emission of KSM. Keep in mind that the format of Kubecost's KSM differ from KSM v2 metrics. Inaccurate costs and pod to controller mappings will break if these metrics are not available.
{% endhint %}

{% code overflow="wrap" %}

```yaml
kubecostMetrics:
  emitKsmV1Metrics: false
  # If you are running KSMv2, you must also set the below config. More details below.
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
* We support reducing some duplication from Kubecost via config. To reduce the emission of metrics that overlap with metrics provided by KSM v2 you can set the following Helm values ([code ref](https://github.com/kubecost/cost-model/blob/0a0793ec040013fe44c058ff37f032449a2f1191/pkg/metrics/kubemetrics.go#L110-L123)):

  ```yaml
  kubecostMetrics:
    emitKsmV1Metrics: false
    emitKsmV1MetricsOnly: true
  ```

  * The metrics that will still be emitted include:
    * [Node metrics](https://github.com/kubecost/cost-model/blob/0a0793ec040013fe44c058ff37f032449a2f1191/pkg/metrics/nodemetrics.go#L30-L57)
      * `kube_node_status_capacity`
      * `kube_node_status_capacity_memory_bytes`
      * `kube_node_status_capacity_cpu_cores`
      * `kube_node_status_allocatable`
      * `kube_node_status_allocatable_memory_bytes`
      * `kube_node_status_allocatable_cpu_cores`
      * `kube_node_labels`
      * `kube_node_status_condition`
    * [Namespace metrics](https://github.com/kubecost/cost-model/blob/0a0793ec040013fe44c058ff37f032449a2f1191/pkg/metrics/namespacemetrics.go#L121-L129)
      * `kube_namespace_labels`
    * [Pod metrics](https://github.com/kubecost/cost-model/blob/0a0793ec040013fe44c058ff37f032449a2f1191/pkg/metrics/podlabelmetrics.go#L51-L60)
      * `kube_pod_labels`
      * `kube_pod_owner`

## Adding external KSM metrics to Kubecost

A simple method to add kube-state-metrics to the Kubecost-bundled Prometheus Server is to install KSM with helm and add the service it creates as a scrape target.

Install KSM from the [Prometheus Community Helm Charts](https://github.com/prometheus-community/helm-charts)

```bash
helm install kube-state-metrics \
  --repo https://prometheus-community.github.io/helm-charts kube-state-metrics \
  --namespace kube-state-metrics --create-namespace
```

Add KSM to your Kubecost Helm values in the extraScrapeConfigs:

```yaml
prometheus:
  extraScrapeConfigs: |
    - job_name: kubecost
      honor_labels: true
      scrape_interval: 1m
      scrape_timeout: 60s
      metrics_path: /metrics
      scheme: http
      dns_sd_configs:
      - names:
        - {{ template "cost-analyzer.serviceName" . }}
        type: 'A'
        port: 9003
    - job_name: kubecost-networking
      kubernetes_sd_configs:
        - role: pod
      relabel_configs:
      # Scrape only the the targets matching the following metadata
        - source_labels: [__meta_kubernetes_pod_label_app_kubernetes_io_instance]
          action: keep
          regex:  kubecost
        - source_labels: [__meta_kubernetes_pod_label_app_kubernetes_io_name]
          action: keep
          regex:  network-costs
    - job_name: kube-state-metrics
      kubernetes_sd_configs:
        - role: pod
      relabel_configs:
      # Scrape only the the targets matching the following metadata
        - source_labels: [__meta_kubernetes_pod_label_app_kubernetes_io_instance]
          action: keep
          regex:  kube-state-metrics
        - source_labels: [__meta_kubernetes_pod_label_app_kubernetes_io_name]
          action: keep
          regex:  kube-state-metrics
```
