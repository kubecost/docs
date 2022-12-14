# Table of contents

* [Welcome to the Docs!](README.md)

## Install and Configure

* [Installation](install.md)
  * [Environment](install-and-configure/install/environment.md)
  * [Helm Parameters](helm-install-params.md)
  * [Ingress Examples](ingress-examples.md)
  * [Cloud Billing Integrations](cloud-integration.md)
    * [Multi-Cloud Integrations](multi-cloud.md)
    * [AWS Cloud Integration](aws-cloud-integrations.md)
      * [AWS Out of Cluster](aws-out-of-cluster.md)
      * [AWS Spot Instances](aws-spot-instances.md)
      * [AWS Node Price Reconciliation Methodology](aws-node-price-reconcilitation-methodology.md)
    * [Azure Cloud Integration](azure-out-of-cluster.md)
      * [Azure Rate Card Configuration](azure-config.md)
    * [GCP Cloud Integration](gcp-out-of-cluster.md)
      * [Creating a Google Service Account](google-service-account-thanos.md)
  * [Multi-Cluster / Long Term Storage](long-term-storage.md)
    * [Federated ETL](federated-etl.md)
    * [AWS](install-and-configure/install/long-term-storage/aws/README.md)
      * [AWS Multi-Cluster Storage Configuration](long-term-storage-aws.md)
      * [Creating a Thanos IAM policy](aws-service-account-thanos.md)
    * [Azure](install-and-configure/install/long-term-storage/azure/README.md)
      * [Azure Long Term Storage](long-term-storage-azure.md)
    * [GCP](install-and-configure/install/long-term-storage/gcp/README.md)
      * [GCP Long Term Storage](long-term-storage-gcp.md)
    * [Thanos Upgrade](thanos-upgrade.md)
  * [Provider Installations](install-and-configure/install/provider-installations/README.md)
    * [Amazon EKS Integration](aws-eks-cost-monitoring.md)
    * [AWS Marketplace Install](aws-marketplace-install.md)
    * [Installing Kubecost on Alibaba](alibaba-install.md)
    * [Installation Kubecost with Istio (Rancher)](istio-rancher.md)
    * [Installing Kubecost with Rafay](rafay.md)
    * [Installing Kubecost with Plural](install-on-plural.md)
    * [Installing in Air-gapped Environments](air-gapped.md)
    * [Install Kubecost on Redhat OpenShift](openshift-kubecost-install.md)
    * [Deploy Kubecost from Red Hat Openshift’s OperatorHub](openshift-operatorhub-kubecost-install.md)
  * [Grafana Configuration Guide](custom-grafana.md)
  * [Prometheus Configuration Guide](custom-prom.md)
    * [Amazon Managed Service for Prometheus](aws-amp-integration.md)
    * [Grafana Cloud Integration for Kubecost](grafana-cloud-integration.md)
  * [Cost Analyzer Persistent Volume](storage.md)
* [Advanced Configuration](install-and-configure/advanced-configuration/README.md)
  * [Add Key](add-key.md)
  * [Enabling Annotation Emission](annotations.md)
  * [Network Traffic Cost Allocation](network-allocation.md)
  * [ETL Backup](etl-backup.md)
  * [User Management - SSO/SAML/RBAC](user-management.md)
  * [Multi-Cluster Options](multi-cluster.md)
  * [Federated Clusters](federated-clusters.md)
  * [TurndownSchedule Migration Guide](turndown-schedule-migration-guide.md)
  * [Deploy Kubecost Staging Builds](staging.md)
  * [Cluster Controller](controller.md)
  * [High Availability Kubecost](high-availability.md)
  * [Windows Node Support](windows.md)

## Integrations

* [Custom Webhook to Create a Kubecost Stage in Spinnaker](spinnaker-custom-webhook.md)

## General

* [OpenCost Product Comparison](opencost-product-comparison.md)
* [User Metrics](user-metrics.md)
* [Installing Agent for Kubecost Cloud (Alpha)](agent.md)
* [Tuning Resource Consumption](resource-consumption.md)
* [Calculating Node Pricing](node-pricing.md)

## Using Kubecost

* [Getting Started](getting-started.md)
  * [Kubernetes Cost Allocation](cost-allocation.md)
  * [Availability Tiers](availability-tiers.md)
  * [Cluster Health Score](cluster-health-score.md)
  * [Spot Checklist](spot-checklist.md)
  * [Spot Cluster Sizing](spot-cluster-sizing.md)
  * [Automatic Request Right-Sizing](auto-request-sizing.md)
    * [Guide: 1-click Request Sizing](using-kubecost/getting-started/auto-request-sizing/guide-1-click-request-sizing.md)
    * [Continuous Request Right-Sizing](continuous-request-sizing.md)
  * [Saved Reports](saved-reports.md)
  * [Alerts](alerts.md)
  * [Advanced Reporting](advanced-reports.md)
  * [Kubernetes Assets](assets.md)
  * [CSV Pricing](csv-pricing.md)
  * [Contexts](context-switcher.md)

## APIs

* [Kubecost API Directory](apis.md)
  * [Allocation API](allocation.md)
  * [V2 Filters](filters-v2.md)
  * [Assets API](assets-api.md)
  * [Abandoned Workloads](api-abandoned-workloads.md)
  * [Container Request Recommendation "Apply" APIs](api-request-recommendation-apply.md)
  * [Container Request Right Sizing Recommendation API (v2)](api-request-right-sizing-v2.md)
  * [Asset Diff API](asset-diff.md)
  * [Audit API](audit-api.md)
* [Deprecated APIs](apis/deprecated-apis/README.md)
  * [Container Request Right-Sizing Recommendation API (V1) - Deprecated](api-request-right-sizing.md)
  * [costDataModel & aggregatedCostModel API - Deprecated](allocation-api.md)
  * [Namespace Contacts](namespace-contacts.md)

## Architecture

* [Kubecost Core Architecture Overview](architecture.md)
* [Kubecost Cloud Architecture Overview](kubecost-cloud-architecture.md)
* [Open Source](open-source-deps.md)
* [Security and Data Protection](security.md)
* [Ports](ports.md)
* [Kubecost Memory Usage](app-memory.md)
* [Secondary Clusters Guide](secondary-clusters.md)
* [Kube-State-Metrics (KSM) Emission](ksm-metrics.md)
* [Kubecost Release Process](release-process.md)
* [Outages](outages.md)

## Troubleshooting

* [Frequently Asked Questions](setup/frequently-asked-questions.md)
* [Troubleshoot Install](troubleshoot-install.md)
* [Capture a Bug Report](bug-report.md)
* [Bug Bounty Program](bug-bounty-program.md)
* [Kubecost Diagnostics](diagnostics.md)
* [Running a Query in Kubecost-bundled Prometheus](prometheus.md)
* [Getting Support](support-channels.md)

## Other Resources

* [Contact Us](contactus.md)
* [Kubecost Blog](https://blog.kubecost.com/)
* [Kubecost Release Notes](https://github.com/kubecost/cost-analyzer-helm-chart/releases)
