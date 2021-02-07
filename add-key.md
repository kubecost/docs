# add-key

You can apply your product key at any time within the product UI or during an install or upgrade process. More details on both options are provided below.

## In Product

To apply your license key within the Kubecost UI, visit the Overview page and then select **UPGRADE** in the page header. Next, select **ADD KEY** in the dialog menu shown below. You can then supply your Kubecost provided license key in the input box that is now visible.

![Add key dialog](.gitbook/assets/add-key-dialog.png)

## At Install-time

Many Kubecost product configuration options can be specified at install-time, including your product key. This specific parameter can be configured under `kubecostProductConfigs.productKey.key` in your [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/84dfbe4addedfee55b50af6ca44c1f62966d4457/cost-analyzer/values.yaml#L426). Note: you must also set `kubecostProductConfigs.productKey.enabled` to `true` when using this option.

Please reach out to team@kubecost.com with any questions.

