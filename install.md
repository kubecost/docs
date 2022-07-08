Installation
===================

To get started with OpenCost and Kubecost, **the recommended path is to [install Kubecost community version](http://kubecost.com/install)**. This installation method is available for free and leverages the Kubecost Helm Chart. It provides access to all OpenCost and Kubecost community functionality and can scale to large clusters. This will also provide a token for trialing and retaining data across different Kubecost product tiers.

## Alternative installation methods

* You can also install directly with the [Kubecost Helm Chart](https://github.com/kubecost/cost-analyzer-helm-chart/) with Helm 3 using the following commands. This provides the same functionality as the step above but doesn't generate a product token for managing tiers or upgrade trials.

```
 helm repo add kubecost https://kubecost.github.io/cost-analyzer/
 helm upgrade --install kubecost kubecost/cost-analyzer --namespace kubecost --create-namespace
```

* You can run [Helm Template](https://helm.sh/docs/helm/helm_template/) against the [Kubecost Helm Chart](https://github.com/kubecost/cost-analyzer-helm-chart/) to generate local YAML output. This requires extra effort when compared to directly installing the Helm Chart but is more flexible than deploying static YAML.

* You can install via [flat manifest](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/README.md#manifest). This install path provides less flexibility for managing your deployment and has several product limitations, e.g. Thanos is not easily enabled.

* Lastly, you can deploy the open source project directly as a Pod. This install path provides a subset of free functionality and is available [here](https://github.com/kubecost/cost-model/blob/master/deploying-as-a-pod.md). Specifically, this install path deploys the underlying cost allocation model without the same UI or access to enterprise functionality, e.g. SAML support.

Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/install.md)

<!--- {"article":"4407601821207","section":"4402815636375","permissiongroup":"1500001277122"} --->
