### Installing in Air-gapped Environments

FAQ for installing in Kubecost in air-gapped environment

**Q:** I have to put container images in to a private registry to use them in my cluster. 
What images do I need?

**A:** The following images will need to be downloaded. Please substitute the appropriate version
for prod-x.xx.x. [Latest releases can be found here](https://github.com/kubecost/cost-analyzer-helm-chart/releases).

*Kubecost Required*
* FrontEnd: gcr.io/kubecost1/frontend:prod-x.xx.x
* Server: gcr.io/kubecost1/server:prod-x.xx.x
* CostModel: gcr.io/kubecost1/cost-model:prod-x.xx.x

*Kubecost Optional*
* NetworkCosts: gcr.io/kubecost1/kubecost-network-costs:v15.0 (used for [network-allocation](https://github.com/kubecost/docs/blob/master/network-allocation.md))
* BusyBox: registry.hub.docker.com/library/busybox:latest (only for NFS)
* Checks: gcr.io/kubecost1/checks:prod-x.xx.x (used for recurring alerts)
* Cluster controller: gcr.io/kubecost1/cluster-controller:v0.0.2 (used for write actions)
* SQL Init: gcr.io/kubecost1/sql-init:prod-x.xx.x (for limited Enterprise Postgres deployments)

*Prometheus - Required when bundled*
* prom/prometheus:v2.17.2
* prom/node-exporter:v0.18.1
* prom/alertmanager:v0.20.0
* grafana/grafana:7.1.1
* jimmidyson/configmap-reload:v0.3.0
* kiwigrid/k8s-sidecar:0.1.144 (can be optional if not using Grafana sidecar)

*Thanos - Enterprise/Durable Storage*
* thanosio/thanos:v0.15.0


