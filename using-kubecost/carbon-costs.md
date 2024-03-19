# Carbon Costs

Carbon Costs is a cost metric added to both [Allocation](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/README.md) and [Assets](/using-kubecost/navigating-the-kubecost-ui/assets.md) dashboards. Carbon Costs are measured in KG CO2e, which is defined by the EPA as:

> Carbon dioxide equivalent or CO2e means the number of metric tons of CO2 emissions with the same global warming potential as one metric ton of another greenhouse gas, and is calculated using Equation A-1 in 40 CFR Part 98.

For more information on how carbon costs are calculated, visit the [Cloud Carbon Footprint](https://www.cloudcarbonfootprint.org/) website.

![Carbon Costs column](/images/carboncosts.png)

## Enabling Carbon Costs

To begin viewing carbon costs, set the Helm flag `carbonEstimates` to `true`:

```
helm install kubecost cost-analyzer \
   --repo https://kubecost.github.io/cost-analyzer/ \
   --namespace kubecost --create-namespace \
   --set kubecostProductConfigs.carbonEstimates.enabled=true
```

Carbon costs will then begin appearing with other cost metrics on your Allocation and Assets pages.
