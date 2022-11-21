Multi-Cluster Options
===============

Kubecost supports two methods for users with multiple clusters, and they can be used together.

1. Kubecost Enterprise allows for a ___single-pane-of-glass___ view into all aggregated cluster costs globally. A `primary cluster` serves the Kubecost UI and API endpoints and all `secondary clusters` send metrics to a central storage bucket. See: [architecture diagram](https://guide.kubecost.com/hc/en-us/articles/4407595922711).
2. Kubecost Business gives visibility into a single-cluster-at-time and uses a [context switcher](https://github.com/kubecost/docs/blob/main/context-switcher.md) to move between different contexts.

> **Note**: Kubecost Free version can now be installed on an unlimited number of individual clusters. Larger teams may benefits from one of the above subscriptions to better manage many clusters. See [pricing](https://www.kubecost.com/pricing) for more details.

---



