Azure Long Term Storage
=======================

__Azure__

To use Azure Storage as Thanos object store, you need to precreate a storage account from Azure portal or using Azure CLI. Follow the instructions from Azure Storage Documentation: https://docs.microsoft.com/en-us/azure/storage/common/storage-quickstart-create-account

Now create a yaml file named `object-store.yaml` with the following format:

```
type: AZURE
config:
  storage_account: ""
  storage_account_key: ""
  container: ""
  endpoint: ""
  max_retries: 0
```

Edit this doc on [Github](https://github.com/kubecost/docs/blob/master/long-term-storage-azure.md)

<!--- {"article":"4407595954327","section":"4402815682455","permissiongroup":"1500001277122"} --->