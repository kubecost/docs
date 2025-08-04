# Cloud Cost Metrics

When ingesting billing data from cloud service providers (CSP), Kubecost records multiple cost metrics for each item. These cost metrics represent different pricing models which may be useful depending on what needs to be accomplished. The cost metrics currently supported by Cloud Cost are:

* ListCost
* NetCost
* AmortizedNetCost
* InvoicedCost
* AmortizedCost

Each cost metric includes a `Cost` and a `KubernetesPercent` field. An unaggregated CloudCost query should have a `1` or a `0` in the `KubernetesPercent` field of all of its cost metrics. When it becomes aggregated, this value can become a percentage. It is necessary to keep track of these separately because differences in cost metrics will cause this value to diverge. For example, aggregating a Cloud Cost representing a Kubernetes node that has a reserved instance applied to it, and a non-Kubernetes node of the same type but with no reserved instance discount. See below:

```text
Node1 {
    ListCost: {
        Cost: 2,
        KubernetesPercent: 1.0,
    },
    AmortizedNetCost: {
        Cost:  1,
        KubernetesPercent: 1.0
    },
}

Node2 {
    ListCost: {
        Cost: 2,
        KubernetesPercent: 0.0,
    },
    AmortizedNetCost: {
        Cost:  2,
        KubernetesPercent: 0.0
    },
}

agg {
    ListCost: {
        Cost: 4,
        KubernetesPercent: 0.5,
    },
    AmortizedNetCost: {
        Cost:  3,
        KubernetesPercent: 0.33
    },

}
```

The `KubernetesPercent` on the AmortizedNetCost is calculated at 33% from $1 which was 100% Kubernetes spend and $2 that were 0% Kubernetes spend in that dimension.

## Cost metrics by CSP

The current Cloud Cost schema is optimistic in that it provides space for cost metrics that may not yet be available from some providers. As the FOCUS Spec gains more adoption among CSPs, all fields will be populated with values that match the definitions. For now, some values on certain providers are being populated with their nearest approximate. This section outlines how each value is populated on each CSP.

<details>

<summary>AWS cost metrics</summary>

Of all billing exports and APIs, the Cost and Usage Report (CUR) has the most robust set of cost metrics, and currently has the best support. Depending on what kind of discounts or resources a user has, the schema changes, therefore many of these columns are populated dynamically to support all users. In particular, any `_net_` column will only be available if the user has a discount that causes it to exist. Additionally, Kubecost currently only considers line items that have a `line_item_line_item_type` of `Usage`, `DiscountUsage`, `SavingsPlanCoveredUsage`, `EdpDiscount`, or `PrivateRateDiscount`.

More information on the columns and their definitions can be found in AWS' [Line item details](https://docs.aws.amazon.com/cur/latest/userguide/Lineitem-columns.html) documentation.

**List Cost**

To populate list price, Kubecost uses `pricing_public_on_demand_cost`.

**Net Cost**

Kubecost uses `line_item_net_unblended_cost` if available. If not, Kubecost uses `line_item_unblended_cost.`

**Amortized Net Cost**

If `_net_` is not available, Kubecost uses Amortized Cost

If `line_item_line_item_type` is `DiscountUsage`, Kubecost uses `reservation_net_effective_cost`.

If `line_item_line_item_type` is `SavingsPlanCoveredUsage`, Kubecost uses `savings_plan_net_savings_plan_effective_cost`.

Default to `line_item_net_unblended_cost`.

**Invoiced Cost**

Kubecost uses Net Cost.

**Amortized Cost**

If `line_item_line_item_type` is `DiscountUsage`, Kubecost uses `reservation_effective_cost`.

If `line_item_line_item_type` is `SavingsPlanCoveredUsage`, Kubecost uses `savings_plan_savings_plan_effective_cost`.

Default to `line_item_unblended_cost`.

</details>

<details>

<summary>GCP cost metrics</summary>

Cloud Cost uses a detailed billing export accessed via BigQuery to interface with GCP. This export provides Kubecost with a Cost column with a float value in addition to an array of credit objects per item. These credits are various discounts applied to the item being referenced.

More details about the export can be found in GCP's [Structure of Detailed data export](https://cloud.google.com/billing/docs/how-to/export-data-bigquery-tables/detailed-usage).

**List Cost**

The Cost column for the line item.

**Net Cost**

The Cost column plus the sum of all credit amounts.

**Amortized Net Cost**

Amortized Net Cost is Cost with all credits and amortized CUD payments
`amortizedNetCost := cost + creditAmount + cudCreditAmount + flexibleCUDCreditAmount + flexibleCUDNetPayedAmount`

**Invoiced Cost**

Kubecost uses Net Cost.

**Amortized Cost**

Amortized Cost is Cost plus CUD credits and amortized CUD payments
`amortizedCost := cost + cudCreditAmount + flexibleCUDCreditAmount + flexibleCUDPayedAmount`

</details>

<details>

<summary>Azure cost metrics</summary>

The Azure billing export can be set to amortized or not amortized during creation. Depending on this, either the Net Cost Metric or Amortized Net Cost metric will be accurate. Additionally the Azure export has multiple schema depending on when it was created and what kind of account the user has. There are also localized versions of the headers.

**List Cost**

Kubecost uses`paygcostinbillingcurrency` if available, otherwise Kubecost uses Net Cost

**Net Cost**

Kubecost uses `costinbillingcurrency`. If not available, Kubecost uses `pretaxcost`, and if that isn't available, Kubecost uses `cost`.

**Amortized Net Cost**

Kubecost uses Net Cost.

**Invoiced Cost**

Kubecost uses Net Cost.

**Amortized Cost**

Kubecost uses Net Cost.

</details>

## Kubernetes clusters

To calculate the 'K8s Utilization', Kubecost must first determine if a resources is part of a Kubernetes cluster or not.

If a tag or label in the list below is present on the billing export, Kubecost will consider those costs part of the 'K8s Utilization' calculation. This will not always be 100% accurate in all situations.

<details>

<summary>AWS</summary>

In AWS, Kubecost will identify the line item in the bill as a Kubernetes resource if `line_item_product_code` is `AmazonEKS`, or one of the following label keys is present:

* `resource_tags_aws_eks_cluster_name`
* `resource_tags_user_eks_cluster_name`
* `resource_tags_user_alpha_eksctl_io_cluster_name`
* `resource_tags_user_kubernetes_io_service_name`
* `resource_tags_user_kubernetes_io_created_for_pvc_name`
* `resource_tags_user_kubernetes_io_created_for_pv_name`

</details>

<details>

<summary>GCP</summary>

The billing report has a Tags column which contains a Record of key values pairs. Kubecost checks for the presence of the following keys which may not have associated value:

* `goog-gke-volume`
* `goog-gke-node`
* `goog-k8s-cluster-name`

</details>

<details>

<summary>Azure</summary>

The billing export has a tags column with a JSON string of key values pairs. Kubecost checks for the presence of keys with the following prefixes:

* `aks-managed`
* `kubernetes.io-created`
* `k8s-azure-created`

</details>
