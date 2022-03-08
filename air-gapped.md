Installing in Air-gapped Environments
=====================================

FAQ for installing in Kubecost in an air-gapped environment

### Q: I have to put container images into a private registry to use them in my cluster. What images do I need?

**A:** The following images will need to be downloaded. Please substitute the appropriate version
for prod-x.xx.x. [Latest releases can be found here](https://github.com/kubecost/cost-analyzer-helm-chart/releases).

### Kubecost Required*
- Frontend: gcr.io/kubecost1/frontend:prod-x.xx.x
- Server: gcr.io/kubecost1/server:prod-x.xx.x
- CostModel: gcr.io/kubecost1/cost-model:prod-x.xx.x

### Kubecost Optional
- Kube-state-metrics: quay.io/coreos/kube-state-metrics:v1.9.8
- NetworkCosts: gcr.io/kubecost1/kubecost-network-costs:v16.0 (used for [network-allocation](https://github.com/kubecost/docs/blob/main/network-allocation.md))
- BusyBox: registry.hub.docker.com/library/busybox:latest (only for NFS)
- Cluster controller: gcr.io/kubecost1/cluster-controller:v0.0.2 (used for write actions)

### Prometheus - Required when bundled
- prom/prometheus:v2.21.1
- prom/node-exporter:v0.18.1
- prom/alertmanager:v0.23.0
- grafana/grafana:8.3.2
- jimmidyson/configmap-reload:v0.7.1
- kiwigrid/k8s-sidecar:1.15.4 (can be optional if not using Grafana sidecar)

### Thanos - Enterprise/Durable Storage*
- thanosio/thanos:v0.24.0

### Q: How do I configure prices for my on-premise Assets?

There are two options to configure asset prices in your on-premise Kubernetes environment:

- *Simple pipeline:* per component prices can be configured in a helm values file ([reference](https://github.com/kubecost/cost-analyzer-helm-chart/blob/6c0975614b4a6854be602d1a6f9506ce8b80abdc/cost-analyzer/values.yaml#L559-L570)) or directly in the Kubecost Settings page. This allows you to directly supply the cost of a CPU month, RAM Gb month, etc.
- *Advanced pipeline:* this method allows each individual asset in your environment to have a unique price. This leverages the Kubecost custom CSV pipeline which is available on Enterprise plans. Contact us at team@kubecost.com to learn more.

Edit this doc on [Github](https://github.com/kubecost/docs/blob/main/air-gapped.md)

<!--- {"article":"4407601795863","section":"4402815636375","permissiongroup":"1500001277122"} --->

