# Helm Parameters

Often while using and configuring Kubecost, our documentation may ask you to pass certain Helm values. There are two different methods for passing custom Helm values into Kubecost which are explained on this page. In these examples, we are updating the `kubecostProductConfigs.productKey.key` Helm value which enables Kubecost Enterprise, however these methods will work for all other Helm values.

## Method 1: Pass exact parameters via `--set` command-line flags

For example, you can only pass a product key if that is all you need to configure.

```bash
helm install kubecost cost-analyzer \
    --repo https://kubecost.github.io/cost-analyzer/ \
    --namespace kubecost --create-namespace \
    --set kubecostProductConfigs.productKey.key="123" \
    --set kubecostProductConfigs.productKey.enabled=true
```

## Method 2: Pass exact parameters via custom values file

Similar to Method 1, you can create a separate values file that contains only the parameters needed.

Your values file should look like this:

```yaml
kubecostProductConfigs:
  productKey: 
    key: "123"
    enabled: true
```

Then run your install command:

```bash
helm install kubecost cost-analyzer \
    --repo https://kubecost.github.io/cost-analyzer/ \
    --namespace kubecost --create-namespace \
    --values my_values_file.yaml
```
