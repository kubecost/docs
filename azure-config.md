Once you've installed Kubecost in an azure account, to access accurate Microsoft Azure billing data, Kubecost needs access to the Billing Rate Card API.

> Note: you can also get this functionality plus external costs by completing the full [Kubecost Azure integration](/azure-out-of-cluster.md).

Start by creating an Azure role definition. Below is an example definition, replace YOUR_SUBSCRIPTION_ID with the Subscription ID of your account:

```
{
    "Name": "MyRateCardRole",
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

Save this into a file called myrole.json

Next, you'll want to register that role with Azure:

```
az role definition create --verbose --role-definition @myrole.json
```

Next, create an Azure Service Principle.

```
az ad sp create-for-rbac --name "MyServicePrincipal" --role "MyRateCardRole" --sdk-auth true > my_credentials.json
```

The newly created `my_credentials.json` file will contain the relevant configuration information. You can either supply this information in <your-kubecost-endpoint>/settings.html (screenshot below) or in helm values under [kubecostProductConfigs](https://github.com/kubecost/cost-analyzer-helm-chart/blob/b9b24ee7f957d81b3c87937026e7e8889b293764/cost-analyzer/values.yaml#L547-L551) :
 ```
helm install kubecost ./cost-analyzer -n kubecost --set kubecostProductConfigs.azureClientID=<> --set kubecostProductConfigs.azureTenantID=<> --set kubecostProductConfigs.azureClientPassword=<> --set .kubecostProductConfigs.createServiceKeySecret=true
```

<img width="1792" alt="Screen Shot 2020-12-07 at 12 32 24 PM" src="https://user-images.githubusercontent.com/453512/101402781-12156880-3889-11eb-86ca-55111d36fe14.png">

