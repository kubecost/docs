# Adding a Product Key

You can apply your product key at any time within the product UI or during an install or upgrade process. More details on both options are provided below.

If you have a [multi-cluster setup](/install-and-configure/install/multi-cluster/multi-cluster.md), you only need to apply your product key on the Kubecost primary cluster. In the event that you are viewing/repairing data on a secondary cluster, you will need to apply your product key on that cluster as well.

{% hint style="info" %}
`kubecostToken` is a different concept from your product key and is used for managing trial access.
{% endhint %}

## Option 1: Storing product key in a secret

To create a secret you will need to create a JSON file called _productkey.json_ with the following format. Be sure to replace `<YOUR_PRODUCT_KEY>` with your Kubecost product key.

```json
{ 
  "key": "<YOUR_PRODUCT_KEY>"
}
```

Run the following command to create the secret. Replace `<SECRET_NAME>` with a name for the secret (example: `productkeysecret`):

{% code overflow="wrap" %}

```bash
kubectl create secret generic <SECRET_NAME> -n kubecost --from-file=productkey.json
```

{% endcode %}

Update your [_values.yaml_](https://github.com/kubecost/cost-analyzer-helm-chart/blob/d5144c1c5354e2978b56194f10d3a87cd545a100/cost-analyzer/values.yaml#L3420-L3424) to enable the product key and specify the secret name, then run a `helm upgrade`:

```yaml
kubecostProductConfigs:
  productKey:
    enabled: true
    secretname: <SECRET_NAME>
```

## Option 2: Apply your product key to _values.yaml_ and upgrade Kubecost

You can also place your product key directly in your [_values.yaml_](https://github.com/kubecost/cost-analyzer-helm-chart/blob/d5144c1c5354e2978b56194f10d3a87cd545a100/cost-analyzer/values.yaml#L3420-L3424), then run a `helm upgrade`.

```yaml
kubecostProductConfigs:
  productKey:
    enabled: true
    key: "<YOUR_PRODUCT_KEY>"
```

## Option 3: Apply your product key in the Kubecost UI

To apply your license key within the Kubecost UI, visit the Overview page, then select _Upgrade_ in the page header.

Next, select _Add Key_ in the dialog menu shown below.

You can then supply your Kubecost provided license key in the input box that is now visible.

![Add key dialog](/images/add-key-dialog.png)

## Verification

To verify that your key has been applied successfully, visit _Settings_ to confirm the final digits are as expected:

![Verifying a product key](/images/add-key-verification.png)
