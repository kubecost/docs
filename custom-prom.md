Custom Prometheus
=================

When integrating Kubecost with an existing Prometheus, we recommend first installing Kubecost with a bundled Prometheus ([instructions](http://kubecost.com/install)) as a dry run before integrating with an external Prometheus deployment. You can get in touch (support@kubecost.com) or via our [Slack community](https://join.slack.com/t/kubecost/shared_invite/enQtNTA2MjQ1NDUyODE5LWFjYzIzNWE4MDkzMmUyZGU4NjkwMzMyMjIyM2E0NGNmYjExZjBiNjk1YzY5ZDI0ZTNhZDg4NjlkMGRkYzFlZTU) for assistance.

**Note:** integrating with an existing Prometheus is only officially supported under Kubecost paid plans.

<a name="dep-versions"></a>

### Dependency Requirements

Kubecost requires the following minimum versions:

- kube-state-metrics - v1.6.0+ (May 19)
- cAdvisor - kubelet v1.11.0+ (May 18)
- node-exporter - v0.16+ (May 18) [Optional]

### Implementation Steps

1. Pass the following parameters in your helm [values file](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml):

   * `prometheus.fqdn` to match your local Prometheus service address with this format ` http://<prometheus-server-service-name>.<prometheus-server-namespace>.svc`
   * `prometheus.enabled` set to `false`

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

This config needs to be added under `extraScrapeConfigs` in the Prometheus configuration. [View Example](https://github.com/kubecost/cost-analyzer-helm-chart/blob/0758d5df54d8963390ca506ad6e58c597b666ef8/cost-analyzer/values.yaml#L74)

To confirm this job is successfully scraped by Prometheus, you can view the Targets page in Prometheus and look for a job named `kubecost`.

![Prometheus Targets](https://raw.githubusercontent.com/kubecost/docs/main/prom-targets.png)

<a name="recording-rules"></a>

### Recording Rules

NOTE: There is no need to add additional recording rules starting in v1.90.0. This section will be removed soon!

Kubecost uses [Prometheus recording rules](https://prometheus.io/docs/prometheus/latest/configuration/recording_rules/) to enable certain product features and to help improve product performance. These are recommended additions, especially for medium and large-sized clusters using their own Prometheus installation. You can find the current set of recording rules used in the `rules` block under `prometheus.server.serverFiles` in this [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) file.

> Note: Kubecost recording rules were most recently updated in v1.65.0.

### Node exporter metric labels

> Note that this step is optional, and only impacts certain efficiency metrics. View [issue/556](https://github.com/kubecost/cost-model/issues/556) for a description of what will be missing if this step is skipped.

You'll need to add the following relabel config to the job that scrapes the node exporter DaemonSet.

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

* Wrong Prometheus FQDN: evidenced by the following pod error message `No valid prometheus config file at ...` and the init pods hanging. We recommend running `curl <your_prometheus_url>/api/v1/status/config` from a pod in the cluster to confirm that your [Prometheus config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#configuration-file) is returned. Here is an example, but this needs to be updated based on your Prometheus address:

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

![Prometheus status diagnostic](https://raw.githubusercontent.com/kubecost/docs/main/prom-status.png)

<a name="existing-grafana"></a>

# Custom Grafana

Using an existing Grafana deployment can be accomplished with either of the following two options:

1. _Option: Directly link to an external Grafana._ After Kubecost installation, visit Settings and update **Grafana Address** to a URL (e.g. http://demo.kubecost.com/grafana) that is visible to users accessing Grafana dashboards. This variable can alternatively be passed at the time you deploy Kubecost via the `kubecostProductConfigs.grafanaURL` parameter in [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml). Next, import Kubecost Grafana dashboards as JSON from this [folder](https://github.com/kubecost/cost-analyzer-helm-chart/tree/master/cost-analyzer).

![Kubecost Settings](https://raw.githubusercontent.com/kubecost/docs/main/images/settings-grafana.png)

2. _Option: Deploy with Grafana sidecar enabled._ Passing the Grafana parameters below in your [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) will install ConfigMaps for Grafana dashboards that will be picked up by the [Grafana sidecar](https://github.com/helm/charts/tree/master/stable/grafana#sidecar-for-dashboards) if you have Grafana with the dashboard sidecar already installed.

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

For Option 2, ensure that the following flags are set in your Operator deployment:

1. sidecar.dashboards.enabled = true
2. sidecar.dashboards.searchNamespace isn't restrictive, use `ALL` if Kubecost runs in another namespace.

Note that with Option 2, the Kubecost UI cannot link to the Grafana dashboards unless `kubecostProductConfigs.grafanaURL` is set, either via the Helm chart, or via the Settings page as described in Option 1.

Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/custom-prom.md)

<!--- {"article":"4407595941015","section":"4402815636375","permissiongroup":"1500001277122"} --->
