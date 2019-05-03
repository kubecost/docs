# Custom Prometheus

Integrating with an existing Prometheus installation can be nuanced. We recommend getting in touch (team@kubecost.com) for assistance.   

__Required Steps__

1. Edit values.yaml
2. Scrape cost-model `/metrics` endpoint
3. Deploy kubecost recording rules 

__Troubleshooting__

* Wrong FQDN
* Prometheus Throttling
* Version dependancies (node-exporter / ksm)
* Missing scrape configs
* Recording rules are inaccurate
