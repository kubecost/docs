# Custom Prometheus

Integrating Kubecost with an existing Prometheus installation can be nuanced. We recommend getting in touch (team@kubecost.com) for assistance. We also recommend first installing Kubecost with a bundled Prometheus ([instructions](http://kubecost.com/install)) as a dry run before integration with your own Prometheus.  

__Required Steps__

1. During the helm install process, copy and edit [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml). Then update the `promtheus.fqdn` variable to match your local Prometheus service address and set the `prometheus.enabled` flag to `false`.
2. Scrape cost-model `/metrics` endpoint -- needed for accurate historical pricing data. Details [here](https://github.com/kubecost/cost-model/blob/master/PROMETHEUS.md#configuration).
3. Deploy kubecost [recording rules](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml#L56) -- optional but recommended for medium and larger clusters

__Troubleshooting__

Common issues include the following: 

* Wrong FQDN -- run `curl <url>/api/v1/status/config` from a pod in the cluster and confirm that the prometheus config is returned
* Prometheus throttling -- ensure Prometheus isn't being CPU throttled due to a low resource request.
* Dependancy versions (node-exporter - v0.16, kube-state-metrics - v1.3, cadvisor)
* Missing scrape configs
* Recording rules are inaccurate

You can visit Settings in Kubecost to see basic diagnostic information on missing/available metrics:

![Prometheus status diagnostic](/prom-status.png)
