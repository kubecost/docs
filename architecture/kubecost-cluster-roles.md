# Kubecost Cluster Roles

Kubecost requires read only RBAC permissions on most cluster resources in order to build a granular cost-model for all resources. `Role` can be set to make changes in your namespace, while `ClusterRole` is required to make changes across the cluster (and therefore in all namespaces).

`cluster-admin` is required to install Kubecost. However, this role is not required to modify the deployment afterwards.

Kubecost requires `get`, `list`, and `watch` permissions over many common Kubernetes pod and pod controller resources such as pods, deployments, StatefulSets as well as other resources which factor into to cost analysis such as namespaces, nodes, events, etc.

The source of these rules can be found in [Kubecost's ClusterRole template](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/templates/cost-analyzer-cluster-role-template.yaml).
