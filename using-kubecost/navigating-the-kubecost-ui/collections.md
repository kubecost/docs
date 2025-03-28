# Collections

The Collections page allows users to create groups of external cloud costs and Kubernetes objects in order to receive a unified view of all cloud spending. This is to leverage existing tags applied to cloud resources, without needing to rename them to match Kubernetes names. Collections will also avoid duplicate costs.

![Collections](/images/collections.png)

Kubernetes costs, also referred to as in-cluster costs, refer to spending on resources including nodes, disks, and network costs. They are monitored via the Assets dashboard.
Cloud costs, also referred to as out-of-cluster or external costs, refer to spending on third party services such as services offered by cloud service providers. They are monitored via the Cloud Cost Explorer.

## Creating a new collection

To begin, select _Add a new Collection_ in the top right. If you have not created any collections yet, you should see a _Add a Collection_ icon in the middle of your screen. You can select this instead. The ‘New Collection’ page opens.
The headline for your page should be an auto-generated title. This will be the name of your collection, which you can change by selecting the pencil icon. You can provide a name and a category for your collection. Categories are custom labels you can add to multiple collections to allow for filtering of that category, if multiple collections are intended for the same team or function. A collection can have at most one category. Name and category can always be edited later.

Once you are satisfied with the name of your collection, you can add Kubernetes and cloud costs.

![New Collection](/images/newcollection.png)

All Kubernetes and cloud spend sources will appear on this page under one of two columns: Costs in Collection, or Costs Not in Collection. When first creating your collection, there should be no costs already added. Therefore, you should select _Costs Not in Collection_ to view a list of all available cost sources, or select _Explore Costs_.

Costs are then divided into two categories: _Kubernetes_ and _Cloud_ (see above for an explanation of these costs). You can toggle between the two groups using the Domain dropdown on the left of the page. For each group, you will see a total cost value displayed on the right of the page, above your cost table.

Costs are organized in a table, listed in descending order starting with the highest values. To add an individual item, hover your cursor over the item until you see a green _Add_ button visible on the right of the page. Select _Add_ to include that cost into your collection. You can add all your listed Kubernetes or cloud costs into a collection by selecting _Add All_, displayed next to your total cost. This is only available once you've added at least one filter. Once an item has been added to the collection, changes will be automatically saved.

You can filter and recategorize your cost table using _Aggregate By_ and _Add Filters_. _Aggregate By_ allows you to organize your costs by a listed category, and supports single and multi-aggregation. _Add Filters_ allows for flexible filtering of your table items, including filtering by custom labels.

After having added items to your collection, selecting _Costs in Collection_ will provide a complete list of all items, as well as key cost metrics including total and percentage costs of both Kubernetes and cloud items.

{% hint style="info" %}
Your cloud provider may not provide a Resource ID for all cloud 'items'. Cloud costs without an associated resource ID are not supported currently.
{% endhint %}

{% hint style="info" %}
Percentage spends refers to the total Kubernetes/Cloud cost within the collection to all Kubernetes/Cloud costs within your environment respectively, not the percentage of total spend within the collection. For example, if a collection contains $20 of Kubernetes spend and the total allocation data in that same window is $50, the percentage of Kubernetes spend will be 40%.
{% endhint %}

In the event there is cost overlap from conflicting Kubernetes and cloud costs, they will be reflected in a special Overlap category. Kubecost automatically subtracts the overlapping costs so that the totals seen for the collection are accurate and do not contain duplicate costs. Currently, overlap is not considered for shared costs and Load Balancer costs coming from workloads running on Azure and GCP clusters.

## Managing collections

The Collections page will list all existing collections with a chart displaying cost over time and total cost. You can begin editing a collection by selecting it. You can also adjust your Collections display by adjusting the window of time, aggregating by item or kind, or filtering.

Selecting the three horizontal dots in the top right of the collection tile will provide you with additional options:

* *Delete*
* *Export as CSV*
* *Export as PDF*

## Viewing idle costs

Costs in the Kubernetes domain have a corresponding idle component. For any Kubernetes costs part of a Collection, the idle cost can be optionally configured to be _included_ in the total cost displayed. The idle cost can be shared by cluster or by node. This can be configured on the Settings page under Idle in Collections. By default, idle costs are hidden. 

If enabled, the 'Idle' column on the _Costs in Collection_ view will display the corresponding idle cost under each item.

To learn more about sharing idle costs, see [here](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/efficiency-idle.md#sharing-idle).

# Categories and Chargeback

Starting in v2.7, the Category view can be used for chargeback reporting. Each collection in the category will be represented as a chargeback line item.

<!--- (image_1) Category view for the Owner category, with three collections: Engineering, Finance and Operations --->

The new costs table will display the following columns: 
- Cost: "Complete" collection cost independent of the Category, prior to any overlap deductions
- Overlap: deduction applied to the collection line item in the case when (part of) its cost has already been accounted for in another collection within the same category. See Allocating overlap in collections for more information
- Shared Cost: Total shared cost attributable to collection
- Chargeback cost: Final chargeback cost for collection

## Cost sharing

You can share the costs of one or more existing collections across a category. The costs of the shared collections will be distributed across all the collections in the category. 

<!--- (image_2) Shared collections table --->

Start typing a collection name in the 'Find a collection' textbox. The dropdown will be populated with collections as you type. 

<!--- (image_3) Shared collections table: Adding a shared collection --->

The costs can be shared in one of two strategies:
- Weighted: costs are distributed proportionally based on the collection's (original) cost
- Even: costs are distributed in equal proportions for each collection in the category

<!--- (image_4) Shared collections table: Sharing Strategy options --->

The shared cost attributable to each collection in the category will be added to the collection cost (after any overlap deductions are applied) to render the final Chargeback cost for the collection.

<!--- (image_5) Costs table with shared collection costs applied --->

You can add, modify or remove collections from the list of shared collections by clicking _Edit_ in the upper right corner.

## Allocating overlap in collections

Given their configuration, there may exist overlap between the collections in the same category. For example, if the Engineering collection covers the costs where the label "team" has value "engineering" and the Finance collection covers the costs for namespace "application", overlap would be represented by the cost of all resources in namespace "application" that are _also_ tagged with label "team":"engineering". 
Chargeback costs are calculated for each collection within the context of the category. If there is overlap between collections, the overlapping costs are allocated in order of priority, where the collection with superior priority maintains its full cost, while the one with inferior priority will have a deduction in the Overlap column.   
The collections are prioritized in line with the order they appear in on the costs table. By default, collections are prioritized by their Cost (most expensive collections are first). Collections can also be prioritized in alphabetical order by modifying the setting in the dropdown to "Order by Name".

<!--- (image_6) Collection priority dropdown --->

If any shared collections are set, their costs are automatically prioritized respective to the collections that are part of the Category. If there is overlap between the shared collections themselves, it will be handled in the same manner as described above. The priority can be modified by reordering the shared collections using the arrows on the right side of each line item. 

<!--- (image_7) Reorder shared collections by priority --->

## Managing categories

The Category page will list all the collections in the category with a chart displaying cost over time and total cost. You can begin editing a collection by selecting it. You can also adjust your Category display by adjusting the window of time.

Selecting the three horizontal dots next to the priority dropdown will provide you with additional options:

* *Export as CSV*
* *Export as PDF*

