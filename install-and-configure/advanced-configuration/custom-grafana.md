# Grafana Configuration Guide

Using an existing Grafana deployment can be accomplished through one of two options:

1. Linking to an external Grafana directly
2. Deploying with Grafana sidecar enabled

## Option 1: Directly link to an external Grafana

After installing Kubecost, select _Settings_ from the left navigation and update _Grafana Address_ to a URL that is visible to users accessing Grafana dashboards. This variable can alternatively be passed at the time you deploy Kubecost via the `kubecostProductConfigs.grafanaURL` parameter in [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml). Next, import Kubecost Grafana dashboards as JSON from this [folder](https://github.com/kubecost/cost-analyzer-helm-chart/tree/master/cost-analyzer).

![Grafana Address option](/.gitbook/assets/grafanaaddress.PNG)

## Option 2: Deploy with Grafana sidecar enabled

Passing the Grafana parameters below in your [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) will install ConfigMaps for Grafana dashboards that will be picked up by the [Grafana sidecar](https://github.com/helm/charts/tree/master/stable/grafana#sidecar-for-dashboards) if you have Grafana with the dashboard sidecar already installed.

{% code overflow="wrap" %}
```yaml
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
{% endcode %}

Ensure that the following flags are set in your Operator deployment:

1. `sidecar.dashboards.enabled=true`
2. `sidecar.dashboards.searchNamespace` isn't restrictive. Use `ALL` if Kubecost runs in another namespace.

{% hint style="warning" %}
The Kubecost UI cannot link to the Grafana dashboards unless `kubecostProductConfigs.grafanaURL` is set, either via the Helm chart, or via the Settings page, as described in Option 1.
{% endhint %}

When using Kubecost on a custom ingress path, you must add this path to the Grafana `root_url`:

{% code overflow="wrap" %}
```text
--set grafana.grafana.ini.server.root_url: "%(protocol)s://%(domain)s:%(http_port)s/kubecost/grafana"
```
{% endcode %}

## Disabling Grafana

If you choose to disable Grafana, set the following Helm values to ensure successful pod startup:

```text
--set global.grafana.enabled=false
--set global.grafana.proxy=false
```
