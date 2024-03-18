# First Time User Guide

After installing Kubecost, the following guide will detail steps to complete the configuration of Kubecost.

While certain steps in this article may be optional depending on your setup, the steps below are `recommended best practices` for most users.

Not all environments will need, or have security policies preventing, billing integrations with Kubecost. See this [pricing sources matrix](/architecture/pricing-sources-matrix.md) for detail of each method of providing Kubecost with more accurate resource costs.

## Integrate with your cloud provider(s)

By default, Kubecost will detect the Cloud Service Provider (CSP) of the cluster where it is installed and pull list prices for nodes, storage, network transfer, and LoadBalancers. For Azure, AWS, and GCP- this works without any additional Kubecost configuration.&#x20;

However, many organizations have discounts with cloud service providers (CSPs). Kubecost supports `cloud-integrations` which pull CSP billing information to reconcile costs to reflect enterprise discounts, Spot market prices, commitment discounts, and more.&#x20;

For an overview of cloud integrations and getting started, see our [Cloud Billing Integrations](/install-and-configure/install/cloud-integration/README.md) doc. Once you have completed all necessary integrations, return to this article.

Due to the frequency of billing updates from providers, it can take anywhere from 24 to 48 hours to see adjusted costs.

## Currency Types

Kubecost uses USD by default, though you can also configure your currency display type. Kubecost supports the following currency types: USD, AUD, BRL, CAD, CHF, CNY, DKK, EUR, GBP, IDR, INR, JPY, NOK, PLN, and SEK. Kubecost does *not* perform any currency conversion when switching currency types; it is for display purposes, therefore you should ideally match your currency type to your cloud billing.

Currency type can only be changed via a [`helm` upgrade to your *values.yaml*](/install-and-configure/install/helm-install-params.md), using the flag `.Values.kubecostProductConfigs.currencyCode`. For example, if you needed to convert your currency type to EUR, you would add the following to your `helm` command:

```sh
--set kubecostProductConfigs.currencyCode=EUR
```

## Data Protection

By default, Kubecost stores its data in a native file format called `ETL` and it is stored in a Kubernetes `PersistentVolume`. While it is possible to rebuild this ETL from data that may be in Prometheus, it is recommended to back up this data. For more information on backing up your ETL, see our [ETL Backup](/install-and-configure/install/etl-backup/etl-backup.md) doc.

### Monitor and budget to better control your spend

#### Alerts

[Alerts](/using-kubecost/navigating-the-kubecost-ui/alerts.md#configuring-alerts-in-the-kubecost-ui) can be configured to enable a proactive approach to monitoring your spend, and can be distributed across different workplace communication tools including email, Slack, and Microsoft Teams. Alerts can establish budgets for your different types of spend and cost-efficiency, and warn you if those budgets are reached. These Alerts are able to be configured via Helm or directly in your Kubecost UI.

#### Anomaly Detection

[Anomaly Detection](/using-kubecost/navigating-the-kubecost-ui/anomaly-detection.md) can detect when spending for any integrated cloud services begins deviating outside an expected range. Detected anomalies will be reported and can be investigated to determine causes of excessive spend.

## Multi-cluster and federated setups

Kubecost has multiple ways of supporting multi-cluster environments, which vary based on your Kubecost product tier.

Kubecost Free will only allow you to view a single cluster at a time in the Kubecost UI.

Kubecost Enterprise provides a "single-pane-of-glass" view which combines metrics across all clusters via a shared storage bucket. One cluster is designated as the primary cluster from which you view the UI, with all other clusters considered secondary, running an agent.

To learn more about multi-cluster/Federated configurations, see our [Multi-Cluster](/install-and-configure/install/multi-cluster/multi-cluster.md) doc.

## Explore Kubecost functionality through the UI

Kubecost has a UI that is not exposed by default. Before exposing the UI, consider securing it using traditional Kubernetes ingress methods. Here are a few [Ingress Examples](/install-and-configure/install/ingress-examples.md).

For testing Kubecost, we recommend port-forwarding. This can be done with `kubectl port-forward --namespace svc/kubecost-cost-analyzer 9090`, then accessing `http://localhost:9090` in your web browser to see Kubecost's UI.

See our [Navigating the Kubecost UI](/using-kubecost/navigating-the-kubecost-ui/README.md) section for a complete overview of the various monitoring, savings, and governance tools, each with dedicated documentation.

## Learning more about Kubecost

See our [Next Steps with Kubecost](/install-and-configure/install/getting-started.md) guide which will introduce you to additional concepts.
