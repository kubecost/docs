Once you've installed kubecost in an azure account, to access accurate Microsoft Azure billing data, Kubecost needs access to the Billing Rate Card API.

Start by creating an Azure role definition. Below is an example definition, replace YOUR_SUBSCRIPTION_ID with the Subscription ID of your account:

```
{
 “Name”: “MyRateCardRole”,
 “IsCustom”: true,
 “Description”: “Rate Card query role”,
 “Actions”: [
 “Microsoft.Compute/virtualMachines/vmSizes/read”,
 “Microsoft.Resources/subscriptions/locations/read”,
 “Microsoft.Resources/providers/read”,
 “Microsoft.ContainerService/containerServices/read”,
 “Microsoft.Commerce/RateCard/read”
 ],
 “AssignableScopes”: [
 “/subscriptions/YOUR_SUBSCRIPTION_ID”
 ]
}
```

Save this into a file called myrole.json

Next, you'll want to register that role with Azure:

`az role definition create --verbose --role-definition @myrole.json`

Next, create an Azure Service Principle.

`az ad sp create-for-rbac --name "MyServicePrincipal" --role "MyRateCardRole" --sdk-auth true > my_credentials.json`

`my_credentials.json` will contain the relevant configuration information. You can either supply this information in /settings.html (see below) or in helm under (.Values.kubecostProductConfigs)[https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.70.0/cost-analyzer/values.yaml#L547]

<img width="1792" alt="Screen Shot 2020-12-07 at 12 32 24 PM" src="https://user-images.githubusercontent.com/453512/101402781-12156880-3889-11eb-86ca-55111d36fe14.png">

