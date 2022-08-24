Azure Rate Card Configuration
============

Kubecost needs access to the Microsoft Azure Billing Rate Card API to access accurate pricing data for your Kubernetes resources.

> Note: you can also get this functionality plus external costs by completing the full [Azure billing integration](/azure-out-of-cluster.md).

## Creating a Custom Azure Role

Start by creating an Azure role definition. Below is an example definition, replace `YOUR_SUBSCRIPTION_ID` with the Subscription ID where your Kubernetes Cluster lives:

```json
{
    "Name": "KubecostRole",
    "IsCustom": true,
    "Description": "Rate Card query role",
    "Actions": [
        "Microsoft.Compute/virtualMachines/vmSizes/read",
        "Microsoft.Resources/subscriptions/locations/read",
        "Microsoft.Resources/providers/read",
        "Microsoft.ContainerService/containerServices/read",
        "Microsoft.Commerce/RateCard/read"
    ],
    "AssignableScopes": [
        "/subscriptions/YOUR_SUBSCRIPTION_ID"
    ]
}
```

Save this into a file called `myrole.json`

Next, you'll want to register that role with Azure:

```shell
az role definition create --verbose --role-definition @myrole.json
```

## Creating an Azure Service Principal

Next, create an Azure Service Principal.

```shell
az ad sp create-for-rbac --name "KubecostAccess" --role "KubecostRole" --scope "/subscriptions/YOUR_SUBSCRIPTION_ID" --sdk-auth true > my_credentials.json
```

The newly created `my_credentials.json` file will contain the relevant configuration information.

## Azure Billing Region, Offer Durable ID, and Currency

Kubecost supports querying the Azure APIs for cost data based on the region, offer durable id, and currency defined in your Microsoft Azure offer.

Those properties are configured with the following helm values:

* `kubecostProductConfigs.azureBillingRegion`
* `kubecostProductConfigs.azureOfferDurableID`
* `kubecostProductConfigs.currencyCode`

Be sure to verify your billing information with Microsoft and update the above helm values to reflect your bill to country, subscription offer durable id/number, and currency.

The following Microsoft documents are a helpful reference:

* [Microsoft Azure Offer Details](https://azure.microsoft.com/en-us/support/legal/offer-details/)
* [Azure Pricing FAQ](https://azure.microsoft.com/en-us/pricing/faq/)
* [Geographic availability and currency support for the commercial marketplace](https://docs.microsoft.com/en-us/azure/marketplace/marketplace-geo-availability-currencies)
* [Azure Portal > Cost Management + Billing > Billing Account Properties](https://portal.azure.com/#view/Microsoft_Azure_GTM/ModernBillingMenuBlade/~/Properties)
* [Understand Cost Management data](https://docs.microsoft.com/en-us/azure/cost-management-billing/costs/understand-cost-mgt-data)

## Supplying Azure Service Principal Details to Kubecost

### Via a Kubernetes secret (Recommended)

Create a file called [`service-key.json`](https://github.com/kubecost/poc-common-configurations/blob/main/azure/service-key.json) and update it with the Service Principal details from the above steps:

```json
{
    "subscriptionId": "<Azure Subscription ID>",
    "serviceKey": {
        "appId": "<Azure AD App ID>",
        "password": "<Azure AD Client Secret>",
        "tenant": "<Azure AD Tenant ID>"
    }
}
```

Next, create a secret for the Azure Service Principal

> Note: When managing the service account key as a Kubernetes secret, the secret must reference the service account key json file, and that file must be named `service-key.json`.

```shell
kubectl create secret generic azure-service-key -n kubecost --from-file=service-key.json
```

Finally, set the `kubecostProductConfigs.serviceKeySecretName` helm value to the name of the Kubernetes secret you created. We use the value `azure-service-key` in our examples.

### Via Helm Values

In the [Helm values file](https://github.com/kubecost/cost-analyzer-helm-chart/blob/4eaaa9acef33468dd0d9fac046defe0af17811b4/cost-analyzer/values.yaml#L770-L776):

```yaml
kubecostProductConfigs:
  azureSubscriptionID: <Azure Subscription ID>
  azureClientID: <Azure AD App ID>
  azureTenantID: <Azure AD Tenant ID>
  azureClientPassword: <Azure AD Client Secret>
  azureOfferDurableID: MS-AZR-0003P
  azureBillingRegion: US
  currencyCode: USD
  createServiceKeySecret: true
```

Or at the command line:

```shell
helm upgrade --install kubecost kubecost/cost-analyzer -n kubecost \
  --set kubecostProductConfigs.azureSubscriptionID=<Azure Subscription ID> \
  --set kubecostProductConfigs.azureClientID=<Azure AD App ID> \
  --set kubecostProductConfigs.azureTenantID=<Azure AD Tenant ID> \
  --set kubecostProductConfigs.azureClientPassword=<Azure AD Client Secret> \
  --set kubecostProductConfigs.azureOfferDurableID=MS-AZR-0003P \
  --set kubecostProductConfigs.azureBillingRegion=US
  --set kubecostProductConfigs.currencyCode=USD
  --set kubecostProductConfigs.createServiceKeySecret=true
```

## Additional Help

Please let us know if you run into any issues, we are here to help.

[Slack community](https://join.slack.com/t/kubecost/shared_invite/zt-1dz4a0bb4-InvSsHr9SQsT_D5PBle2rw) - check out the `#support` channel for any help you may need & drop your introduction in the `#general` channel

Email: <team@kubecost.com>

Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/azure-config.md)

<!--- {"article":"4407595934871","section":"4402815682455","permissiongroup":"1500001277122"} --->
