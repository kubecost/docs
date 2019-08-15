To access accurate Microsoft Azure billing data, Kubecost needs access to the Billing Rate Card API.

Start by creating an Azure role definition. Below is an example defition, replace YOUR_SUBSCRIPTION_ID with the Subscription ID of your account:

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
