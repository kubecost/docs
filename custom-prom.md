# Custom Prometheus

Integrating Kubecost with an existing Prometheus installation can be nuanced. We recommend getting in touch (team@kubecost.com) for assistance. We also recommend first installing Kubecost with a bundled Prometheus ([instructions](http://kubecost.com/install)) as a dry run before integration with your own Prometheus.  

__Required Steps__

1. During the helm install process, copy [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml). Then update the `promtheus.fqdn` variable to match your local Prometheus service address and set the `prometheus.enabled` flag to `false`.
2. <a name="scrape-configs"></a>Have your Prometheus scrape the cost-model `/metrics` endpoint. These metrics are needed for accurate historical pricing data. Here is an example scrape config:

```
- job_name: kubecost
      honor_labels: true
      scrape_interval: 1m
      scrape_timeout: 10s
      metrics_path: /metrics
      scheme: http
      dns_sd_configs:
      - names:
        - kubecost-cost-analyzer.<namespace kubecost runs in>
        type: 'A'
        port: 9003
```  

<a name="recording-rules"></a>__Recording Rules__  
Kubecost uses Prometheus [recording rules](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml#L62) to help improve product performance. These are optional but recommended additions for medium and large-sized clusters using their own Prometheus installation.

<a name="troubleshoot"></a>__Troubleshooting__

Common issues include the following: 

* Wrong Prometheus FQDN: evidenced by the following pod error message `No valid prometheus config file at  ...`. We recommend running `curl <your_prometheus_url>/api/v1/status/config` from a pod in the cluster to confirm that your [Prometheus config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#configuration-file) is returned. If not, this is an indication that an incorrect Prometheus Url has been provided. If a config file is returned, then the Kubecost pod likely has it's access restricted by a cluster policy, service mesh, etc. 

* Prometheus throttling -- ensure Prometheus isn't being CPU throttled due to a low resource request.

* Dependancy versions (node-exporter - v0.16, kube-state-metrics - v1.3, cadvisor)

* Missing scrape configs

* Recording rules are inaccurate

You can visit Settings in Kubecost to see basic diagnostic information on missing/available metrics:

![Prometheus status diagnostic](/prom-status.png)
