Kubernetes Assets
======

The Kubecost Assets view shows Kubernetes cluster costs broken down by the individual backing assets in your cluster (e.g. cost by node, disk, and other assets). 
It’s used to identify spend drivers over time and to audit Allocation data. This view can also optionally show out-of-cluster assets by service, tag/label, etc.

> **Note**: Similar to our Allocation API, the Assets API uses our ETL pipeline which aggregates data daily. This allows for enterprise-scale with much higher performance.

![Kubecost Assets view](https://raw.githubusercontent.com/kubecost/docs/main/images/assets.PNG.png)

This user interface is available at `<your-kubecost-address>/assets.html`.

This is the main Kubecost Assets dashboard. In the screenshot there are multiple features to take notice of which are covered in this guide:

1. *Date Range* filter
2. *Aggregate by* filter
3. *Edit search parameters* icon
4. Additional dashboard icons
5. Assets metrics table

## 1. Date Range filter
![Date Range](https://raw.githubusercontent.com/kubecost/docs/main/images/assetsdate.PNG)

Select the date range of the report by setting specific start and end dates, or using one of the preset options.

## 2. Aggregate filter
![Aggregate by](https://raw.githubusercontent.com/kubecost/docs/main/images/assetsaggregateby.PNG)

Here you can aggregate cost by native Kubernetes concepts. While selecting Single Aggregation, you will only be able to select one concept at a time. While selecting Multi Aggregation, you will be able to filter for multiple concepts at the same time. Assets will be by default aggregated by Service.

## 3. Edit search parameters icon
![Edit search parameters](https://raw.githubusercontent.com/kubecost/docs/main/images/assetsfilter.PNG)

The Edit report icon has additional options to filter your search.

### Resolution
Change the display of your recent assets by service. *Daily* provides a day-by-day breakdown of assets. *Entire window* creates a semicircle that shows each asset as a sizable portion based on total cost within the displayed time frame.

### Cost metric
View either cumulative or run rate costs measured over the selected time window based on the assets being filtered for.

* Cumulative Cost: represents the actual/historical spend captured by the Kubecost agent over the selected time window
* Rate metrics: Monthly, daily, or hourly “run rate” cost, also used for projected cost figures, based on samples in the selected time window

### Filters
Filter assets by category, service, or other means. When a filter is applied, only resources with this matching value will be shown.

## 4. Additional dashboard icons
![Additional dashboard icons](https://raw.githubusercontent.com/kubecost/docs/main/images/assetsicons.PNG)

Directly next to the *Edit search parameters* icon are several additional icons for configuring reports:

* Save/unsave report icon: Save or unsave your current report
* Open saved report icon: Open a report that was previously saved using the Save report icon
* Download CSV icon: Download your current report as a CSV file

## 5. Assets metrics table
The assets metrics table displays your aggregate assets, with four columns to organize by.

* Name: Name of the aggregate group
* Credits: Amount deducted from total cost due to provider-applied credit. A negative number means the total cost was reduced.
* Adjusted: Amount added to total cost based on reconciliation with cloud provider’s billing data.
* Total cost: Shows the total cost of the aggregate asset factoring in additions or subtractions from the Credits and Adjusted columns.

Hovering over the gray info icon next to each asset will provide you with the hours run and hourly cost of the asset. To the left of each asset name is one of several Category icons (you can aggregate by these): Storage, Network, Compute, Management, and Other.

Gray bubble text may appear next to an asset. These are all manually-assigned labels to an asset. To filter assets for a particular label, select the *Edit search parameters* icon, then select *Label/Tag* from the Filters dropdown and enter the complete name of the label.

You can select an aggregate asset to view all individual assets comprising it. Each individual asset should have a ProviderID.

## Cloud cost reconciliation

After granting Kubecost permission to access cloud billing data, Kubecost adjusts its asset prices once cloud billing data becomes available, e.g. AWS Cost and Usage Report and the spot data feed. Until this data is available from cloud providers, Kubecost uses data from public cloud APIs to determine cost, or alternatively custom pricing sheets. This allows teams to have highly accurate estimates of asset prices in real-time and then become even more precise once cloud billing data becomes available, which is often 1-2 hours for spot nodes and up to a day for reserved instances/savings plans. 

Note that while cloud adjustments typically lag by roughly a day, there are certain adjustments, e.g. credits, that may continue to come in over the course of the month, and in some cases at the very end of the month, so reconciliation adjustments may continue to update over time.




<!--- {"article":"4407595924247","section":"4402829033367","permissiongroup":"1500001277122"} --->
