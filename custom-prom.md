# Custom Prometheus



Integrating Kubecost with an existing Prometheus installation can be nuanced. We recommend first installing Kubecost with a bundled Prometheus ([instructions](http://kubecost.com/install)) as a dry run before integrating with an external Prometheus deployment. We also recommend getting in touch (team@kubecost.com) for assistance.

**Note:** integrating with an existing Prometheus is only officially supported under Kubecost paid plans.

<a name="dep-versions"></a>
### Dependency Requirements

Kubecost requires the following minimum versions:
 
  - kube-state-metrics - v1.6.0 < v2.0.0 Support for v2.0.0+ is upcoming.
  - cAdvisor - kubelet v1.11.0  (May 18)
  - node-exporter - v0.16 (May 18) [Optional Dependency]

### Implementation Steps

1. Copy [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) and update the following parameters:  

   - `prometheus.fqdn` to match your local Prometheus with this format `  http://<prometheus-server-service-name>.<prometheus-server-namespace>.svc`
   - `prometheus.enabled` set to `false`  

   Pass this updated file to the Kubecost helm install command with `--values values.yaml`

2. <a name="scrape-configs"></a>Have your Prometheus scrape the cost-model `/metrics` endpoint. These metrics are needed for reporting accurate pricing data. Here is an example scrape config:

```
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

This config needs to be added under `extraScrapeConfigs` in Prometheus configuration. [Example](https://github.com/kubecost/cost-analyzer-helm-chart/blob/0758d5df54d8963390ca506ad6e58c597b666ef8/cost-analyzer/values.yaml#L74)

You can confirm that this job is successfully running with the Targets view in Prometheus.

![Prometheus Targets](/prom-targets.png)

<a name="recording-rules"></a>
### Recording Rules  
Kubecost uses [Prometheus recording rules](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/) to enable certain product features and to help improve product performance. These are recommended additions, especially for medium and large-sized clusters using their own Prometheus installation. You can find the current set of recording rules used in the `rules` block under `prometheus.server.serverFiles` in this [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) file.

> Note: Kubecost recording rules were most recently updated in v1.65.0

### Cadvisor metric labels 
Kubecost uses `container_name` and `pod_name` labels on cadvisor metrics. For clusters running **k8s v1.16+**, the following relabel config creates the expected labels on cadvisor metrics:

```
  metric_relabel_configs:
  - source_labels: [ container ]
    target_label: container_name
    regex: (.+)
    action: replace
  - source_labels: [ pod ]
    target_label: pod_name
    regex: (.+)
    action: replace
```

Note that this does not override the source label-- it creates a new label called "pod_name" and copies the value of the pod into it.

On recent versions of **Prometheus Operator**, cadvisor `instance` labels do not match internal Kubernetes node names. This causes usage data to not be registered correctly in Kubecost. The solution is to add the following block into your kubelet/cadvisor scrape config.

```
  metric_relabel_configs:
  - source_labels: [node]
    separator: ;
    regex: (.*)
    target_label: instance
    replacement: $1
    action: replace
```

Note that this does override the instance label This is the desired behavior, as the instance label before override represents an internal ip of 10.X.X.X that is not useful for identifying the node or for aggregation.

### Node exporter metric labels

> Note that this step is optional, and only impacts certain efficiency metrics. View [issue/556](https://github.com/kubecost/cost-model/issues/556) for a description of what will be missing if this step is skipped.

You'll need to add the following relabel config to the job that scrapes the node exporter daemonet.

```
  - job_name: 'kubernetes-service-endpoints'

    kubernetes_sd_configs:
      - role: endpoints

    relabel_configs:
      - source_labels: [__meta_kubernetes_pod_node_name]
        action: replace
        target_label: kubernetes_node
```

Note that this does not override the source label-- it creates a new label called "kubernetes_node" and copies the value of pod into it.

<a name="troubleshoot"></a>
## Troubleshooting Issues

Visiting `<your-kubecost-endpoint>/diagnostics.html` provides diagnostics info on this integration. [More details](/diagnostics.md)

Common issues include the following:

* Wrong Prometheus FQDN: evidenced by the following pod error message `No valid prometheus config file at  ...` and the init pods hanging. We recommend running `curl <your_prometheus_url>/api/v1/status/config` from a pod in the cluster to confirm that your [Prometheus config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#configuration-file) is returned. Here is an example, but this needs to be updated based on your Prometheus address:

```
kubectl exec kubecost-cost-analyzer-db55d88f6-fr6kc -c cost-analyzer-frontend -n kubecost \
-- curl http://kubecost-prometheus-server.kubecost/api/v1/status/config
```

If the config file is not returned, this is an indication that an incorrect Prometheus address has been provided. If a config file is returned from one pod in the cluster but not the Kubecost pod, then the Kubecost pod likely has its access restricted by a network policy, service mesh, etc.

* Prometheus throttling -- ensure Prometheus isn't being CPU throttled due to a low resource request.

* Wrong dependency version -- see the section above about Requirements

* Missing scrape configs -- visit Prometheus Target page (screenshot above)

* Data incorrectly is a single namespace -- make sure that [honor_labels](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config) is enabled

You can visit Settings in Kubecost to see basic diagnostic information on these Prometheus metrics:

![Prometheus status diagnostic](/prom-status.png)


<a name="existing-grafana"></a>
# Custom Grafana

Using an existing Grafana deployment can be accomplished with either of the following two options:

1) _Option: Directly link to an external Grafana._ After Kubecost installation, visit Settings and update __Grafana Address__ to a URL (e.g. http://demo.kubecost.com/grafana) that is visible to users accessing Grafana dashboards. This variable can alternatively be passed at the time you deploy Kubecost via the `kubecostProductConfigs.grafanaURL` paremeter in [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml). Next, import Kubecost Grafana dashboards as JSON from this [folder](https://github.com/kubecost/cost-analyzer-helm-chart/tree/master/cost-analyzer). 

![Kubecost Settings](/images/settings-grafana.png)

2) _Option: Deploy with Grafana sidecar enabled._ Passing the Grafana parameters below in your [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) will install ConfigMaps for Grafana dashboards that will be picked up by the [Grafana sidecar](https://github.com/helm/charts/tree/master/stable/grafana#sidecar-for-dashboards) if you have Grafana with the dashboard sidecar already installed.

```
global:
  grafana:
    enabled: false
    domainName: cost-analyzer-grafana.default #example where format is <service-name>.<namespace>
    proxy: false
grafana:
  sidecar:
    dashboards:
      enabled: true
    datasources:
      enabled: false
```

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;For Option 2, ensure that the following flags are set in your Operator deployment:

&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1. sidecar.dashboards.enabled = true  
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2. sidecar.dashboards.searchNamespace isn't restrictive, use `ALL` if Kubecost runs in another ns  
