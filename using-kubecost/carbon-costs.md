# Carbon Costs

Carbon Costs is a cost metric added to both [Allocation](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/README.md) and [Assets](/using-kubecost/navigating-the-kubecost-ui/assets.md) dashboards. Carbon Costs are measured in KG CO2e (metric tons carbon dioxide emission with the same global warming potential as one metric ton of another greenhouse gas, and is calculated using Equation A-1 in 40 CFR Part 98).

![Carbon Costs column](/images/carboncosts.png)

## Enabling Carbon Costs

To begin viewing carbon costs, set the Helm flag `carbonEstimates` to `true`:

```
helm install kubecost cost-analyzer \
   --repo https://kubecost.github.io/cost-analyzer/ \
   --namespace kubecost --create-namespace \
   --set kubecostProductConfigs.carbonEstimates.enabled=true
```
