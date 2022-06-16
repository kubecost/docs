Add Key
=======

You can apply your product key at any time within the product UI or during an install or upgrade process. More details on both options are provided below.

> Note: `kubecostToken` is a different concept from your product key and is used for managing trial access.

## At Install-time

Many Kubecost product configuration options can be specified at install-time, including your product key.

### Option #1: Storing Product Key in a Secret

To create a secret you will need to create a JSON file called `productkey.json` with the following format. Be sure to replace `<YOUR_PRODUCT_KEY>` with your Kubecost product key.

``` javascript
{ 
    "key": "<YOUR_PRODUCT_KEY>"
}
```

Run the following command to create the secret. Replace `<SECRET_NAME>` with a name for the secret (example: `productkeysecret`):

``` shell
$ kubectl create secret generic <SECRET_NAME> -n kubecost --from-file=./productkey.json
```

Update your [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/5eedab0433445a5b8e134113beb95f4598cd5e2d/cost-analyzer/values.yaml#L714-L717) to enable the product key and specify the secret name:

* `kubecostProductConfigs.productKey.enabled = true`
* `kubecostProductConfigs.productKey.secretname = <SECRET_NAME>`

Run a `helm upgrade` to start using your product key.

### Option #2: Specifying Product Key in values.yaml

This specific parameter can be configured under `kubecostProductConfigs.productKey.key` in your [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/84dfbe4addedfee55b50af6ca44c1f62966d4457/cost-analyzer/values.yaml#L426).

> Note: you must also set the `kubecostProductConfigs.productKey.enabled` config to `true` when using this option.

> Note: that this will leave your secrets unencrypted in values.yaml. Use a Kubernetes secret as in the previous method to avoid this.

## In Product

To apply your license key within the Kubecost UI, visit the Overview page and then select **UPGRADE** in the page header.

Next, select **ADD KEY** in the dialog menu shown below.

You can then supply your Kubecost provided license key in the input box that is now visible.

![Add key dialog](https://raw.githubusercontent.com/kubecost/docs/main/images/add-key-dialog.png)

## Verification

To verify that your key is properly supplied, visit the Settings UI to confirm the final digits are as expected:

![image](https://user-images.githubusercontent.com/298359/111573440-c74c9c00-8767-11eb-842c-cfa18159d1c1.png)

Please reach out to support@kubecost.com with any questions.

Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/add-key.md)

<!--- {"article":"4407595912983","section":"4402815636375","permissiongroup":"1500001277122"} --->