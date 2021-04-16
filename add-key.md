You can apply your product key at any time within the product UI or during an install or upgrade process. 
More details on both options are provided below.

> Note: `kubecostToken` is a different concept from your product key and is used for managing trial access.

## At Install-time

Many Kubecost product configuration options can be specified at install-time, including your product key. 
This specific parameter can be configured under `kubecostProductConfigs.productKey.key` in your [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/84dfbe4addedfee55b50af6ca44c1f62966d4457/cost-analyzer/values.yaml#L426). 

> Note: you must also set the `kubecostProductConfigs.productKey.enabled` config to `true` when using this option. 

## In Product

To apply your license key within the Kubecost UI, visit the Overview page and then select **UPGRADE** in the page header. 
Next, select **ADD KEY** in the dialog menu shown below. 
You can then supply your Kubecost provided license key in the input box that is now visible.

![Add key dialog](/images/add-key-dialog.png)

## Verification

To verify that your key is properly supplied, visit the Settings UI to confirm the final digits are as expected:

![image](https://user-images.githubusercontent.com/298359/111573440-c74c9c00-8767-11eb-842c-cfa18159d1c1.png)

Please reach out to team@kubecost.com with any questions.
