# Installing Kubecost on Alibaba

## Helm install Kubecost

Kubecost installation is exactly same as other cloud providers with Helm 3:

` helm install kubecost/cost-analyzer -n kubecost -f values.yaml`

With values.yaml files containing below parameters at least:

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

`alibaba-service-key` can be create using the following command:

```
kubectl create secret generic alibaba-service-key -n kubecost –from-file=./example_path
```

Your path needs a file having Alibaba Cloud secrets. Alibaba secrets can be passed in a JSON file with the file in the format.

```
{
     "alibaba_access_key_id": “XXX”
     "alibaba_secret_access_key": “XXX"
}
```
These two can be generated in the Alibaba Cloud portal. Hover over your user account icon, then select _AccessKey Management_. A new window opens. Select _Create AccessKey_ to generate a unique access token for your Kubecost that will be used for all the activity related to Kubecost.

## Troubleshooting

### Cannot install Kubecost without a default StorageClass

While getting all the available Storage Classes that the Alibaba K8s cluster comes with, there may not be a default storage class. Kubecost installation may fail as the cost-model pod and Prometheus server pod would be in a status pending state.

To fix this issue, make any of the Storage Classes in the Alibaba K8s cluster as Default using the below command:

```
 kubectl patch storageclass alicloud-disk-available -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}' 
```

Following this, installation should proceed as normal.
