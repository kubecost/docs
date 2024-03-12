# Kubecost Pricing Sources

## Overview

There are multiple ways that Kubecost can be configured to pull in pricing data. This document outlines the different options and how to configure them.

## Pricing sources matrix

Kubecost supports the following pricing sources:

| Source | Detail | Pros | Cons |
|--|--|--|--|
| [Cloud Provider OnDemand API](pricing-sources-matrix.md#cloud-provider-ondemand-api) | On by default<br>Kubecost looks up public pricing APIs. | No configuration<br>No maintenance | For users with significant discounts, Kubecost costs will be significantly higher than actual billing. |
| [Custom Pricing](#custom-pricing) | Manually set monhtly costs for: CPU, RAM, storage, GPU, network, spot CPU, spot RAM | Simple configuration<br>Does not require cloud provider access<br>Works for on-prem clusters<br>Completely air-gapped for highly-secure environements  | Accuracy dependent on value provided<br>Single rate per resource- no flexibility per node/storage types |
| [Cloud Provider-Billing Integrated](/install-and-configure/install/cloud-integration/README.md) | Kubecost pulls cloud provider billing every 6 hours<br>When billing becomes available Kubecost reconciles the previously-estimated costs | Extremely accurate<br>Little maintenance<br>All cloud billing can be imported<br>Out-of-cluster costs can be [combined with Kubernetes resources](navigating-the-kubecost-ui/collections.md) | Kubecost requires access to the billing account<br>This setup can take time, especially if the team deploying Kubecost does not have access to the billing account |
| [CSV Pricing](/install-and-configure/advanced-configuration/csv-pricing.md) | Kubecost uses a user-provided CSV with granular resource prices. | Does not require cloud provider access<br>Works for on-prem clusters<br>Completely air-gapped for highly-secure environements | Mapping labels in the CSV can be tedious |
| [AWS Spot Data Feed](/install-and-configure/install/cloud-integration/aws-cloud-integrations/aws-spot-instances.md) | Kubecost pulls spot prices from a custom feed | More accurate costs in the short-term (48 hours) | Limited value if billing-integration is configured<br>Requires additional setup with AWS |

## Diagram

![Cloud Provider Billing Integrated](../images/cloud-bill-diagram.png)

## Detail

### Cloud Provider OnDemand API

[AWS EC2](https://pricing.us-east-1.amazonaws.com/offers/v1.0/aws/AmazonEC2/current/us-east-2/index.json)

### Custom Pricing

Set via your *values-kubecost.yaml*, or in the Kubecost UI by going to *Settings*, then under 'Pricing', toggling on 'Enable Custom Pricing', then making adjustments per group:

![UI Custom Pricing Screenshot](/images/custompricing.png)

Prices are monthly. `storage` and miscellaneous network metrics are all per GB.

```yaml
kubecostProductConfigs:
  defaultModelPricing:
    enabled: true
    CPU: 28.0
    spotCPU: 4.86
    RAM: 3.09
    spotRAM: 0.65
    GPU: 693.50
    spotGPU: 225.0
    storage: 0.04
    zoneNetworkEgress: 0.01
    regionNetworkEgress: 0.01
    internetNetworkEgress: 0.12
```

### Cloud Provider-Billing Integrated

- [Cloud Provider Billing for Reconciliation and Out-of-Cluster Spend](/install-and-configure/install/cloud-integration/README.md)
  - [AWS Cost and Usage Report](/install-and-configure/install/cloud-integration/aws-cloud-integrations/aws-cloud-integrations.md)
  - [Azure Cost Export](/install-and-configure/install/cloud-integration/azure-out-of-cluster/azure-out-of-cluster.md)
  - [Google BigQuery Export](/install-and-configure/install/cloud-integration/gcp-out-of-cluster/README.md)

### CSV Pricing

[CSV Pricing](../install-and-configure/advanced-configuration/csv-pricing.md):

![CSV Pricing Table](/images/pricing.png)

### Spot data feed

[AWS Spot Data Feed](../install-and-configure/install/cloud-integration/aws-cloud-integrations/aws-spot-instances.md)
