# Kubecost Pricing Sources

## Overview

There are multiple ways that Kubecost can be configured to pull in pricing data. This document outlines the different options and how to configure them.

## Pricing sources matrix

{% hint style="info" %}
With the exception of integrated cloud provider billing, all pricing sources are configured per-cluster.
{% endhint %}

Kubecost supports the following pricing sources:

| Source | Detail | Pros | Cons |
|--|--|--|--|
| [Integrated cloud provider billing](/install-and-configure/install/cloud-integration/README.md) | Kubecost pulls cloud provider billing every 6 hours<br>When billing becomes available Kubecost reconciles the previously-estimated costs | Extremely accurate<br>Little maintenance<br>All cloud billing can be imported<br>Out-of-cluster costs can be [combined with Kubernetes resources](/using-kubecost/navigating-the-kubecost-ui/collections.md) | Kubecost requires access to the billing account<br>This setup can take time, especially if the team deploying Kubecost does not have access to the billing account |
| [Cloud Provider OnDemand API](pricing-sources-matrix.md#cloud-provider-ondemand-api) | On by default<br>Kubecost looks up public pricing APIs. | No configuration<br>No maintenance | For users with significant discounts, Kubecost costs will be significantly higher than actual billing. |
| [Custom Pricing](#custom-pricing) | Manually set monthly costs for: CPU, RAM, storage, GPU, network, spot CPU, spot RAM | Simple configuration<br>Does not require cloud provider access<br>Works for on-prem clusters<br>Completely air-gapped for highly-secure environments  | Accuracy dependent on value provided<br>Single rate per resource- no flexibility per node/storage types |
| [Azure Rate Card](../install-and-configure/install/cloud-integration/azure-out-of-cluster/azure-config.md) | Kubecost pulls Azure Rate Card API | More accurate Azure costs in the short-term (48 hours) | Limited value if billing-integration is configured<br>Requires additional setup with Azure |
| [Alibaba](../install-and-configure/install/provider-installations/alibaba-install.md) | Kubecost pulls Alibaba Rate Card API | Currently the only method to retrieve Alibaba resource pricing |More accurate costs<br>Requires additional setup with Alibaba |
| [AWS Spot Data Feed](/install-and-configure/install/cloud-integration/aws-cloud-integrations/aws-spot-instances.md) | Kubecost pulls spot prices from a custom feed | More accurate costs in the short-term (48 hours) for Spot nodes | Limited value if billing-integration is configured<br>Requires additional setup with AWS |
| [CSV Pricing](/install-and-configure/advanced-configuration/csv-pricing.md) | Kubecost Enterprise can use a user-provided CSV with granular resource prices. | Does not require cloud provider access<br>Works for on-prem clusters<br>Completely air-gapped for highly-secure environments | Mapping labels in the CSV can be tedious |

## Diagram

![Cloud Provider Billing Integrated](../images/cloud-bill-diagram.png)

## Details

### Cloud Provider OnDemand API

Kubecost will attempt to identify the provider of the cluster and pull pricing data from the public API. Alibaba and Azure have their own specific pricing sources.

- [Alibaba](../install-and-configure/install/provider-installations/alibaba-install.md)
- [Azure Rate Card](../install-and-configure/install/cloud-integration/azure-out-of-cluster/azure-config.md)

### Custom Pricing

Set the following Helm values via your *values-kubecost.yaml*, or in the Kubecost UI by going to *Settings*, then under 'Pricing', toggling on 'Enable Custom Pricing', then making adjustments per group:

![UI Custom Pricing Screenshot](/images/custompricing.png)

Prices are monthly. `storage` and miscellaneous network metrics are all per GB.

```yaml
kubecostProductConfigs:
  customPricesEnabled: true
  defaultModelPricing:
    enabled: true
    CPU: 28.0 # Single core per month cost
    spotCPU: 4.86 # Single core per month cost
    RAM: 3.09 # GB per month cost
    spotRAM: 0.65 # GB per month cost
    GPU: 693.50 # per month cost
    spotGPU: 225.0 # per month cost
    storage: 0.04 # per GB per month cost
    zoneNetworkEgress: 0.01 # per GB per month cost
    regionNetworkEgress: 0.01 # per GB per month cost
    internetNetworkEgress: 0.12 # per GB per month cost
```

### Cloud Provider-Billing Integrated

- [Cloud Provider Billing for Reconciliation and Out-of-Cluster Spend](/install-and-configure/install/cloud-integration/README.md)
  - [AWS Cost and Usage Report](/install-and-configure/install/cloud-integration/aws-cloud-integrations/aws-cloud-integrations.md)
  - [Azure Cost Export](/install-and-configure/install/cloud-integration/azure-out-of-cluster/azure-out-of-cluster.md)
  - [Google BigQuery Export](/install-and-configure/install/cloud-integration/gcp-out-of-cluster/README.md)

### OnDemand pricing references

- [AWS EC2 pricing](https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AmazonEC2/current/us-east-2/index.json)
- [Azure Retail Prices](https://learn.microsoft.com/en-us/rest/api/cost-management/retail-prices/azure-retail-prices)
- [GCP Cloud Billing - On-Demand VMs](https://cloud.google.com/billing/docs/reference/rest/v1/services.skus/list)
