## Installing in Air-gapped Environments

FAQ for installing in Kubecost in air-gapped environment

### Q: I have to put container images in to a private registry to use them in my cluster. What images do I need?

**A:** The following images will need to be downloaded. Please substitute the appropriate version
for prod-x.xx.x. [Latest releases can be found here](https://github.com/kubecost/cost-analyzer-helm-chart/releases).

*Kubecost Required*
* FrontEnd: gcr.io/kubecost1/frontend:prod-x.xx.x
* Server: gcr.io/kubecost1/server:prod-x.xx.x
* CostModel: gcr.io/kubecost1/cost-model:prod-x.xx.x

*Kubecost Optional*
* Kube-state-metrics: quay.io/coreos/kube-state-metrics:v1.9.5
* NetworkCosts: gcr.io/kubecost1/kubecost-network-costs:v14.1 (used for [network-allocation](https://github.com/kubecost/docs/blob/master/network-allocation.md))
* BusyBox: registry.hub.docker.com/library/busybox:latest (only for NFS)
* Cluster controller: gcr.io/kubecost1/cluster-controller:v0.0.2 (used for write actions)
* SQL Init: gcr.io/kubecost1/sql-init:prod-x.xx.x (for limited Enterprise Postgres deployments)

*Prometheus - Required when bundled*
* prom/prometheus:v2.17.2
* prom/node-exporter:v0.18.1
* prom/alertmanager:v0.20.0
* grafana/grafana:7.5.4
* jimmidyson/configmap-reload:v0.3.0
* kiwigrid/k8s-sidecar:1.11.1 (can be optional if not using Grafana sidecar)

*Thanos - Enterprise/Durable Storage*
* thanosio/thanos:v0.19.0


### Q: How do I configure prices for my on-premise Assets?

There are two options to configure asset prices in your on-premise Kubernetes environment:

* *Simple pipeline:* per component prices can be configured in a helm values file ([reference](https://github.com/kubecost/cost-analyzer-helm-chart/blob/6c0975614b4a6854be602d1a6f9506ce8b80abdc/cost-analyzer/values.yaml#L559-L570)) or directly in the Kubecost Settings page. This allows your to directly supply the cost of a CPU month, RAM Gb month, etc.
* *Advanced pipeline:* this method allows each individual asset in your environment to have a unique price. This leverages the Kubecost custom CSV pipeline which is available on business and enterprise plans. Contact us team@kubecost.com to learn more.
