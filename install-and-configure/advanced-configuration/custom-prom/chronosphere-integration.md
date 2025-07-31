# Chronosphere Observability Platform Integration for Kubecost

In the standard deployment of [Kubecost](https://www.kubecost.com/), Kubecost is deployed with a bundled Prometheus instance to collect and store metrics of your Kubernetes cluster. Kubecost also provides the flexibility to connect with your time series database or storage. [Chronosphere Observability Platform](https://grafana.com/products/cloud/) is an end-to-end observability solution allowing teams to harness the most useful data, reduce spend, boost developer efficiency, and remediate faster.

This document will show you how to integrate the Chronosphere Observability Platform with Kubecost using [OpenTelemetry Collector](https://github.com/open-telemetry/opentelemetry-collector-contrib).

## Prerequisites

* You have access to a running Kubernetes cluster
* You have installed and configured [OpenTelemetry Collector](https://github.com/open-telemetry/opentelemetry-collector-contrib) with [Prometheus Receiver module](https://github.com/open-telemetry/opentelemetry-collector-contrib/tree/main/receiver/prometheusreceiver)
* You have successfully collected metrics from cAdvisor, Kube State Metrics and Node Exporters
* You have a Chronosphere Observability Platform account
* You have permissions to create Chronosphere Observability Platform API keys

## Step 1: Create a Secret to store Chronosphere API token

* `kubectl create ns kubecost`
* `kubectl -n kubecost create secret generic chronosphere-secret --from-literal=TOKEN=<chronosphere-api-token>`

Assume kubecost is the namespace where you want to install Kubecost.

## Step 2: Install Kubecost using HELM

```bash
helm upgrade --install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer  \
  --namespace kubecost \
  --set global.prometheus.fqdn=https://<tenant>.chronosphere.io/data/metrics/ \
  --set global.prometheus.enabled=false \
  --set global.grafana.enabled=false \
  --set global.grafana.proxy=false \
  --set global.prometheus.queryServiceBearerTokenSecretName=chronosphere-secret
```

Replace \<tenant\> with the actual tenant name of your Chronosphere Observability Platform account. chronosphere-secret is the name of the Secret created in Step 1.

## Step 3: Add configuration to OpenTelemetry's Prometheus Receiver to scrape metrics from kubecost

Add two scape jobs to Prometheus receiver configuration like below assuming Kubecost is installed in namespace, kubecost:

```yaml
  receivers:
    prometheus:
      config:
        scrape_configs:
          - job_name: kubecost
            honor_labels: true
            scrape_interval: 1m
            scrape_timeout: 10s
            metrics_path: /metrics
            scheme: http
            dns_sd_configs:
              - names:
                  - kubecost-cost-analyzer.kubecost
                type: "A"
                port: 9003
          - job_name: kubecost-networking
            kubernetes_sd_configs:
              - role: pod
            relabel_configs:
              # Scrape only the the targets matching the following metadata
              - source_labels: [__meta_kubernetes_pod_label_app]
                action: keep
                regex: "kubecost-network-costs"
```

When pods are ready, you can enable port-forwarding with the following command:

```bash
kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090
```

Then, navigate to <http://localhost:9090> in a web browser.

Please allow 25 minutes for Kubecost to gather metrics. A progress indicator will appear at the top of the UI.

## Step 4 (optional): Configure recording rules to enhance performance

Create a file called _kubecost\_rules.yaml_ with the following command:

{% code overflow="wrap" %}

```yaml
cat << EOF > kubecost-rules.yaml
api_version: v1/config
kind: RecordingRule
spec:
  name: cluster-cpu-usage-rate5m
  slug: cluster-cpu-usage-rate5m
  prometheus_expr: sum(rate(container_cpu_usage_seconds_total{container!=""}[5m]))
  metric_name: cluster:cpu_usage:rate5m
  interval_secs: 300
  execution_group: cpu
---
api_version: v1/config
kind: RecordingRule
spec:
  name: cluster-cpu-usage-nosum-rate5m
  slug: cluster-cpu-usage-nosum-rate5m
  prometheus_expr: rate(container_cpu_usage_seconds_total{container!=""}[5m])
  metric_name: cluster:cpu_usage_nosum:rate5m
  interval_secs: 300
  execution_group: cpu
---
api_version: v1/config
kind: RecordingRule
spec:
  name: kubecost-container-cpu-usage-irate
  slug: kubecost-container-cpu-usage-irate
  prometheus_expr: avg(irate(container_cpu_usage_seconds_total{container!="POD", container!=""}[5m])) by (container,pod, namespace)
  metric_name: kubecost_container_cpu_usage_irate
  interval_secs: 300
  execution_group: cpu
---
api_version: v1/config
kind: RecordingRule
spec:
  name: kubecost-container-memory-working-set-bytes
  slug: kubecost-container-memory-working-set-bytes
  prometheus_expr: sum(container_memory_working_set_bytes{container!="POD",container!=""}) by (container, pod, namespace)
  metric_name: kubecost_container_memory_working_set_bytes
  interval_secs: 300
  execution_group: cpu
---
api_version: v1/config
kind: RecordingRule
spec:
  name: kubecost-cluster-memory-working-set-bytes
  slug: kubecost-cluster-memory-working-set-bytes
  prometheus_expr: sum(container_memory_working_set_bytes{container!="POD",container!=""})
  metric_name: kubecost_cluster_memory_working_set_bytes
  interval_secs: 300
  execution_group: cpu
---
api_version: v1/config
kind: RecordingRule
spec:
  name: kubecost-savings-cpu-allocation-daemonset-false
  slug: kubecost-savings-cpu-allocation-daemonset-false
  prometheus_expr: sum(avg(kube_pod_owner{owner_kind!="DaemonSet"}) by (pod) * sum(container_cpu_allocation) by (pod))
  metric_name: kubecost_savings_cpu_allocation
  interval_secs: 300
  execution_group: savings
  label_policy:
    add:
      daemonset: "false"
---
api_version: v1/config
kind: RecordingRule
spec:
  name: kubecost-savings-cpu-allocation-daemonset-true
  slug: kubecost-savings-cpu-allocation-daemonset-true
  prometheus_expr: sum(avg(kube_pod_owner{owner_kind="DaemonSet"}) by (pod) * sum(container_cpu_allocation) by (pod)) / sum(kube_node_info)
  metric_name: kubecost_savings_cpu_allocation
  interval_secs: 300
  execution_group: savings
  label_policy:
    add:
      daemonset: "true"
---
api_version: v1/config
kind: RecordingRule
spec:
  name: kubecost-savings-memory-allocation-bytes-daemonset-false
  slug: kubecost-savings-memory-allocation-bytes-daemonset-false
  prometheus_expr: sum(avg(kube_pod_owner{owner_kind!="DaemonSet"}) by (pod) * sum(container_memory_allocation_bytes) by (pod))
  metric_name: kubecost_savings_memory_allocation_bytes
  interval_secs: 300
  execution_group: savings
  label_policy:
    add:
      daemonset: "false"
---
api_version: v1/config
kind: RecordingRule
spec:
  name: kubecost-savings-memory-allocation-bytes-daemonset-true
  slug: kubecost-savings-memory-allocation-bytes-daemonset-true
  prometheus_expr: sum(avg(kube_pod_owner{owner_kind="DaemonSet"}) by (pod) * sum(container_memory_allocation_bytes) by (pod)) / sum(kube_node_info)
  metric_name: kubecost_savings_memory_allocation_bytes
  interval_secs: 300
  execution_group: savings
  label_policy:
    add:
      daemonset: "true"
EOF
```

{% endcode %}

Then, use [chronoctl](https://docs.chronosphere.io/chronoctl/install) (Chronosphere's CLI tool) to create rules on the platform with the following command:

```bash
# Read the file and split based on '---', process each rule
awk '
  BEGIN { rule = "" }
  /^---$/ { if (rule != "") { print rule | "chronoctl recording-rules create -f -"; close("chronoctl recording-rules create -f -"); rule = "" } }
  { rule = rule $0 ORS }
  END { if (rule != "") { print rule | "chronoctl recording-rules create -f -"; close("chronoctl recording-rules create -f -") } }
' "kubecost-rules.yaml"
```

The process is complete. By now, you should have successfully completed the Kubecost integration with Chronosphere Observability Platform.
