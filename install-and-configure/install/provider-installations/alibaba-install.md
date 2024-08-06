# Installing Kubecost on Alibaba

## Installing Kubecost via Helm

Installing Kubecost on an Alibaba cluster is the same as other cloud providers with Helm v3.1+:

`helm install kubecost/cost-analyzer -n kubecost -f values.yaml`

Your _values.yaml_ files must contain the below parameters:

```
prometheus:
  server:
    global:
      external_labels:
        cluster_id: aliyun-ali-test-1 # Each cluster should have a unique ID

kubecostProductConfigs:
  clusterName: "aliyun-ali-test-" # used for display in Kubecost UI
  serviceKeySecretName: "alibaba-service-key"
```

The `alibaba-service-key` can be created using the following command:

{% code overflow="wrap" %}
```
kubectl create secret generic alibaba-service-key -n kubecost –from-file=your_path/service-key.json
```
{% endcode %}

Your path needs a file having Alibaba Cloud secrets. Alibaba secrets can be passed in a JSON file with the file in the format:

```
{
     "alibaba_access_key_id": “XXX”
     "alibaba_secret_access_key": “XXX"
}
```

These two can be generated in the Alibaba Cloud portal. Hover over your user account icon, then select _AccessKey Management_. A new window opens. Select _Create AccessKey_ to generate a unique access token that will be used for all activities related to Kubecost.

In the access key's policy, add the DescribePrice and DescribeDisks permission to get accurate pricing information.

## Alibaba Cloud integration

Currently, Kubecost does not support complete integration of your Alibaba billing data like for other major cloud providers. Instead, Kubecost will only support public pricing integration, which will provide proper list prices for all cloud-based resources. Features like reconciliation and savings insights are not available for Alibaba. For more information on setting up a public pricing integration, see our [Multi-Cloud Integrations](/install-and-configure/install/cloud-integration/multi-cloud.md) doc.

## Troubleshooting

### Cannot install Kubecost without a default StorageClass

While getting all the available Storage Classes that the Alibaba K8s cluster comes with, there may not be a default storage class. Kubecost installation may fail as the cost-model pod and Prometheus server pod would be in a status pending state.

To fix this issue, make any of the Storage Classes in the Alibaba K8s cluster as Default using the below command:

{% code overflow="wrap" %}
```
 kubectl patch storageclass alicloud-disk-available -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' 
```
{% endcode %}

Following this, installation should proceed as normal.
