# Add Key

You can apply your product key at any time within the product UI or during an install or upgrade process. More details on both options are provided below.

If you have a [multi-cluster setup](/install-and-configure/install/multi-cluster/multi-cluster.md), you only need to apply your product key on the Kubecost primary cluster, and not on any of the Kubecost secondary clusters.

{% hint style="info" %}
`kubecostToken` is a different concept from your product key and is used for managing trial access.
{% endhint %}

## Option 1: Apply your product key at install

Many Kubecost product configuration options can be specified at install-time, including your product key.

### Option 1: Storing product key in a secret

To create a secret you will need to create a JSON file called _productkey.json_ with the following format. Be sure to replace `<YOUR_PRODUCT_KEY>` with your Kubecost product key.

```json
{ 
  "key": "<YOUR_PRODUCT_KEY>"
}
```

Run the following command to create the secret. Replace `<SECRET_NAME>` with a name for the secret (example: `productkeysecret`):

{% code overflow="wrap" %}
```shell
$ kubectl create secret generic <SECRET_NAME> -n kubecost --from-file=productkey.json
```
{% endcode %}

Update your [_values.yaml_](https://github.com/kubecost/cost-analyzer-helm-chart/blob/5eedab0433445a5b8e134113beb95f4598cd5e2d/cost-analyzer/values.yaml#L714-L717) to enable the product key and specify the secret name:

* `kubecostProductConfigs.productKey.enabled=true`
* `kubecostProductConfigs.productKey.secretname=<SECRET_NAME>`

Run a `helm upgrade` command to start using your product key.

### Option 2: Apply your product key to _values.yaml_ and upgrade Kubecost

This specific parameter can be configured under `kubecostProductConfigs.productKey.key` in your [_values.yaml_](https://github.com/kubecost/cost-analyzer-helm-chart/blob/84dfbe4addedfee55b50af6ca44c1f62966d4457/cost-analyzer/values.yaml#L426).

{% hint style="info" %}
You must also set the `kubecostProductConfigs.productKey.enabled=true` when using this option. That this will leave your secrets unencrypted in _values.yaml_. Use a Kubernetes secret as in the previous method to avoid this.
{% endhint %}

## Option 3: Apply your product key in the Kubecost UI

To apply your license key within the Kubecost UI, visit the Overview page, then select _Upgrade_ in the page header.

Next, select _Add Key_ in the dialog menu shown below.

You can then supply your Kubecost provided license key in the input box that is now visible.

![Add key dialog](/images/add-key-dialog.png)

## Verification

To verify that your key has been applied successfully, visit _Settings_ to confirm the final digits are as expected:

![Verifying a product key](/images/add-key-verification.png)
