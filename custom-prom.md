# Custom Prometheus

Integrating Kubecost with an existing Prometheus installation can be nuanced. We recommend first installing Kubecost with a bundled Prometheus ([instructions](http://kubecost.com/install)) as a dry run before integrating with your own Prometheus. We also recommend getting in touch (team@kubecost.com) for assistance. 

**Note:** integrating with an existing Prometheus is officially supported under all Kubecost paid plans. 

__Required Steps__

1. Copy [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) and update the following parameters:
  
   `promtheus.fqdn` to match your local Prometheus with this format `http://<prometheus-server-service-name>.<prometheus-server-namespace>.svc.cluster.local`  
   `prometheus.enabled` set to `false`  
  
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
Kubecost uses Prometheus [recording rules](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml#L145) to enable certain product features and to help improve product performance. These are recommended additions, especially for medium and large-sized clusters using their own Prometheus installation.

<a name="troubleshoot"></a>__Troubleshooting Issues__

Common issues include the following: 

* Wrong Prometheus FQDN: evidenced by the following pod error message `No valid prometheus config file at  ...`. We recommend running `curl <your_prometheus_url>/api/v1/status/config` from a pod in the cluster to confirm that your [Prometheus config](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#configuration-file) is returned. If not, this is an indication that an incorrect Prometheus Url has been provided. If a config file is returned, then the Kubecost pod likely has it's access restricted by a cluster policy, service mesh, etc. 

* Prometheus throttling -- ensure Prometheus isn't being CPU throttled due to a low resource request.

* Required dependancy versions <a name="dep-versions"></a>  
  - node-exporter - v0.16   
  - kube-state-metrics - v1.6.0  
  - cadvisor - kubelet v1.11.0  

* Missing scrape configs -- visit Prometheus Target page (screenshot above)

* Data incorrectly is a single namespace -- make sure that [honor_labels](https://prometheus.io/docs/prometheus/latest/configuration/configuration/#scrape_config) is enabled 

You can visit Settings in Kubecost to see basic diagnostic information on these Prometheus metrics:

![Prometheus status diagnostic](/prom-status.png)
