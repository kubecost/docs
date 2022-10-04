---
description: 'TODO: internal links & cleanup'
---

# Frequently Asked Questions

Q: How can I reduce CPU or Memory resource consumption by Kubecost? A: Please see our tuning guide at: https://guide.Kubecost.com/hc/en-us/articles/6446286863383-Tuning-Resource-Consumption

Q: Can I safely configure Thanos Compaction downsampling? A: Yes, Kubecost is resilient to downsampling. However turning query concurrency is going to be most beneficial, especially during the long rebuild windows. To turn downsampling use the following Thanos sub-chart values.

Q: Why is the "Network" tile on the cost allocation page not showing any data? A: This tile relies on service names which requires one of the following values to be set. https://github.com/Kubecost/cost-analyzer-helm-chart/blob/39f0e06cded52dab845fa6def4df8e18fe800751/cost-analyzer/values.yaml#L582

Q: How often does reconciliation run? A: The Cloudusage process runs every 3 hours, however the cost and usage reports are updated by cloud providers less frequently. (This needs some verification and link to tuning if available)

Q: How often are AWS Spot prices updated? A: If enabled, Kubecost will refresh spot instances every 15 minutes. Note, that the spot data feed may be updated hourly. https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/spot-data-feeds.html

Q: I just enabled the CUR and AWS integration but do not see any cloud resources? A: The AWS CUR and billing data from other cloud providers lags by 24-48 hours.

Q: I have an empty namespace, why is it not showing up in Kubecost? A: Kubecost builds the allocation API from known workloads. If there are no workloads in the namespace it will not be aware of the namespace.

Q: What license does the "Paid" versions of Kubecost use? A: Paid Kubecost versions use our EULA: https://www.Kubecost.com/terms

Q: When configuring Spot feeds in a Federated cluster, where should it be configured? A: The Spot Data Feed is meant to supplement node prices before the CUR drops. Because of this, it should be configured in each cluster to give the most accurate estimates as the data needs to be written into Thanos.

Q: Does the Abandoned Workloads savings report rely on Network Traffic daemon set? A: No, it uses cAdvisor metrics.

Q: Does Kubecost cost efficiency calculation take GPU into consideration? A: No, the reason is that we get GPU efficiency from integration with the Nvidia DCGM, which is a third-party integration that needs to be set up manually with Kubecost.

Q: Should I use amortized prices when setting up my CUR or billing export? A: Yes, amortized allows upfront costs of the resources to appear in Kubecost. More info.

Q: Do I need to configure the Cloud integration on the Secondary clusters? A: No, Only if you are planning on viewing the UI on the secondary. This is because the cloud reconciliation process happens after the data is shipped to the Thanos store.

Q: What is the difference between rebuild and repair commands? A: Rebuild is a legacy command and repair should be used instead as it builds on top of the existing ETL instead of wiping it completely. (Prefer repair command when possible.)

How can I add TLS to the Kubecost Prometheus? A: See the following values https://github.com/Kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/charts/prometheus/values.yaml#L686

