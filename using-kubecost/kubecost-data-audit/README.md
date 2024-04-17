# Kubecost Data Audit

When configuring the [Cloud Billing Integration](/install-and-configure/install/cloud-integration/README.md), Kubecost is able to reconcile its predictions (which leverage public pricing APIs) with actual billing data to improve accuracy. After Kubecost ingests and reconciles against your cloud billing data, it's able to provide 95%+ accuracy for Kubernetes costs, and 99%+ accuracy for out-of-cluster costs.

This doc provides guidance on how to validate the prices in Kubecost match that of your cloud provider's cost management dashboard.

## Prerequisite

Before comparing costs between Kubecost and your cloud provider's cost management dashboard, ensure your Kubecost deployment has configured [Cloud Billing Integrations](/install-and-configure/install/cloud-integration/README.md).

## Viewing detailed costs of a node in Kubecost

Auditing Kubecost data is most effective when targeting small ranges of time. In this doc, the primary goal is to ensure the price of a single node for a single day is correct. Then, there is more confidence when comparing with a window of 7 days. Or when comparing cost of the entire cluster. Or when aggregating costs by account or label.

Also, keep in mind that it typically takes ~24-48hrs for cloud providers to provide new billing data, then for Kubecost to ingest this new data and reconcile its predictions against the billing data.

1. Go to the Assets page, then select _Aggregate By_ > _Single Aggregation_ > _Service_.

    ![Assets page with aggregation type](/images/data-auditing/dataaudit-step1.png)

2. Audits are most effective when targeting small ranges of time. Select a Start and End Date which covers a window of 1 day, and is beyond 48 hours ago. Also select a date that has reconciled with the AWS Cost and Usage Report (CUR). CUR data can be delayed up to 24 hours.

    ![Assets page with time range](/images/data-auditing/dataaudit-step2.png)

3. Select the _Kubernetes_ service from the table underneath the NAME column, then select _Node_. You should arrive at a page like this (if your information is displayed in a bar graph, you can change the display by selecting _Edit_, then _Entire Window_ under the Resolution dropdown):

    ![Asset view by node](/images/data-auditing/dataaudit-step3.png)

4. Select any node to view its details.

    ![Detailed node cost information](/images/data-auditing/dataaudit-step4.png)

## Viewing detailed costs of a node in Kubecost (via API)

```bash
curl -G http://localhost:9090/model/assets \
    -d 'window=2023-02-14T00:00:00Z,2023-02-15T00:00:00Z' \
    -d 'filterTypes=Node' \
    -d 'filterProviders=AWS'
```

For more configuration options, visit the [Assets API doc](/apis/monitoring-apis/assets-api.md).
