# Prometheus Configuration Guide

## Bring your own Prometheus

There are several considerations when disabling the Kubecost included Prometheus deployment. Kubecost _strongly_ recommends installing Kubecost with the bundled Prometheus in most environments.

The Kubecost Prometheus deployment is optimized to not interfere with other observability instrumentation and by default only contains metrics that are useful to the Kubecost product. This results in **70-90% fewer metrics** than a Prometheus deployment using default settings.

Additionally, if multi-cluster metric aggregation is required, Kubecost provides a turnkey solution that is highly tuned and simple to support using the included Prometheus deployment.

{% hint style="warning" %}
This feature is accessible to all users. However, please note that comprehensive support is exclusive to those with paid support plans.
{% endhint %}

## Dependency requirements

Kubecost requires the following minimum versions:

* Prometheus: v2.18 (v2.13-2.17 supported with limited functionality)
* kube-state-metrics: v1.6.0+
* cAdvisor: kubelet v1.11.0+
* node-exporter: v0.16+ (Optional)

## Instructions

### Disable node-exporter and kube-state-metrics (recommended)

If you have node-exporter and/or KSM running on your cluster, follow this step to disable the Kubecost included versions. Additional detail on [KSM requirements](ksm-metrics.md).

{% hint style="info" %}
In contrast to our recommendation above, we do recommend disabling the Kubecost's node-exporter and kube-state-metrics if you already have them running in your cluster.
{% endhint %}

```
helm upgrade --install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost --create-namespace \
  --set prometheus.nodeExporter.enabled=false \
  --set prometheus.serviceAccounts.nodeExporter.create=false \
  --set prometheus.kubeStateMetrics.enabled=false
```

### Disabling Kubecost's Prometheus deployment

{% hint style="warning" %}
This process is not recommended. Before continuing, review the [Bring your own Prometheus](https://docs.kubecost.com/install-and-configure/install/custom-prom#bring-your-own-prometheus) section if you haven't already.
{% endhint %}

1.  Pass the following parameters in your Helm install:

    {% code overflow="wrap" %}
    ```
    helm upgrade --install kubecost \
      --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
      --namespace kubecost --create-namespace \
      --set global.prometheus.fqdn=http://<prometheus-server-service-name>:<port>.<prometheus-server-namespace>.svc \
      --set global.prometheus.enabled=false
    ```
    {% endcode %}

{% hint style="info" %}
The FQDN can be a full path via `https://prometheus-prod-us-central-x.grafana.net/api/prom/` if you use Grafana Cloud-managed Prometheus. Learn more in the [Grafana Cloud Integration for Kubecost](grafana-cloud-integration.md) doc.
{% endhint %}

2. Have your Prometheus scrape the cost-model `/metrics` endpoint. These metrics are needed for reporting accurate pricing data. Here is an example scrape config:

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

This config needs to be added to `extraScrapeConfigs` in the Prometheus configuration. See the example [extraScrapeConfigs.yaml](images/extraScrapeConfigs.yaml).

3. By default, the Prometheus chart included with Kubecost (bundled-Prometheus) contains scrape configs optimized for Kubecost-required metrics. You need to add those scrape configs jobs into your existing Prometheus setup to allow Kubecost to provide more accurate cost data and optimize the required resources for your existing Prometheus.

You can find the full scrape configs of our bundled-Prometheus [here](https://github.com/kubecost/cost-analyzer-helm-chart/blob/7c0a385b878829510eafaeff4ddf534196985040/cost-analyzer/charts/prometheus/values.yaml#L1160-L1416). You can check [Prometheus documentation](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape\_config) for more information about the scrape config, or read this [documentation](https://github.com/prometheus-operator/prometheus-operator/blob/main/Documentation/additional-scrape-config.md) if you are using Prometheus Operator.

### Recording rules

{% hint style="info" %}
This step is optional. If you do not set up Kubecost's CPU usage recording rule, Kubecost will fall back to a [PromQL subquery](https://prometheus.io/blog/2019/01/28/subquery-support/) which may put unnecessary load on your Prometheus.
{% endhint %}

Kubecost-bundled Prometheus includes a recording rule used to calculate CPU usage max, a critical component of the request right-sizing recommendation functionality. Add the recording rules to reduce query load [here](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.102/kubecost.yaml#L399).

Alternatively, if your environment supports `serviceMonitors` and `prometheusRules`, pass these values to your Helm install:

```yaml
global:
  prometheus:
    enabled: false
serviceMonitor:
  enabled: true
  # additionalLabels:
  #   label-key: label-value
  networkCosts:
    enabled: true
    # additionalLabels:
    #   label-key: label-value
prometheusRule:
  enabled: true
  # additionalLabels:
  #   label-key: label-value
```

To confirm this job is successfully scraped by Prometheus, you can view the Targets page in Prometheus and look for a job named `kubecost`.

![Prometheus Targets](images/prom-targets.png)

### Node exporter metric labels

{% hint style="info" %}
This step is optional, and only impacts certain efficiency metrics. View [issue/556](https://github.com/kubecost/cost-model/issues/556) for a description of what will be missing if this step is skipped.
{% endhint %}

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

This does not override the source label. It creates a new label called `kubernetes_node` and copies the value of pod into it.

### Distinguishing clusters

In order to distinguish between multiple clusters, Kubecost needs to know the label used in prometheus to identify the name. Use the `.Values.kubecostModel.promClusterIDLabel`. The default cluster label is `cluster_id`, though many environments use the key of `cluster`.

### Data retention

By default, metric retention is 91 days, however the retention of data can be further increased with a configurable value for a property `etlDailyStoreDurationDays`. You can find this value [here](https://github.com/kubecost/cost-analyzer-helm-chart/blob/9f3d7974247bfd3910fbf69d0d4bd66f1335201a/cost-analyzer/values.yaml#L340).

{% hint style="warning" %}
Increasing the default `etlDailyStorageDurationDays` value will naturally result in greater memory usage. At higher values, this can cause errors when trying to display this information in the Kubecost UI. You can remedy this by increasing the [Step size](https://docs.kubecost.com/troubleshooting/diagnostics) when using the Allocations dashboard.
{% endhint %}

## Troubleshooting

The Diagnostics page (_Settings > View Full Diagnostics_) provides diagnostic info on your integration. Scroll down to Prometheus Status to verify that your configuration is successful.

![Prometheus status diagnostic](images/prom-status.png)

Below you can find solutions to common Prometheus configuration problems. View the [Kubecost Diagnostics](https://docs.kubecost.com/troubleshooting/diagnostics) doc for more information.

### Misconfigured Prometheus FQDN

Evidenced by the following pod error message `No valid prometheus config file at ...` and the init pods hanging. We recommend running `curl <your_prometheus_url>/api/v1/status/config` from a pod in the cluster to confirm that your [Prometheus config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#configuration-file) is returned. Here is an example, but this needs to be updated based on your pod name and Prometheus address:

```
kubectl exec -i -t --namespace kubecost \
  deployment/kubecost-cost-analyzer -c cost-analyzer-frontend -- \
  curl http://<your_prometheus_url>/api/v1/status/config
```

{% hint style="info" %}
In the above example, \<your\_prometheus\_url> may include a port number and/or namespace, example: `http://prometheus-operator-kube-p-prometheus.monitoring:9090/api/v1/status/config`
{% endhint %}

If the config file is not returned, this is an indication that an incorrect Prometheus address has been provided. If a config file is returned from one pod in the cluster but not the Kubecost pod, then the Kubecost pod likely has its access restricted by a network policy, service mesh, etc.

### Context deadline exceeded

Network policies, Mesh networks, or other security related tooling can block network traffic between Prometheus and Kubecost which will result in the Kubecost scrape target state as being down in the Prometheus targets UI. To assist in troubleshooting this type of error you can use the `curl` command from within the cost-analyzer container to try and reach the Prometheus target. Note the "namespace" and "deployment" name in this command may need updated to match your environment, this example uses the default Kubecost Prometheus deployment.

When successful, this command should return all of the metrics that Kubecost uses. Failures may be indicative of the network traffic being blocked.

```
kubectl exec -i -t --namespace kubecost \
  deployment/kubecost-cost-analyzer -c cost-analyzer-frontend -- \
  curl "http://<your_prometheus_url>/metrics"
```

### Prometheus throttling

Ensure Prometheus isn't being CPU throttled due to a low resource request.

### Wrong dependency version

Review the Dependency Requirements section above

### Missing scrape configs

Visit Prometheus Targets page (screenshot above)

### Data incorrectly is a single namespace

Make sure that [honor\_labels](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape\_config) is enabled

### Negative idle reported

#### Single cluster tests

Ensure results are not null for both queries below.

1. Make sure Prometheus is scraping Kubecost search metrics for: `node_total_hourly_cost`

```
kubectl exec -i -t --namespace kubecost \
  deployment/kubecost-cost-analyzer -c cost-analyzer-frontend -- \
  curl "http://localhost:9003/prometheusQuery?query=node_total_hourly_cost"
```

2. Ensure kube-state-metrics are available: `kube_node_status_capacity`

```
kubectl exec -i -t --namespace kubecost \
  deployment/kubecost-cost-analyzer -c cost-analyzer-frontend -- \
  curl "http://localhost:9003/prometheusQuery?query=kube_node_status_capacity"
```

For both queries, verify nodes are returned. A successful response should look like:

{% code overflow="wrap" %}
```json
{"status":"success","data":{"resultType":"vector","result":[{"metric":{"__name__":"node_total_hourly_cost","instance":"aks-agentpool-81479558-vmss000001","instance_type":"Standard_B4ms","job":"kubecost","node":"aks-agentpool-81479558-vmss000001","provider_id":"azure:///.../virtualMachines/1","region":"eastus"},"value":[1673020150,"0.16599565032196045"]}]}}
```
{% endcode %}

An error will look like:

```json
{"status":"success","data":{"resultType":"vector","result":[]}}
```

#### Enterprise multi-cluster test

Ensure that all clusters and nodes have values- output should be similar to the above Single Cluster Tests

1. Make sure Prometheus is scraping Kubecost search metrics for: `node_total_hourly_cost`

{% code overflow="wrap" %}
```
kubectl exec -i -t --namespace kubecost \
  deployment/kubecost-cost-analyzer -c cost-analyzer-frontend -- \
  curl -G http://localhost:9003/thanosQuery \
  -d time=`date -d '1 day ago' "+%Y-%m-%dT%H:%M:%SZ"` \
  --data-urlencode "query=avg (sum_over_time(node_total_hourly_cost[1d])) by (cluster_id, node)" \
  | jq
```
{% endcode %}

{% hint style="info" %}
On macOS, change `date -d '1 day ago'` to `date -v '-1d'`
{% endhint %}

2. Ensure kube-state-metrics are available: `kube_node_status_capacity`

{% code overflow="wrap" %}
```
kubectl exec -i -t --namespace kubecost \
  deployment/kubecost-cost-analyzer -c cost-analyzer-frontend -- \
  curl -G http://localhost:9003/thanosQuery \
  -d time=`date -d '1 day ago' "+%Y-%m-%dT%H:%M:%SZ"` \
  --data-urlencode "query=avg (sum_over_time(kube_node_status_capacity[1d])) by (cluster_id, node)" \
  | jq
```
{% endcode %}

For both queries, verify nodes are returned. A successful response should look like:

{% code overflow="wrap" %}
```json
{"status":"success","data":{"resultType":"vector","result":[{"metric":{"__name__":"node_total_hourly_cost","instance":"aks-agentpool-81479558-vmss000001","instance_type":"Standard_B4ms","job":"kubecost","node":"aks-agentpool-81479558-vmss000001","provider_id":"azure:///.../virtualMachines/1","region":"eastus"},"value":[1673020150,"0.16599565032196045"]}]}}
```
{% endcode %}

An error will look like:

```json
{"status":"success","data":{"resultType":"vector","result":[]}}
```
