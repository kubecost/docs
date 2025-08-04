# Installing in Air-gapped Environments

This article is the primary reference for installing Kubecost in an air-gapped environment with a user-managed container registry.

## Kubecost images

This section details all required and optional Kubecost images. Optional images are used depending on the specific configuration needed.

Please substitute the appropriate version for prod-x.xx.x. [Latest releases can be found here](https://github.com/kubecost/cost-analyzer-helm-chart/releases).

To find the exact images used for each Kubecost release, a command such as this can be used:

```bash
helm template kubecost --repo https://kubecost.github.io/cost-analyzer cost-analyzer \
  --namespace kubecost \
  --set networkCosts.enabled=true \
  --set clusterController.enabled=true \
  |grep image:
```

{% hint style="info" %}
The alpine/k8s image is not used in real deployments. It is only in the Helm chart for testing purposes.
{% endhint %}

### Kubecost: Required

* Frontend: gcr.io/kubecost1/frontend
* CostModel: gcr.io/kubecost1/cost-model

### Kubecost: Optional

* NetworkCosts: gcr.io/kubecost1/kubecost-network-costs (used for [network-allocation](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/network-allocation.md))
* Cluster controller: gcr.io/kubecost1/cluster-controller:v0.9.0 (used for write actions)
* BusyBox: registry.hub.docker.com/library/busybox:latest (only for NFS)

### Prometheus: Required when bundled

* quay.io/prometheus/prometheus
* prom/node-exporter
* quay.io/prometheus-operator/prometheus-config-reloader

### Grafana: Optional

* grafana/grafana
* kiwigrid/k8s-sidecar

## Thanos: Optional

* thanosio/thanos

## FAQ and troubleshooting

### How do I configure prices for my on-premise assets?

There are two options to configure asset prices in your on-premise Kubernetes environment:

#### Simple pipeline

Per-resource prices can be configured in a Helm values file ([reference](https://github.com/kubecost/cost-analyzer-helm-chart/blob/6c0975614b4a6854be602d1a6f9506ce8b80abdc/cost-analyzer/values.yaml#L559-L570)) or directly in the Kubecost Settings page. This allows you to directly supply the cost of a certain Kubernetes resources, such as a CPU month, a RAM Gb month, etc.

{% hint style="info" %}
Use quotes if setting "0.00" for any item under [`kubecostProductConfigs.defaultModelPricing`](https://github.com/kubecost/cost-analyzer-helm-chart/blob/6c0975614b4a6854be602d1a6f9506ce8b80abdc/cost-analyzer/values.yaml#L559-L570). Failure to do so will result in the value(s) not being written to the Kubecost cost-model's PV (/var/configs/default.json).
{% endhint %}

{% hint style="info" %}
When setting CPU and RAM monthly prices, the values will be broken down to the hourly rate for the total monthly price set under kubecost.ProductConfigs.defaultModelPricing. The values will adjust accordingly in /var/configs/default.json in the kubecost cost-model container.
{% endhint %}

#### Advanced pipeline

This method allows each individual asset in your environment to have a unique price. This leverages the Kubecost custom CSV pipeline which is available on Enterprise plans.

### I use AWS and want the public pricing but can't allow Kubecost to ingress/egress data

Use a proxy for the AWS pricing API. You can set `AWS_PRICING_URL` via the [`extra env var`](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.98/cost-analyzer/values.yaml#L304) to the address of your proxy.
