# Custom Prometheus

Integrating Kubecost with an existing Prometheus installation can be nuanced. We recommend getting in touch (team@kubecost.com) for assistance.   

__Required Steps__

1. Copy and edit [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml). Update the `promtheus.fqdn` variable to match your local Prometheus service address and set the `prometheus.enabled` flag to false
2. Scrape cost-model `/metrics` endpoint
3. Deploy kubecost recording rules 

__Troubleshooting__

* Wrong FQDN
* Prometheus Throttling
* Version dependancies (node-exporter / ksm)
* Missing scrape configs
* Recording rules are inaccurate
