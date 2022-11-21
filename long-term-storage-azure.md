Azure Long Term Storage
=======================

To use Azure Storage as Thanos object store, you need to precreate a storage account from Azure portal or using Azure CLI. Follow the instructions from the [Azure Storage Documentation](https://docs.microsoft.com/en-us/azure/storage/common/storage-quickstart-create-account).

Now create a .YAML file named `object-store.yaml` with the following format:

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



<!--- {"article":"4407595954327","section":"4402815682455","permissiongroup":"1500001277122"} --->
