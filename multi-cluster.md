Multi-Cluster Options
===============

Kubecost supports two methods for users with multiple clusters, and they can be used together.

1. Kubecost Enterprise allows for a ___single-pane-of-glass___ view into all aggregated cluster costs globally. A `primary cluster` serves the Kubecost UI and API endpoints and all `secondary clusters` send metrics to a central storage bucket. See: [architecture diagram](https://guide.kubecost.com/hc/en-us/articles/4407595922711).
2. Kubecost Business allows for a single-cluster-at-time view and uses a context switching (bookmark) [utility](./context-switcher.md) to move between different clusters.

Note that the Kubecost Free Edition is designed for small teams with a single cluster. Larger teams should consider one of the above subscriptions. It is also a great way for large teams to understand what value Kubecost delivers. See [pricing](https://www.kubecost.com/pricing) for more details.

---
Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/multi-cluster.md)

<!--- {"article":"4407595970711","section":"4402815636375","permissiongroup":"1500001277122"} --->
