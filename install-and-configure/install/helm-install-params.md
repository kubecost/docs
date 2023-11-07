# Helm Parameters

Often while using and configuring Kubecost, our documentation may ask you to pass certain Helm flag values. There are three different approaches for passing custom Helm values into your Kubecost product, which are explained in this doc. In these examples, we are updating the `kubecostProductConfigs.productKey.key` Helm value which enables Kubecost Enterprise, however these methods will work for all other Helm flags.

## Method 1: Pass exact parameters via `--set` command-line flags

For example, you can only pass a product key if that is all you need to configure.

```bash
$ helm install kubecost cost-analyzer \
    --repo https://kubecost.github.io/cost-analyzer/ \
    --namespace kubecost --create-namespace \
    --set kubecostProductConfigs.productKey.key="123" \
    --set kubecostProductConfigs.productKey.enabled=true
    ...
## Method 2: Pass exact parameters via custom `values` file

Similar to Method 1, you can create a separate values file that contains only the parameters needed.

Your _values.yaml_ should look like this:

```
kubecostProductConfigs:
  productKey: 
    key: "123"
    enabled: true
```

Then run your install command:

```
$ helm install kubecost cost-analyzer \
    --repo https://kubecost.github.io/cost-analyzer/ \
    --namespace kubecost --create-namespace \
    --values values.yaml
```

## Method 3: Use [_values.yaml_](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) from the Kubecost Helm chart repository.

Taking this approach means you may need to sync with the repo to use the latest release.

Be careful when applying certain Helm values related to your UI configuration to your secondary clusters. For more information, see this section in our Multi-Cluster doc about [primary and secondary clusters](https://docs.kubecost.com/install-and-configure/install/multi-cluster#primary-and-secondary-clusters).
