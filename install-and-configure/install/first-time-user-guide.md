# First Time User Guide

After successfully installing Kubecost, new users should familiarize themselves with these onboarding steps to begin immediately realizing value. This doc will explain to you the core features and options you will have access to and direct you to other necessary docs groups that will help you get set up.

While certain steps in this article may be optional depending on your setup, these are recommended best practices for seeing the most value out of Kubecost as soon as possible.

## Step 1: Integrate with your cloud provider(s)

Many Kubernetes adopters may have billing with cloud service providers (CSPs) that differs from public pricing. By default, Kubecost will detect the CSP of the cluster where it is installed and pull list prices for nodes, storage, and LoadBalancers across all major CSPs: Azure, AWS, and GCP.&#x20;

However, Kubecost is also able to integrate these CSPs to receive the most accurate billing data. By completing a cloud integration, Kubecost is able to reconcile costs with your actual cloud bill to reflect enterprise discounts, Spot market prices, commitment discounts, and more.&#x20;

New users should seek to integrate any and all CSPs they use into Kubecost. For an overview of cloud integrations and getting started, see our [Cloud Billing Integrations](https://docs.kubecost.com/install-and-configure/install/cloud-integration) doc. Once you have completed all necessary integrations, return to this article.

Due to the frequency of updates from providers, it can take anywhere from 24 to 48 hours to see adjusted costs.

## Step 2: Review your data

Now that your base install and CSP integrations are complete, it's time to determine the accuracy against your cloud bill. Based on different methods of cost aggregation, Kubecost should assess your billing data within a 3-5% margin of error.

### Monitoring your cost billing

After enabling port-forwarding, you should have access to the Kubecost UI. Explore the different pages in the left navigation, starting with the Monitor dashboards. These pages, including Allocations, Assets, Clusters, and Cloud Costs, are comprised of different categories of cost spending, and allow you to apply customized queries for specific billing data. These queries can then be saved in the form of reports for future quick access. Each page of the Kubecost UI has more dedicated information in the [Navigating the Kubecost UI](https://docs.kubecost.com/using-kubecost/navigating-the-kubecost-ui) section.

## Step 3: Learn about protecting your data and spend

It's important to take precautions to ensure your billing data is preserved, and you know how to monitor your infrastructure's health.

### ETL Backup

Metrics reside in Prometheus, but extracting information for either the UI or through API responses directly from this store is not performant at scale.  For this reason, the data is optimized and stored in a structure is called extract, transform, load, or ETL. Kubecost's definition of ETL usually will refer to this ETL process.

Like any other system, backup of critical data is a must, and backing up ETL is no exception. To address this, we offer a number of different options based on your product tier. Descriptions and instructions for our backup functionalities can be found in our [ETL Backup](https://docs.kubecost.com/install-and-configure/install/etl-backup) doc.

### Alerts and Health

Similar to most systems, monitoring health is vital.  For this, we offer several means of monitoring the health of both Kubecost and the host cluster.

#### Alerts

[Alerts ](https://docs.kubecost.com/using-kubecost/navigating-the-kubecost-ui/alerts#configuring-alerts-in-the-kubecost-ui)can be configured to enable a proactive approach to monitoring your spend, and can be distributed across different workplace communication tools including email, Slack, and Microsoft Teams. Alerts can establish budgets for your different types of spend and cost-efficiency, and warn you if those budgets are reached. These Alerts are able to be configured via Helm or directly in your Kubecost UI.

#### Health

The [Health](https://docs.kubecost.com/using-kubecost/navigating-the-kubecost-ui/cluster-health-score) page will display an overall cluster health score which assesses how reliably and efficiently your infrastructure is performing. Scores start at 100 and decrease based on how severe  any present errors are.

## Step 4: Multi-cluster and federated setups

Kubecost has multiple ways of supporting multi-cluster environments, which vary based on your Kubecost product tier.

Kubecost Free will only allow you to view a single cluster at a time in the Kubecost UI. However, you can connect multiple different clusters and switch through them using Kubecost's [context switcher](https://docs.kubecost.com/using-kubecost/context-switcher).

Kubecost Enterprise provides a "single-pane-of-glass" view which combines metrics across all clusters into a shared storage bucket. One cluster is designated as the primary cluster from which you view the UI, with all other clusters considered secondary. Attempting to view the UI through a secondary cluster will not display metrics across your entire environment.

It is recommended to complete the steps above for your primary cluster before adding any secondary clusters. To learn more about advanced multi-cluster/Federated configurations, see our [Multi-Cluster](https://docs.kubecost.com/install-and-configure/install/multi-cluster) doc.

## Step 5: Explore Kubecost functionality through the UI

Port forward with `kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090`, then access `http://localhost:9090` in your web browser to see Kubecost's UI. There are plenty of monitoring, savings, and governance tools at your disposal, each with dedicated documentation. See our [Navigating the Kubecost UI](/using-kubecost/navigating-the-kubecost-ui/README.md) section for a complete overview of these features.

## Learning more about Kubecost

After completing these primary steps, you are well on your way to being proficient in Kubecost. However, managing Kubernetes infrastructure can be complicated, and for that we have plenty more documentation to help. For advanced or optional configuration options, see our [Next Steps with Kubecost](https://docs.kubecost.com/install-and-configure/install/getting-started) guide which will introduce you to additional concepts.
