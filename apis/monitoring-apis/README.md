# Monitoring APIs

Monitoring APIs generally refer to querying through the primary Kubecost monitoring dashboards, being [Allocations](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/README.md), [Assets](/using-kubecost/navigating-the-kubecost-ui/assets.md), and the [Cloud Cost Explorer](/using-kubecost/navigating-the-kubecost-ui/cloud-costs-explorer/cloud-cost-metrics.md).

## Using the `summary/topline` endpoint

Several Kubecost monitoring APIs have an additional /topline/ endpoint which will function the same as any normal query, but will total all costs by category. These categories should mirror cost metric columns found in the tables of each monitoring dashboard. An example of using `/topline` to view total costs for Assets data would look like:

GET `http://<your-kubecost-address>/model/assets/topline?window=...`

When querying for Allocation data, you must add a `/summary` before `topline`, and the query for that will look like:

GET `http://<your-kubecost-address>/model/allocation/summary/topline?window=...`