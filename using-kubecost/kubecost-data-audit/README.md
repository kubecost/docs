# Kubecost Data Audit

When configuring the [cloud billing integration](/cloud-integration.md), Kubecost is able to reconcile its predictions (which leverage public pricing APIs) with actual billing data to improve accuracy. After Kubecost ingests & reconciles against your cloud billing data, it's able to provide 95%+ accuracy for Kubernetes costs, and 99%+ accuracy for out-of-cluster costs.

These docs provide guidance on how to validate the prices in Kubecost match that of your cloud provider's cost management dashboard.
