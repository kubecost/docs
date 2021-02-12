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