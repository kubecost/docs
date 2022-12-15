---
description: 'Common Kubecost questions (faq).'
---

# Frequently Asked Questions

Q: How can I reduce CPU or Memory resource consumption by Kubecost?\
A: Please review our [Tuning Resource Consumption guide](https://docs.kubecost.com/general/resource-consumption).

Q: Can I safely configure Thanos Compaction [down sampling](https://thanos.io/tip/components/compact.md/#downsampling)?\
A: Yes, Kubecost is resilient to downsampling. However turning query concurrency is going to be most beneficial, especially during the long rebuild windows. To tune downsampling use the following Thanos subchart [values](https://github.com/kubecost/cost-analyzer-helm-chart/blob/b5b089ce217636fb2b7e6f42daed37397d28d3aa/cost-analyzer/charts/thanos/values.yaml#L525-L530).

Q: Why do I receive a 403 error when trying to save reports or alerts?\
A: This is due to the SAML user having read only RBAC permissions.&#x20;

Q: What does "Share Tenancy" mean?\
A: This enables sharing the cost of the K8s management plane for hosted Kubernetes offerings, such as EKS/AKS/GKE costs.

Q: Why is the "Network" tile on the Allocations page not showing any data?\
A: This tile relies on service names which requires one of the following [values](https://github.com/kubecost/cost-analyzer-helm-chart/blob/b5b089ce217636fb2b7e6f42daed37397d28d3aa/cost-analyzer/values.yaml#L576-L585) to be enabled.

Q: How often does reconciliation run?\
A: The Cloud Usage process runs every 3 hours, however the Cost and Usage Reports (CUR) are updated by cloud providers less frequently.

Q: How are short-lived jobs accounted for?\
A: If the Prometheus [scrape interval](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values.yaml#L440) is 1m, then a job that ran for 5s or 30s or 60s or 100s, but only registered one data point, all costs the same to us: 1m \* $/m. The scrape interval can be configured to be faster, but there are consequences (More resource usage due to additional metrics).

Q: How often are AWS Spot prices updated?\
A: If enabled, Kubecost will refresh Spot instances every 15 minutes. Note, that the Spot data feed may be updated hourly. [Review the AWS docs for more conclusive info.](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-data-feeds.html)

Q: My CUR appears to be integrated properly but I'm not seeing any additional cloud assets that I would expect on the Assets page.\
A: Verify that the Helm values of `kubecostModel.etlCloudUsage` or `kubecostModel.etlCloudAsset` are not set to false. [See the Helm chart for reference.](https://github.com/kubecost/cost-analyzer-helm-chart/blob/93d3255870766d236628359a969b7691450d0095/cost-analyzer/templates/cost-analyzer-deployment-template.yaml#L679-L688)

Q: I just enabled the CUR and AWS integration but do not see any cloud resources?\
A: The AWS CUR and billing data from other cloud providers lags by 24-48 hours.

Q: Why is the UI on my secondary Kubecost install broken?\
A: This is normal if you have followed our [secondary tuning guide](https://docs.kubecost.com/architecture/secondary-clusters), because its focus is reducing resource usage at the cost of breaking the secondary UI. The secondary UI should only be used for diagnostics.

Q: I have two standalone Kubecost clusters in an Azure subscription, each residing in their own resource group. How can I limit the billing export for each cluster to only the resource group instead of the entire subscription?\
A: You can create two billing exports each scoped to the corresponding resource group. [Review Azure's guide on exporting date for more info.](https://learn.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-export-acm-data?tabs=azure-portal#create-a-daily-export)

Q: I have an empty namespace, why is it not showing up in Kubecost?\
A: Kubecost builds the allocation API from known workloads. If there are no workloads in the namespace it will not be aware of the namespace.

Q: Can customer logos be added to Kubecost?\
A: Currently, this feature isn't planned. Due to technical difficulties, this may take considerable effort to implement.

Q: What license do the Business and Enterprise versions of Kubecost use?\
A: Paid Kubecost versions use our [EULA](https://www.kubecost.com/terms).

Q: When configuring Spot feeds in a federated cluster, where should it be configured?\
A: The Spot data feed is meant to supplement node prices before the CUR drops. Because of this, it should be configured in each cluster to give the most accurate estimates as the data needs to be written into Thanos.\
\
Q: Does the Abandoned Workloads savings report rely on the Network Traffic daemonSet?\
A: No, it uses cAdvisor metrics.\
\
Q: Does Kubecost cost efficiency calculation take GPU into consideration?\
A: No, the reason is that we get GPU efficiency from integration with the Nvidia DCGM, which is a third-party integration that needs to be set up manually with Kubecost.

Q: Should I use amortized prices when setting up my CUR or billing export?\
A: Yes, amortized allows upfront costs of the resources to appear in Kubecost. [More info here](https://docs.kubecost.com/install-and-configure/advanced-configuration/cloud-integration#cloud-integration-configurations).

Q: Do I need to configure the cloud integration on the secondary clusters?\
A: No, only if you are planing on viewing the UI on the secondary. This is because the cloud reconciliation process happens after the data is shipped to the Thanos store.

Q: What is the difference between `rebuild` and `repair` commands?\
A: `rebuild` is a legacy command and `repair` should be used instead, as it builds on top of the existing ETL instead of wiping it completely. (Use `repair` command when possible.)

Q: For GCP, I'm unable to see the GCP Project on the Allocations page.\
A: You can only filter by project in Assets. A workaround for this is naming their clusters with a naming convention that includes the project name or number.

Q: How can I add TLS to the Kubecost-bundled Prometheus?\
A: See the following [Helm values](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/charts/prometheus/values.yaml#L686).

Q: Does Kubecost change labels/tags that include a `-` dash to an `_` underscore?\
A: Yes, this is due to imitations in how Prometheus handles labels.

Q: What time of the day is the Azure costs export updated?\
A: The Azure costs export update time is relative to the time of day when it was initially created. See [Azure docs on exporting data for more](https://docs.microsoft.com/en-us/azure/cost-management-billing/costs/tutorial-export-acm-data?tabs=azure-portal#export-schedule)

Q: What regions/currencies are available for the Azure rate card integration?\
A: Azure is very specific as to what currency can be used for each region/country. Azuew provides that information [here](https://docs.microsoft.com/en-us/azure/marketplace/marketplace-geo-availability-currencies).

Q: I would like to use the node-exporter daemonSet provided with Openshift, however after disabling Kubecost-bundled Prometheus, it is unable to discover the node-exporter endpoints.\
A: The Openshift provided node-exporter requires an additional annotation of `prometheus.io/scrape: "true"` to be added.&#x20;

```
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/path: '/metrics'
        prometheus.io/port: "9100"
```

Q: How can I disable kube-state-metrics if needed? \
A: It can be disabled with one of two methods `prometheus.kubeStateMetrics.enabled=false` or `prometheus.kube-state-metrics.disabled=true`. We recommend disabling any 3rd party KSM instead of our bundled version. More discussion is [here].

Q: Does increasing the `.Values.kubecostModel.etlResolutionSeconds` value cause any issues with cost accuracy?\
A: Decreasing resolution may flatten out cost spikes but the summation of costs should not be affected.

Q: Is there a way to test alerts via the API?\
A: Yes, there is a `/alert/test` API endpoint that sends a blank test message. [Code](https://github.com/kubecost/kubecost-cost-model/blob/948c2d1e9aff42808f5458be9f557769aad1b493/pkg/cmd/costmodel/costmodel.go#L2508)\
\
Another suggestion for testing alert filters is to create an alert with a small window and waited. The [API](https://guide.kubecost.com/hc/en-us/articles/4407601796759-Alerts-Documentation#alerts-scheduler) will allow hours in the window.&#x20;

Example of [test API](http://localhost:9090/model/alerts/test)\ payload:

```
aggregation: "namespace"
filter: "kubecost"
id: "a454aafd-fd08-4aa8-bcf3-99d49e082ff1"
type: "recurringUpdate"
window: "1h" 
```

Q: Kubecost allows us to configure in-zone/in-region/cross-region traffic classification. After I tried to configure this and seeing that the values have been configured, I couldn’t see traffic classification allocation in the dashboard. Is this feature still supported?

A: Check http://your.kubecost.com/details! From there, look for the bottom right box to view more network details. It also may be important to have the network-costs daemonSet running in your cluster.

Q: When cloud integration is not yet enabled, does Kubecost's usage of public pricing data take into account the region the node is on?\
A: Yes. This can be verified by reviewing the code at [opencost/pkg/cloud](https://github.com/opencost/opencost/tree/1795bcddb1d91d3e60772030528274c4dff29185/pkg/cloud). Specifically, if you start at [GetNodeCost()](https://github.com/opencost/opencost/blob/1795bcddb1d91d3e60772030528274c4dff29185/pkg/costmodel/costmodel.go#L933) you can follow the chain of function calls. It's slightly different for each cloud provider, but it should look roughly like this: `pkg/costmodel/GetNodeCost() → pkg/cloud/NodePricing() → pkg/cloud/DownloadPricingData() → pkg/cloud/getRegionPricing()`

Q: If I disable node exporter, will it affect the metrics emitted by Kubecost?\
A: Yes you can disable node exporter as it is optional. No, it will not have an effect on Kubecost's metrics. Read about the effects of disabling the node exporter [here](https://docs.kubecost.com/general/resource-consumption#disable-or-stop-scraping-node-exporter).

Q: “No Athena Bucket Configured” error on /diagnostics view?\
A: Verify that the the AWS IAM Policy has been correctly configured (step3). Verify that the IAM role has been given to Kubecost (step4).

Q: What time zone is shown by Kubecost?\
A: All APIs and metrics will be based on and accept UTC zones. When viewing the data from your web browser, the graphs displayed will convert this UTC time to your local machine's time zone.

Q: When using the `aggregate` parameter with the Allocation API `/model/allocation`, the returned line items don't always list the full set of "properties". \
A: This happens when the values of these "properties" collide upon performing the aggregation. For example if performing the aggregation by `aggregate=label:app`, the line item `app=hello-world` may belong to multiple namespaces and Kubecost would therefore omit "properties.namespace" altogether. The most effective workaround is to perform a multiaggregation (`aggregate=namespace,label:app`) to ensure all the properties you want exist in the result. More discussion in this [Github issue](https://github.com/kubecost/cost-analyzer-helm-chart/issues/1839).
