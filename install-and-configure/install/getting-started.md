# Next Steps with Kubecost

Once you have familiarized yourself with Kubecost and integrated with any cloud providers, it's time to move on to more advanced concepts. This doc provides commonly used product configurations and feature overviews to help get you up and running after the Kubecost product has been [installed](https://kubecost.com/install). You may be redirected to other Kubecost docs to learn more about specific concepts or follow tutorials.

## Memory and storage

The default Kubecost installation has a 32Gb persistent volume and a 15-day retention period for Prometheus metrics. This is enough space to retain data for roughly 300 pods, depending on your exact node and container count. See the Kubecost Helm chart [configuration options](https://github.com/kubecost/cost-analyzer-helm-chart) to adjust both the retention period and storage size.

{% hint style="warning" %}
Prometheus is not optional. Disabling Prometheus will result in zero costs in Kubecost. For more information, see Kubecost's [Prometheus Configuration Guide](/install-and-configure/advanced-configuration/custom-prom/custom-prom.md).
{% endhint %}

To determine the appropriate disk size, you can use this formula to approximate:

{% code overflow="wrap" %}
```text
needed_disk_space = retention_time_minutes * ingested_samples_per_minutes * bytes_per_sample
```
{% endcode %}

Where ingested samples can be measured as the average over a recent period, e.g. `sum(avg_over_time(scrape_samples_post_metric_relabeling[24h]))`. On average, Prometheus uses around 1.5-2 bytes per sample. So, ingesting 100k samples per minute and retaining them for 15 days would demand around 40 GB. It’s recommended to add another 20-30% capacity for headroom and WAL. More info on disk sizing can be found in Prometheus' [Storage](https://prometheus.io/docs/prometheus/latest/storage/#operational-aspects) doc.

## Setting requests and limits

Users should set and/or update resource requests and limits before taking Kubecost into production at scale. These inputs can be configured in the Kubecost [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) for Kubecost modules and subcharts.

The exact recommended values for these parameters depend on the size of your cluster, availability requirements, and usage of the Kubecost product. Suggested values for each container can be found within Kubecost itself on the namespace page. More info on these recommendations is available [here](https://blog.kubecost.com/blog/requests-and-limits/).

For best results, run Kubecost for up to seven days on a production cluster, then tune resource requests/limits based on resource consumption.

## Configure security of user access

To broaden usage to other teams or departments within your Kubecost environment, basic security measures will usually be required. There are a number of options for protecting your workspace depending on your Kubecost product tier.

### Ingress controller

Establishing an ingress controller will allow for control of access for your workspace. Learn more about enabling external access in Kubecost with our [Ingress Examples](/install-and-configure/install/ingress-examples.md) doc.

### SSO/SAML/RBAC/OIDC

{% hint style="info" %}
SAML/OIDC-configured RBAC and SSO are Kubecost Enterprise only features.
{% endhint %}

See the below guides for configuring SSO with SAML or OIDC. Teams RBAC is currently only supported with SAML:

* [SAML](/install-and-configure/advanced-configuration/user-management-saml/README.md)
* [OIDC](/install-and-configure/advanced-configuration/user-management-oidc/user-management-oidc.md)
* [Teams](../../using-kubecost/navigating-the-kubecost-ui/teams.md) - RBAC using Kubecost UI

## **Resource efficiency and idle costs**

Efficiency and idle costs can teach you more about the cost-value of your Kubernetes spend by showing you how efficiently your resources are used. To learn more about pod resource efficiency and cluster idle costs, see [Efficiency and Idle](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/efficiency-idle.md).

## **See also**

* [Using an existing Prometheus installation](/install-and-configure/advanced-configuration/custom-prom/custom-prom.md)
* [Using an existing Grafana installation](/install-and-configure/advanced-configuration/custom-grafana.md)
* [Exposing Kubecost with an Ingress](ingress-examples.md)
