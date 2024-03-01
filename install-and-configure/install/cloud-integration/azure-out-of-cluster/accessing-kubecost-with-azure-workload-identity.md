# Azure Cloud Integration using Azure Workload Identity

As of v.2.1.1, Kubecost supports Cloud Integration via Azure Workload Identity. Refer to the [Microsoft documentation](https://learn.microsoft.com/en-us/azure/aks/workload-identity-deploy-cluster) to learn more about how to set up Azure Workload Identity in AKS. For this tutorial, you will need to have the cluster name, resource group, federated identity credential name provided by Azure.


### 1. Validate that OIDC is enabled on the Azure Cluster

```bash
$ export AKS_OIDC_ISSUER="$(az aks show -n $CLUSTER_NAME -g "${RESOURCE_GROUP}" --query "oidcIssuerProfile.issuerUrl" -otsv)"
https://westus.oic.<redacted>.azure.com/<redacted>
```

### 2. Create the federated credential between the managed identity and kubecos-cost-analyzer service account:

```bash
az identity federated-credential create --name ${FEDERATED_IDENTITY_CREDENTIAL_NAME} --identity-name ${USER_ASSIGNED_IDENTITY_NAME} --resource-group ${RESOURCE_GROUP} --issuer ${AKS_OIDC_ISSUER} --subject system:serviceaccount:${KUBECOST_NAMESPACE}:kubecost-cost-analyzer
```

### 3. Add to cost-analyzer deployment in values.yaml

```yaml
kubecostDeployment:
  labels:
    azure.workload.identity/use: "true"
serviceAccount:
  annotations:
    azure.workload.identity/client-id: $AZURE_CLIENT_ID
```

From here, run a helm upgrade to apply the values. You should now have access to all expected Kubecost functionality through your service account with Identity Workload.



### 4. Create a JSON file which **must** be named _cloud-integration.json_ with the following format:

```json
{
    "azure": {
     "storage":[
      {
            "subscriptionID": "AZ_cloud_integration_subscriptionId",
            "account": "AZ_cloud_integration_azureStorageAccount",
            "container": "AZ_cloud_integration_azureStorageContainer",
            "path": "",
            "cloud": "public/gov",
            "authorizer":{
             "authorizerType": "AzureDefaultCredential"
            }
        }
     ]
   }
}
```
### 5. Create the Secret:

{% code overflow="wrap" %}
```bash
$ kubectl create secret generic <SECRET_NAME> --from-file=cloud-integration.json -n kubecost
```
{% endcode %}

Next, ensure the following are set in your Helm values:

```yaml
kubecostProductConfigs:
  cloudIntegrationSecret: <SECRET_NAME>
```

### 6. Apply the changes above by upgrading Kubecost via helm:

```bash
helm upgrade --install kubecost --repo https://kubecost.github.io/cost-analyzer cost-analyzer --namespace kubecost -f values.yaml
```

