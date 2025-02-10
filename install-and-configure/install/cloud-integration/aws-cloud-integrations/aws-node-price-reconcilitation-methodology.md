# AWS Node Price Reconciliation Methodology

Kubecost is capable of aggregating the costs of EC2 compute resources over a given time frame with a specified duration step size. To achieve this, Kubecost uses Athena queries to gather usage data points with differing price models. The result of this process is a list of resources with their cost by time frame.

## Athena queries

The reconciliation process makes two queries to Athena, one to gather resources that are paid for with either the on-demand model or a savings plan and one query for resources on the reservation price model. The first query includes resources given at a blended rate, which could be on-demand usage or resources that have exceeded the limits of a savings plan. It will also include resources that are part of a savings plan which will have a savings plan effective cost. The second query only includes reserved resources and the cost which reflects the rate they were reserved at.

The queries make use of the following columns from Athena:

* `line_item_usage_start_date` The beginning timestamp of the line item usage. Used to filter resource usage within a date range and to aggregate on usage window.
* `line_item_usage_end_date` The ending timestamp of the line item usage. Used to filter resource usage within a date range and to aggregate on usage window.
* `line_item_resource_id` An ID, also called the provider ID, is given to line items that are instantiated resources.
* `line_item_line_item_type` The type of a line item, used to determine if the resource usage is covered by a savings plan and has a discounted price.
* `line_item_usage_type` What is being used in a line item, for the purposes of a compute resource this, is the type of VM and where it is running
* `line_item_product_code` The service that a line item is from. Used to filter out items that are not from EC2.
* `reservation_reservation_a_r_n` Amazon Resource Name for reservation of line item, the presence of this value is used to identify a resource as being part of a reservation plan.
* `line_item_unblended_cost` The undiscounted cost of a resource.
* `savings_plan_savings_plan_effective_cost` The cost of a resource discounted by a savings plan
* `reservation_effective_cost` The cost of a resource discounted by a reservation

### On-Demand/Savings plan query

This query is grouped by six columns:

1. `line_item_usage_start_date`
2. `line_item_usage_end_date`
3. `line_item_resource_id`
4. `line_item_line_item_type`
5. `line_item_usage_type`
6. `line_item_product_code`

The columns `line_item_unblended_cost` and `savings_plan_savings_plan_effective_cost` are summed on this grouping. Finally, the query filters out rows that are not within a given date range, have a missing `line_item_resource_id`, and have a `line_item_product_code` not equal to "AmazonEC2". The grouping has three important aspects, the time frame of the line items, the resource as defined by the resource id, and the usage type, which is later used to determine the proper cost of the resources as it was used. This means that line items are grouped according to the resource, the time frame of the usage, and the rate at which the usage was charged.

### Reservation query

The reservation query is grouped on five columns:

1. `line_item_usage_start_date`
2. `line_item_usage_end_date`
3. `reservation_reservation_a_r_n`
4. `line_item_resource_id`
5. `line_item_product_code`

The query is summed on the `reservation_effective_cost` and filtered by the date window, for missing `reservation_reservation_a_r_n` values and also removes line items with `line_item_product_code` not equal to "AmazonEC2". This grouping is on resource id by time frame removing all non-reservation line items.

## Processing query results

The on-demand query is categorized into different resource types: compute, network, storage, and others. The network is identified by the presence of the "byte" in the `line_item_usage_type`. Compute and storage are identified by the presence of "i-" and "vol-" prefixes in `line_item_resource_id` respectively. Non compute values are removed from the results. Out of the two costs aggregated by this query the correct one to use is determined by the `line_item_line_item_type`, if it has a value of "SavingsPlanCoveredUsage", then the `savings_plan_savings_plan_effective_cost` is used as the cost, and if not then the `line_item_unblended_cost` is used.

In the reservation query, all of the results are of the compute category and there is only the `reservation_effective_cost` to use as a cost.

These results are then merged into one set, with the provider id used to associate the cost with other information about the resource.

## Why doesn't this match the AWS Cost Explorer?

There are several different ways to look at your node cost data. The default for the cost explorer is _Unblended_" but it makes the most sense from an allocation perspective to use the amortized rates. Be sure _Amortized costs_ is selected when looking at cost data. Here's an example of how they can vary dramatically on our test cluster.

The t2-mediums here are covered by a savings plan. Unblended, the cost is only $0.06/day for two.

![Unblended node costs](/images/aws-node-price-unblended.png)

When _Amortized costs_ is selected, the price jumps to $1.50/day

![Amortized node costs](/images/aws-node-price-amortized.png)

This should closely match our data on the Assets page, for days where we have adjustments come in from the pricing CUR.

![Kubecost Assets dashboard](/images/aws-node-price-assets.png)
