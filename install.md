# Installation

## Installing Kubecost

To get started with Kubecost and OpenCost, **the recommended path is to** [**install Kubecost Community Version**](https://kubecost.com/install). This installation method is available for free and leverages the Kubecost Helm Chart. It provides access to all OpenCost and Kubecost community functionality and can scale to large clusters. This will also provide a token for trialing and retaining data across different Kubecost product tiers.

## Alternative installation methods

1. You can also install directly with the [Kubecost Helm Chart](https://github.com/kubecost/cost-analyzer-helm-chart/) with Helm v3.1+ using the following commands. This provides the same functionality as the step above but doesn't generate a product token for managing tiers or upgrade trials.

```bash
helm upgrade --install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost --create-namespace
```

2. You can run [Helm Template](https://helm.sh/docs/helm/helm\_template/) against the [Kubecost Helm Chart](https://github.com/kubecost/cost-analyzer-helm-chart/) to generate local YAML output. This requires extra effort when compared to directly installing the Helm Chart but is more flexible than deploying a flat manifest.

```bash
helm template kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost --create-namespace \
  -f your-custom-values.yaml > kubecost.yaml
kubectl apply -f kubecost.yaml
```

3. You can install via flat manifest. This install path is not recommended because it has limited flexibility for managing your deployment and future upgrades.

{% code overflow="wrap" %}
```bash
kubectl apply -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/kubecost.yaml
```
{% endcode %}

4. Lastly, you can deploy the open-source OpenCost project directly as a Pod. This install path provides a subset of free functionality and is available [here](https://www.opencost.io/docs/install). Specifically, this install path deploys the underlying cost allocation model without the same UI or access to enterprise functionality: cloud provider billing integration, RBAC/SAML support, and scale improvements in Kubecost.

## Updating Kubecost

Kubecost releases are scheduled on a near-monthly basis. You can keep up to date with new Kubecost updates and patches by following our release notes [here](https://github.com/kubecost/cost-analyzer-helm-chart/releases).

After installing Kubecost, you will be able to update Kubecost with the following command, which will upgrade you to the most recent version:

```
helm repo update && helm upgrade kubecost kubecost/cost-analyzer -n kubecost
```

You can upgrade or downgrade to a specific version of Kubecost with the following command:

```
helm upgrade kubecost --repo... --version 1.XXX.X
```

## Deleting Kubecost

To uninstall Kubecost and its dependencies, run the following command:

```
helm uninstall kubecost -n kubecost
```
