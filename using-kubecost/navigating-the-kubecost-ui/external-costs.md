# External Costs

{% hint style="info" %}
External Costs is currently in beta.
{% endhint %}

External Costs is a monitoring dashboard for third party service costs that are not directly from cloud providers. Currently, this includes monitoring for Datadog costs. More third party services are expected to be supported in the future.

![External Costs](/images/externalcosts.png)

## Enabling External Costs

Kubecost will require the integration of a service's plugin in order to detect and display costs associated with that service.

From your Datadog account, you will need the following values:

* `datadog_site`: ex. us5.datadoghq.com
* `datadog_api_key`: ex. c508d4fd3d126abbbbdc2fe96b0f6613
* `datadog_app_key`: ex. f357b1f4efefb0870109e0d1aa0cb437b5f10ab9

See Datadog's [API and Application Keys](https://docs.datadoghq.com/account_management/api-app-keys/) for help finding your API and application key values.

At a minimum, the following values are needed:

```yaml
kubecostModel:
  plugins:
    enabled: true
    enabledPlugins:
    - datadog
  configs:
    datadog: |
      {
      "datadog_site": "us5.datadoghq.com",
      "datadog_api_key": "847081f247542151fc63b4dXXXX",
      "datadog_app_key": "6515819e6a3fb23c0dc3d6032ffc84XXXXX"
      }


Now update your Kubecost install via `helm`:

```sh
$ helm install kubecost cost-analyzer \
    --repo https://kubecost.github.io/cost-analyzer/ \
    --namespace kubecost --create-namespace \
    --values values-kubecost.yaml
```

The external costs UI should populate within 25 minutes. You can also confirm the configuration by viewing pod logs to show Datadog queries going through.

## Configuring your query

### Date range

Select the date range of the report by setting specific start and end dates, or using one of the preset options.

### Aggregation

Here you can aggregate your results by one or several categories. While selecting Single Aggregation, you will only be able to select one concept at a time. While selecting Multi Aggregation, you will be able to filter for multiple concepts at the same time. Costs will be aggregated by *Domain* by default. Fields by which you can aggregate are:

* Zone
* Resource Type
* Account Name
* Provider ID
* Charge Category
* Usage Unit
* Resource Name
* Domain

### Filtering

Kubecost supports filtering of the above aggregation categories. When a filter is applied, only resources with this matching value will be shown. Supports advanced filtering options as well.

You can also view the External Costs page from the Cloud Cost Explorer, when aggregating by *Provider*. Third party services will appear on this page, and when any line item is selected, you will be taken to External Costs.

### Additional configuration

Additional settings are available in Helm

```yaml
kubecostModel:
  plugins:
    enabled: true
    enabledPlugins:
    - datadog
  configs:
    datadog: |
      {
      "datadog_site": "us5.datadoghq.com",
      "datadog_api_key": "847081f247542151fc63b4dXXXX",
      "datadog_app_key": "6515819e6a3fb23c0dc3d6032ffc84XXXXX"
      }
  install:
    enabled: true
    fullImageName: curlimages/curl:latest
    securityContext:
      allowPrivilegeEscalation: false
      seccompProfile:
        type: RuntimeDefault
      capabilities:
        drop:
        - ALL
      readOnlyRootFilesystem: true
      runAsNonRoot: true
      runAsUser: 1000
  folder: /opt/opencost/plugin
  # leave this commented to always download most recent version of plugins
  # version: <INSERT_SPECIFIC_PLUGINS_VERSION>
```
