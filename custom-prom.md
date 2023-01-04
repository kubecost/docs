Prometheus Configuration Guide
==============================

## Bring your own Prometheus

There are several considerations when disabling the Kubecost included Prometheus deployment. Kubecost _strongly_ recommends installing Kubecost with the bundled Prometheus in most environments.

The Kubecost Prometheus deployment is optimized to not interfere with other observability instrumentation and by default only contains metrics that are useful to the Kubecost product. This results in __70-90% fewer metrics__ than a Prometheus deployment using default settings.

Additionally, if multi-cluster metric aggregation is required, Kubecost provides a turnkey solution that is highly tuned and simple to support using the included Prometheus deployment.

> **Note**: the Kubecost team provides best efforts support for free/community users when integrating with an existing Prometheus deployment.

## Disable node-exporter and kube-state-metrics (recommended)

If you have node-exporter and/or KSM running on your cluster, follow this step to disable the Kubecost included versions. Additional detail on [KSM requirements](https://github.com/kubecost/docs/blob/main/ksm-metrics.md).

> **Note**: In contrast to our recommendation above, we do recommend disabling the Kubecost's node-exporter and kube-state-metrics if you already have them running in your cluster.

  ```sh
  helm upgrade --install kubecost \
    --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
    --namespace kubecost --create-namespace \
    --set prometheus.nodeExporter.enabled=false \
    --set prometheus.serviceAccounts.nodeExporter.create=false \
    --set prometheus.kubeStateMetrics.enabled=false
  ```
## Dependency Requirements

Kubecost requires the following minimum versions:

- prometheus - v2.18 (support for v2.13 - v2.17 with limited features.)
- kube-state-metrics - v1.6.0+ (May 19)
- cAdvisor - kubelet v1.11.0+ (May 18)
- node-exporter - v0.16+ (May 18) [Optional]

## Steps to disable Kubecost's Prometheus Deployment (not recommended)

**Before continuing, see the note above about Kubecost's bundled prometheus**

1. Pass the following parameters in your helm install:

    ```sh
    helm upgrade --install kubecost \
      --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
      --namespace kubecost --create-namespace \
      --set global.prometheus.fqdn=http://<prometheus-server-service-name>.<prometheus-server-namespace>.svc \
      --set global.prometheus.enabled=false
    ```

    **Note** The fqdn can be a full path: https://prometheus-prod-us-central-x.grafana.net/api/prom/ if you use Grafana Cloud managed Prometheus. Learn more at [Grafana Cloud Integration for Kubecost](https://guide.kubecost.com/hc/en-us/articles/5699967551639-Grafana-Cloud-Integration-for-Kubecost)

1. Have your Prometheus scrape the cost-model `/metrics` endpoint. These metrics are needed for reporting accurate pricing data. Here is an example scrape config:

```yaml
- job_name: kubecost
      honor_labels: true
      scrape_interval: 1m
      scrape_timeout: 10s
      metrics_path: /metrics
      scheme: http
      dns_sd_configs:
      - names:
        - kubecost-cost-analyzer.<namespace-of-your-kubecost>
        type: 'A'
        port: 9003
```

This config needs to be added to  `extraScrapeConfigs` in the Prometheus configuration. Example [extraScrapeConfigs.yaml](https://raw.githubusercontent.com/kubecost/docs/main/extraScrapeConfigs.yaml)

To confirm this job is successfully scraped by Prometheus, you can view the Targets page in Prometheus and look for a job named `kubecost`.

![Prometheus Targets](https://raw.githubusercontent.com/kubecost/docs/main/prom-targets.png)

## Node exporter metric labels

> **Note**: This step is optional, and only impacts certain efficiency metrics. View [issue/556](https://github.com/kubecost/cost-model/issues/556) for a description of what will be missing if this step is skipped.

You'll need to add the following relabel config to the job that scrapes the node exporter DaemonSet.

```yaml
  - job_name: 'kubernetes-service-endpoints'

    kubernetes_sd_configs:
      - role: endpoints

    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_node_name]
        action: replace
        target_label: kubernetes_node
```

Note that this does not override the source label. It creates a new label called "kubernetes_node" and copies the value of pod into it.

## Troubleshooting

Visiting `<your-kubecost-endpoint>/diagnostics.html` provides diagnostics info on this integration. [More details](/diagnostics.md)

Common issues include the following:

**Wrong Prometheus FQDN**: Evidenced by the following pod error message `No valid prometheus config file at ...` and the init pods hanging. We recommend running `curl <your_prometheus_url>/api/v1/status/config` from a pod in the cluster to confirm that your [Prometheus config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#configuration-file) is returned. Here is an example, but this needs to be updated based on your pod name and Prometheus address:

```sh
kubectl exec -i -t -n kubecost $(kubectl get pod --namespace kubecost|grep analyzer -m1 |awk '{print $1}') -c cost-analyzer-frontend -- curl http://<your_prometheus_url>/api/v1/status/config
```

> **Note**: In the above example, `$(kubectl get pod --namespace kubecost|grep analyzer -m1 |awk '{print $1}')` simply finds the name of a cost analyzer pod. You can replace this with the pod name, example: `kubecost-cost-analyzer-5bc6947b94-58hmx`

> **Note**: In the above example, <your_prometheus_url> may include a port number and/or namespace, example: `http://prometheus-operator-kube-p-prometheus.monitoring:9090/api/v1/status/config`

If the config file is not returned, this is an indication that an incorrect Prometheus address has been provided. If a config file is returned from one pod in the cluster but not the Kubecost pod, then the Kubecost pod likely has its access restricted by a network policy, service mesh, etc.

**Context Deadline Exceeded**: Network policies, Mesh networks, or other security related tooling can block network traffic between Prometheus and Kubecost which will result in the Kubecost scrape target state as being down in the Prometheus targets UI. To assist in troubleshooting this type of error you can use the `wget` command from within the Prometheus Server container to try and reach the Kubecost target manually. Note the "namespace" and "deployment" name in this command may need updated to match your environment, this example uses the default Kubecost Prometheus deployment.\

When successfully this command should return all of the Kubecost metrics. Failures may be indicative of the network traffic being blocked.

```sh
kubectl exec -i -t -n kubecost $(kubectl get pod --namespace kubecost|grep analyzer -m1 |awk '{print $1}') -c cost-analyzer-frontend -- curl "http://localhost:9003/metrics"
```

**Prometheus throttling**: Ensure Prometheus isn't being CPU throttled due to a low resource request.

**Wrong dependency version**: Review the Dependency Requirements section above

**Missing scrape configs**: Visit Prometheus Targets page (screenshot above)

**Data incorrectly is a single namespace**: Make sure that [honor_labels](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config) is enabled

**Negative idle reported**

1. Make sure prometheus is scraping Kubecost search metrics for: `node_total_hourly_cost`

  ```sh
  kubectl exec -i -t -n kubecost $(kubectl get pod --namespace kubecost|grep analyzer -m1 |awk '{print $1}') -c cost-analyzer-frontend -- curl "http://localhost:9003/metrics" | grep node_total_hourly_cost
  ```
2. Ensure kube-state-metrics are available: `kube_node_status_capacity`

  ```sh
  kubectl exec -i -t -n kubecost $(kubectl get pod --namespace kubecost|grep analyzer -m1 |awk '{print $1}') -c cost-analyzer-frontend -- curl "http://localhost:9003/metrics" | grep kube_node_status_capacity
  ```

In Kubecost, you can view basic diagnostic information on these Prometheus metrics by selecting _Settings_ in the left navigation, then scrolling down to Prometheus Status, as seen below:

![Prometheus status diagnostic](https://raw.githubusercontent.com/kubecost/docs/main/prom-status.png)
