# Grafana Mimir Integration for Kubecost

In the standard deployment of [Kubecost](https://www.kubecost.com/), Kubecost is deployed with a bundled Prometheus instance to collect and store metrics of your Kubernetes cluster. Kubecost also provides the flexibility to connect with your time series database or storage. [Grafana Mimir](https://grafana.com/oss/mimir/) is an open-source, horizontally scalable, highly available, multi-tenant TSDB for long-term storage for Prometheus.

This document will show you how to integrate the Grafana Mimir with Kubecost for long-term metrics retention. In this setup, you need to use Grafana Agent to collect metrics from Kubecost and your Kubernetes cluster. The metrics will be re-written to your existing [Grafana Mimir setup without an authenticating reverse proxy](https://grafana.com/docs/mimir/latest/operators-guide/secure/authentication-and-authorization/#without-an-authenticating-reverse-proxy)

## Prerequisites

* You have access to a running Kubernetes cluster
* You have an existing Grafana Mimir setup

## Step 1: Install the Grafana Agent on your cluster

Install the Grafana Agent for Kubernetes on your cluster. On the existing K8s cluster that you intend to install Kubecost, run the following commands to install the Grafana Agent to scrape the metrics from Kubecost `/metrics` endpoint. The script below installs the Grafana Agent with the necessary scraping configuration for Kubecost, you may want to add additional scrape configuration for your setup.

{% code overflow="wrap" %}
```bash
export CLUSTER_NAME="YOUR_CLUSTER_NAME"
export MIMIR_ENDPOINT="http://example-mimir.com/api/v1/push"

cat <<EOF |

kind: ConfigMap
metadata:
  name: grafana-agent
apiVersion: v1
data:
  agent.yaml: |
    metrics:
      wal_directory: /var/lib/agent/wal
      global:
        scrape_interval: 60s
        external_labels:
          cluster: ${CLUSTER_NAME}
      configs:
      - name: integrations
        remote_write:
        - headers:
            X-Scope-OrgID: kubecost_mimir
          url: ${MIMIR_ENDPOINT}
        - url: ${MIMIR_ENDPOINT}
        scrape_configs: #Need further scrape config update
        - job_name: kubecost
          honor_labels: true
          scrape_interval: 1m
          scrape_timeout: 10s
          metrics_path: /metrics
          scheme: http
          dns_sd_configs:
          - names:
            - kubecost-cost-analyzer.kubecost
            type: 'A'
            port: 9003
        - job_name: kubecost-networking
          kubernetes_sd_configs:
            - role: pod
          relabel_configs:
          # Scrape only the the targets matching the following metadata
            - source_labels: [__meta_kubernetes_pod_label_app]
              action: keep
              regex:  'kubecost-network-costs'
        - job_name: prometheus
          static_configs:
            - targets:
              - localhost:9090
        - job_name: 'kubernetes-nodes-cadvisor'
          scheme: https
          tls_config:
            ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
            insecure_skip_verify: true
          bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
          kubernetes_sd_configs:
            - role: node
          relabel_configs:
            - action: labelmap
              regex: __meta_kubernetes_node_label_(.+)
            - target_label: __address__
              replacement: kubernetes.default.svc:443
            - source_labels: [__meta_kubernetes_node_name]
              regex: (.+)
              target_label: __metrics_path__
              replacement: /api/v1/nodes/$1/proxy/metrics/cadvisor
          metric_relabel_configs:
            - source_labels: [ __name__ ]
              regex: (container_cpu_usage_seconds_total|container_memory_working_set_bytes|container_network_receive_errors_total|container_network_transmit_errors_total|container_network_receive_packets_dropped_total|container_network_transmit_packets_dropped_total|container_memory_usage_bytes|container_cpu_cfs_throttled_periods_total|container_cpu_cfs_periods_total|container_fs_usage_bytes|container_fs_limit_bytes|container_cpu_cfs_periods_total|container_fs_inodes_free|container_fs_inodes_total|container_fs_usage_bytes|container_fs_limit_bytes|container_cpu_cfs_throttled_periods_total|container_cpu_cfs_periods_total|container_network_receive_bytes_total|container_network_transmit_bytes_total|container_fs_inodes_free|container_fs_inodes_total|container_fs_usage_bytes|container_fs_limit_bytes|container_spec_cpu_shares|container_spec_memory_limit_bytes|container_network_receive_bytes_total|container_network_transmit_bytes_total|container_fs_reads_bytes_total|container_network_receive_bytes_total|container_fs_writes_bytes_total|container_fs_reads_bytes_total|cadvisor_version_info|kubecost_pv_info)
              action: keep
            - source_labels: [ container ]
              target_label: container_name
              regex: (.+)
              action: replace
            - source_labels: [ pod ]
              target_label: pod_name
              regex: (.+)
              action: replace
        - job_name: 'kubernetes-nodes'
          tls_config:
            ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
            insecure_skip_verify: true
          bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token

          kubernetes_sd_configs:
            - role: node

          relabel_configs:
            - action: labelmap
              regex: __meta_kubernetes_node_label_(.+)
            - target_label: __address__
              replacement: kubernetes.default.svc:443
            - source_labels: [__meta_kubernetes_node_name]
              regex: (.+)
              target_label: __metrics_path__
              replacement: /api/v1/nodes/$1/proxy/metrics

          metric_relabel_configs:
            - source_labels: [ __name__ ]
              regex: (kubelet_volume_stats_used_bytes) # this metric is in alpha
              action: keep

        - job_name: 'kubernetes-service-endpoints'

          kubernetes_sd_configs:
            - role: endpoints

          relabel_configs:
            - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape]
              action: keep
              regex: true
            - source_labels: [__meta_kubernetes_endpoints_name]
              action: keep
              regex: (.*kube-state-metrics|.*prometheus-node-exporter|kubecost-network-costs)
            - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
              action: replace
              target_label: __scheme__
              regex: (https?)
            - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
              action: replace
              target_label: __metrics_path__
              regex: (.+)
            - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
              action: replace
              target_label: __address__
              regex: ([^:]+)(?::\d+)?;(\d+)
              replacement: $1:$2
            - action: labelmap
              regex: __meta_kubernetes_service_label_(.+)
            - source_labels: [__meta_kubernetes_namespace]
              action: replace
              target_label: kubernetes_namespace
            - source_labels: [__meta_kubernetes_service_name]
              action: replace
              target_label: kubernetes_name
            - source_labels: [__meta_kubernetes_pod_node_name]
              action: replace
              target_label: kubernetes_node
          metric_relabel_configs:
            - source_labels: [ __name__ ]
              regex: (container_cpu_allocation|container_cpu_usage_seconds_total|container_fs_limit_bytes|container_fs_writes_bytes_total|container_gpu_allocation|container_memory_allocation_bytes|container_memory_usage_bytes|container_memory_working_set_bytes|container_network_receive_bytes_total|container_network_transmit_bytes_total|DCGM_FI_DEV_GPU_UTIL|deployment_match_labels|kube_daemonset_status_desired_number_scheduled|kube_daemonset_status_number_ready|kube_deployment_spec_replicas|kube_deployment_status_replicas|kube_deployment_status_replicas_available|kube_job_status_failed|kube_namespace_annotations|kube_namespace_labels|kube_node_info|kube_node_labels|kube_node_status_allocatable|kube_node_status_allocatable_cpu_cores|kube_node_status_allocatable_memory_bytes|kube_node_status_capacity|kube_node_status_capacity_cpu_cores|kube_node_status_capacity_memory_bytes|kube_node_status_condition|kube_persistentvolume_capacity_bytes|kube_persistentvolume_status_phase|kube_persistentvolumeclaim_info|kube_persistentvolumeclaim_resource_requests_storage_bytes|kube_pod_container_info|kube_pod_container_resource_limits|kube_pod_container_resource_limits_cpu_cores|kube_pod_container_resource_limits_memory_bytes|kube_pod_container_resource_requests|kube_pod_container_resource_requests_cpu_cores|kube_pod_container_resource_requests_memory_bytes|kube_pod_container_status_restarts_total|kube_pod_container_status_running|kube_pod_container_status_terminated_reason|kube_pod_labels|kube_pod_owner|kube_pod_status_phase|kube_replicaset_owner|kube_statefulset_replicas|kube_statefulset_status_replicas|kubecost_cluster_info|kubecost_cluster_management_cost|kubecost_cluster_memory_working_set_bytes|kubecost_load_balancer_cost|kubecost_network_internet_egress_cost|kubecost_network_region_egress_cost|kubecost_network_zone_egress_cost|kubecost_node_is_spot|kubecost_pod_network_egress_bytes_total|node_cpu_hourly_cost|node_cpu_seconds_total|node_disk_reads_completed|node_disk_reads_completed_total|node_disk_writes_completed|node_disk_writes_completed_total|node_filesystem_device_error|node_gpu_count|node_gpu_hourly_cost|node_memory_Buffers_bytes|node_memory_Cached_bytes|node_memory_MemAvailable_bytes|node_memory_MemFree_bytes|node_memory_MemTotal_bytes|node_network_transmit_bytes_total|node_ram_hourly_cost|node_total_hourly_cost|pod_pvc_allocation|pv_hourly_cost|service_selector_labels|statefulSet_match_labels|kubecost_pv_info|up)
              action: keep

        - job_name: 'kubernetes-service-endpoints-slow'

          scrape_interval: 5m
          scrape_timeout: 30s

          kubernetes_sd_configs:
            - role: endpoints

          relabel_configs:
            - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scrape_slow]
              action: keep
              regex: true
            - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_scheme]
              action: replace
              target_label: __scheme__
              regex: (https?)
            - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_path]
              action: replace
              target_label: __metrics_path__
              regex: (.+)
            - source_labels: [__address__, __meta_kubernetes_service_annotation_prometheus_io_port]
              action: replace
              target_label: __address__
              regex: ([^:]+)(?::\d+)?;(\d+)
              replacement: $1:$2
            - action: labelmap
              regex: __meta_kubernetes_service_label_(.+)
            - source_labels: [__meta_kubernetes_namespace]
              action: replace
              target_label: kubernetes_namespace
            - source_labels: [__meta_kubernetes_service_name]
              action: replace
              target_label: kubernetes_name
            - source_labels: [__meta_kubernetes_pod_node_name]
              action: replace
              target_label: kubernetes_node

        - job_name: 'kubernetes-services'

          metrics_path: /probe
          params:
            module: [http_2xx]

          kubernetes_sd_configs:
            - role: service

          relabel_configs:
            - source_labels: [__meta_kubernetes_service_annotation_prometheus_io_probe]
              action: keep
              regex: true
            - source_labels: [__address__]
              target_label: __param_target
            - target_label: __address__
              replacement: blackbox
            - source_labels: [__param_target]
              target_label: instance
            - action: labelmap
              regex: __meta_kubernetes_service_label_(.+)
            - source_labels: [__meta_kubernetes_namespace]
              target_label: kubernetes_namespace
            - source_labels: [__meta_kubernetes_service_name]
              target_label: kubernetes_name

EOF
(export NAMESPACE=kubecost && kubectl apply -n $NAMESPACE -f -)

MANIFEST_URL=https://raw.githubusercontent.com/grafana/agent/v0.24.2/production/kubernetes/agent-bare.yaml NAMESPACE=kubecost /bin/sh -c "$(curl -fsSL https://raw.githubusercontent.com/grafana/agent/v0.24.2/production/kubernetes/install-bare.sh)" | kubectl apply -f -
```
{% endcode %}

You can also verify if `grafana-agent` is scraping data with the following command (optional):

```bash
kubectl -n kubecost logs grafana-agent-0
```

To learn more about how to install and configure the Grafana agent, as well as additional scrape configuration, please refer to [Grafana Agent](https://grafana.com/docs/tempo/latest/configuration/grafana-agent/) documentation, or you can view the Kubecost Prometheus scrape config at this [GitHub repository](https://github.com/kubecost/cost-analyzer-helm-chart/blob/ebe7e088debecd23f90e6dd75b425828901a246c/cost-analyzer/charts/prometheus/values.yaml#L1152).

## Step 2: Deploy Kubecost

Run the following command to deploy Kubecost. Please remember to update the environment variables values with your Mimir setup information.

{% code overflow="wrap" %}
```bash
export MIMIR_ENDPOINT="http://example-mimir.com/"
export MIMIR_ORG_ID="YOUR_MIMIR_ORG_ID"
helm upgrade -i kubecost cost-analyzer/ -n kubecost --create-namespace \
--set global.mimirProxy.enabled=true \
--set global.prometheus.enabled=false \
--set global.prometheus.fqdn=http://kubecost-cost-analyzer-mimir-proxy.kubecost.svc:8085/prometheus \
--set global.mimirProxy.mimirEndpoint=http://${MIMIR_ENDPOINT} \
--set global.mimirProxy.orgIdentifier=${MIMIR_ORG_ID}
```
{% endcode %}

The process is complete. By now, you should have successfully completed the Kubecost integration with your Grafana Mimir setup.
