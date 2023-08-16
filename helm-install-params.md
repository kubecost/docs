# Helm Parameters

There are three different approaches for passing custom Helm config values into the Kubecost project:

1.  **Pass exact parameters via `--set` command-line flags.** For example, you can only pass a product key if that is all you need to configure.

    ```bash
    $ helm install kubecost cost-analyzer \
        --repo https://kubecost.github.io/cost-analyzer/ \
        --namespace kubecost --create-namespace \
        --set kubecostProductConfigs.productKey.key="123"
        ...
    ```
2.  **Pass exact parameters via custom `values` file.** Similar to option #1, you can create a separate values file that contains only the parameters needed.

    ```bash
    $ helm install kubecost cost-analyzer \
        --repo https://kubecost.github.io/cost-analyzer/ \
        --namespace kubecost --create-namespace \
        --values values.yaml
    ```

    _values.yaml:_

    ```yaml
    kubecostProductConfigs:
      productKey: 
        key: "123"
        enabled: true
    ```
3. **Use** [**values.yaml**](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) **from the Kubecost Helm Chart repository.**

{% hint style="info" %}
Taking this approach means you may need to sync with the repo to use the latest release.
{% endhint %}
