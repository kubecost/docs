Grafana Configuration Guide
===========================
Using an existing Grafana deployment can be accomplished with either of the following two options:

## Option 1: Directly link to an external Grafana.
After Kubecost installation, visit Settings and update __Grafana Address__ to a URL (e.g. http://demo.kubecost.com/grafana) that is visible to users accessing Grafana dashboards. This variable can alternatively be passed at the time you deploy Kubecost via the `kubecostProductConfigs.grafanaURL` parameter in [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml). Next, import Kubecost Grafana dashboards as JSON from this [folder](https://github.com/kubecost/cost-analyzer-helm-chart/tree/master/cost-analyzer).

![Kubecost Settings](https://raw.githubusercontent.com/kubecost/docs/main/images/settings-grafana.png)

## Option 2: Deploy with Grafana sidecar enabled.
Passing the Grafana parameters below in your [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) will install ConfigMaps for Grafana dashboards that will be picked up by the [Grafana sidecar](https://github.com/helm/charts/tree/master/stable/grafana#sidecar-for-dashboards) if you have Grafana with the dashboard sidecar already installed.

```
global:
  grafana:
    enabled: false
    domainName: cost-analyzer-grafana.default #example where format is <service-name>.<namespace>
    proxy: false
grafana:
  sidecar:
    dashboards:
      enabled: true
    datasources:
      enabled: false
```

For Option 2, ensure that the following flags are set in your Operator deployment:

1. sidecar.dashboards.enabled = true
2. sidecar.dashboards.searchNamespace isn't restrictive, use `ALL` if Kubecost runs in another namespace.

Note that with Option 2, the Kubecost UI cannot link to the Grafana dashboards unless `kubecostProductConfigs.grafanaURL` is set, either via the Helm chart, or via the Settings page as described in Option 1.


Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/custom-grafana.md)

<!--- {"article":"6737508001687","section":"1500002777682","permissiongroup":"1500001277122"} --->
