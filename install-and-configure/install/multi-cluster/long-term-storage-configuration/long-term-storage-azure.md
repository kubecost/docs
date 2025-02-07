# Azure Multi-Cluster Storage Configuration

{% hint style="info" %}
Usage of a Federated Storage Bucket is only supported for Kubecost Enterprise plans.
{% endhint %}

To use Azure Storage as an ETL object store, you need to pre-create a storage account from Azure the portal or using the Azure CLI. Follow the instructions from the [Azure Storage Documentation](https://docs.microsoft.com/en-us/azure/storage/common/storage-quickstart-create-account).

Now create a .YAML file named `federated-store.yaml` with the following format:

``` yaml
type: AZURE
config:
  storage_account: ""
  storage_account_key: ""
  container: ""
  # config.endpoint is only needed if primary blob service endpoint domain is not blob.core.windows.net
  # Example: blob.core.chinacloudapi.cn
  endpoint: ""
  max_retries: 0
```
