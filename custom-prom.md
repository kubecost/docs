# Custom Prometheus

Integrating Kubecost with an existing Prometheus installation can be nuanced. We recommend first installing Kubecost with a bundled Prometheus ([instructions](http://kubecost.com/install)) as a dry run before integrating with an external Prometheus deployment. We also recommend getting in touch (team@kubecost.com) for assistance.

**Note:** integrating with an existing Prometheus is only supported under Kubecost paid plans.

<a name="dep-versions"></a>
__Requirements__

Kubecost requires the following dependency versions:

  - node-exporter - v0.16 (May 18)
  - kube-state-metrics - v1.6.0 (May 19)
  - cAdvisor - kubelet v1.11.0  (May 18)

__Implementation Steps__

1. Copy [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) and update the following parameters:  

   - `prometheus.fqdn` to match your local Prometheus with this format `  http://<prometheus-server-service-name>.<prometheus-server-namespace>.svc.cluster.local`
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
__Recording Rules__  
<br/>
Kubecost uses [Prometheus recording rules](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/) to enable certain product features and to help improve product performance. These are recommended additions, especially for medium and large-sized clusters using their own Prometheus installation. You can find our recording rules under _rules_ in this [values.yaml file](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml#L169).

<a name="troubleshoot"></a>
## Troubleshooting Issues

Common issues include the following:

* Wrong Prometheus FQDN: evidenced by the following pod error message `No valid prometheus config file at  ...`. We recommend running `curl <your_prometheus_url>/api/v1/status/config` from a pod in the cluster to confirm that your [Prometheus config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#configuration-file) is returned. If not, this is an indication that an incorrect Prometheus Url has been provided. If a config file is returned, then the Kubecost pod likely has its access restricted by a cluster policy, service mesh, etc.

* Prometheus throttling -- ensure Prometheus isn't being CPU throttled due to a low resource request.

* Wrong dependency version -- see the section above about Requirements

* Missing scrape configs -- visit Prometheus Target page (screenshot above)

* On recent versions of the **Prometheus Operator**, cadvisor `instance` labels do not match internal Kubernetes node names. The solution is to add the following block into your kubelet/cadvisor scrape config.

```
  metric_relabel_configs:
  - source_labels: [node]
    separator: ;
    regex: (.*)
    target_label: instance
    replacement: $1
    action: replace
```

* Data incorrectly is a single namespace -- make sure that [honor_labels](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config) is enabled


You can visit Settings in Kubecost to see basic diagnostic information on these Prometheus metrics:

![Prometheus status diagnostic](/prom-status.png)


<a name="existing-grafana"></a>
# Custom Grafana

Using an existing Grafana deployment can be accomplished with either of the following two options:

1) _Option: Configure in Kubecost product._ After the default Kubecost installation, visit Settings and update __Grafana Address__ to a URL (e.g. http://demo.kubecost.com/grafana) that is visible to users accessing Grafana dashboards. Next, import Kubecost Grafana dashboards as JSON from this [folder](https://github.com/kubecost/cost-analyzer-helm-chart/tree/master/cost-analyzer).

![Kubecost Settings](/images/settings-grafana.png)

2) _Option: Deploy with Grafana sidecar enabled._ Passing the Grafana parameters below in your [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) will install ConfigMaps for Grafana dashboards that will be picked up by the [Grafana sidecar](https://github.com/helm/charts/tree/master/stable/grafana#sidecar-for-dashboards) if you have Grafana with the dashboard sidecar already installed.

```
global:
  grafana:
    enabled: false
    domainName: cost-analyzer-grafana.default #example where format is <service-name>.<namespace>
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
