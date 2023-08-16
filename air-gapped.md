# Installing in Air-gapped Environments

This doc is the primary reference for installing Kubecost in an air-gapped environment.

### I have to put container images into a private registry to use them in my cluster. What images do I need?

The following images will need to be downloaded. Please substitute the appropriate version for prod-x.xx.x. [Latest releases can be found here](https://github.com/kubecost/cost-analyzer-helm-chart/releases).

#### Kubecost: Required

* Frontend: gcr.io/kubecost1/frontend:prod-x.xx.x
* CostModel: gcr.io/kubecost1/cost-model:prod-x.xx.x

#### Kubecost: Optional


* NetworkCosts: gcr.io/kubecost1/kubecost-network-costs:v16.6 (used for [network-allocation](network-allocation.md))
* BusyBox: registry.hub.docker.com/library/busybox:latest (only for NFS)
* Cluster controller: gcr.io/kubecost1/cluster-controller:v0.9.0 (used for write actions)
* Grafana Dashboards: grafana/grafana:9.4.7

#### Prometheus: Required when bundled

* prom/prometheus:v2.35.0
* prom/node-exporter:v1.5.0
* jimmidyson/configmap-reload:v0.7.1
* kiwigrid/k8s-sidecar:1.23.1 (optional if not using Grafana sidecar)

### Thanos - Enterprise/Durable Storage\*

* thanosio/thanos:v0.29.0

### How do I configure prices for my on-premise Assets?

There are two options to configure asset prices in your on-premise Kubernetes environment:

* _Simple pipeline:_ per resource prices can be configured in a Helm values file ([reference](https://github.com/kubecost/cost-analyzer-helm-chart/blob/6c0975614b4a6854be602d1a6f9506ce8b80abdc/cost-analyzer/values.yaml#L559-L570)) or directly in the Kubecost Settings page. This allows you to directly supply the cost of a CPU month, RAM Gb month, etc.
{% hint style="info" %}
Use quotes if setting "0.00" for any item under [`kubecostProductConfigs.defaultModelPricing`](https://github.com/kubecost/cost-analyzer-helm-chart/blob/6c0975614b4a6854be602d1a6f9506ce8b80abdc/cost-analyzer/values.yaml#L559-L570). Failure to do so will result in the value(s) not being written to the Kubecost cost-model's PV (/var/configs/default.json).
{% endhint %}
{% hint style="info" %}
When setting CPU and RAM monthly prices, the values will be broken down to the hourly rate for the total monthly price set under kubecost.ProductConfigs.defaultModelPricing. The values will adjust accordingly in /var/configs/default.json in the kubecost cost-model container.
{% endhint %}
* _Advanced pipeline:_ this method allows each individual asset in your environment to have a unique price. This leverages the Kubecost custom CSV pipeline which is available on Enterprise plans.

### I use AWS and want the public pricing but can't allow Kubecost to ingress/egress data

* Use a proxy for the AWS pricing API. You can set `AWS_PRICING_URL` via the [`extra env var`](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.98/cost-analyzer/values.yaml#L304) to the address of your proxy.
