Prometheus Configuration Guide
==============================

## Bring your own Prometheus

When integrating Kubecost with an existing Prometheus, we recommend first installing Kubecost with a bundled Prometheus ([instructions](http://kubecost.com/install)) as a dry run before integrating with an external Prometheus deployment. You can get in touch (support@kubecost.com) or via our [Slack community](https://join.slack.com/t/kubecost/shared_invite/enQtNTA2MjQ1NDUyODE5LWFjYzIzNWE4MDkzMmUyZGU4NjkwMzMyMjIyM2E0NGNmYjExZjBiNjk1YzY5ZDI0ZTNhZDg4NjlkMGRkYzFlZTU) for assistance.

The Kubecost Prometheus deployment is used both as a source and store of metrics. It’s optimized to not interfere with other observability instrumentation and by default only contains metrics that are useful to the Kubecost product. This results in __70-90% fewer metrics__ than a Prometheus deployment using default settings.

For the best experience, we generally recommend teams use the bundled prometheus-server & grafana but reuse their existing kube-state-metrics and node-exporter deployments if they already exist. This setup allows for the easiest installation process, easiest ongoing maintenance, minimal duplication of metrics, and more flexible metric retention.

> Note: the Kubecost team provides best efforts support for free/community users when integrating with an existing Prometheus deployment.


## Dependency Requirements

Kubecost requires the following minimum versions:

- kube-state-metrics - v1.6.0+ (May 19)
- cAdvisor - kubelet v1.11.0+ (May 18)
- node-exporter - v0.16+ (May 18) [Optional]

## Implementation Steps

1. Pass the following parameters in your helm [values file](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml):

   * `global.prometheus.fqdn` to match your local Prometheus service address with this format ` http://<prometheus-server-service-name>.<prometheus-server-namespace>.svc`
   * `global.prometheus.enabled` set to `false`

    Pass this updated file to the Kubecost helm install command with `--values values.yaml`

    Or add `--set global.prometheus.fqdn=http://<prometheus-server-service-name>.<prometheus-server-namespace>.svc --set global.prometheus.enabled=false` the end of your helm install command

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

> Note that this step is optional, and only impacts certain efficiency metrics. View [issue/556](https://github.com/kubecost/cost-model/issues/556) for a description of what will be missing if this step is skipped.

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

Note that this does not override the source label-- it creates a new label called "kubernetes_node" and copies the value of pod into it.

## Troubleshooting Issues

Visiting `<your-kubecost-endpoint>/diagnostics.html` provides diagnostics info on this integration. [More details](/diagnostics.md)

Common issues include the following:

* Wrong Prometheus FQDN: evidenced by the following pod error message `No valid prometheus config file at ...` and the init pods hanging. We recommend running `curl <your_prometheus_url>/api/v1/status/config` from a pod in the cluster to confirm that your [Prometheus config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#configuration-file) is returned. Here is an example, but this needs to be updated based on your Prometheus address:
* If you are still not able to curl to above fqdn, Try giving the port number where prometheus service is running, `curl <your_prometheus_url:port_numer>/api/v1/status/config`

```sh
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

---
Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/custom-prom.md)

<!--- {"article":"4407595941015","section":"4402815636375","permissiongroup":"1500001277122"} --->
