# Collections

The Collections page allows users to create groups of external cloud costs and Kubernetes objects in order to receive a unified view of all cloud spending. This is to leverage existing tags applied to cloud resources, without needing to rename them to match Kubernetes names. Collections will also avoid duplicate costs.

![Collections](/images/collections.png)

Kubernetes costs, also referred to as in-cluster costs, refer to spending on resources including nodes, disks, and network costs. They are monitored via the Assets dashboard.
Cloud costs, also referred to as out-of-cluster or external costs, refer to spending on third party services such as services offered by cloud service providers. They are monitored via the Cloud Cost Explorer.

## Creating a new collection

To begin, select _Add a new Collection_ in the top right. If you have not created any collections yet, you should see a _Add a Collection_ icon in the middle of your screen. You can select this instead. The ‘New Collection’ page opens.
The headline for your page should be an auto-generated title. This will be the name of your collection, which you can change by selecting the pencil icon. You can provide a name and also a kind for your collection. Kind is a custom label you can add to multiple collections to allow for filtering of that label, if multiple collections are intended for the same team or function. Name and kind can always be edited later.

Once you are satisfied with the name of your collection, you can add Kubernetes and cloud costs.

![New Collection](/images/newcollection.png)

All Kubernetes and cloud spend sources will appear on this page under one of two columns: Costs in Collection, or Costs Not in Collection. When first creating your collection, there should be no costs already added. Therefore, you should select _Costs Not in Collection_ to view a list of all available cost sources, or select _Explore Costs_.

Costs are then divided into two categories: _Kubernetes_ and _Cloud_ (see above for an explanation of these costs). You can toggle between the two groups using the Domain dropdown on the left of the page. For each group, you will see a total cost value displayed on the right of the page, above your cost table.

Costs are organized in a table, listed in descending order starting with the highest values. To add an individual item, hover your cursor over the item until you see a green _Add_ button visible on the right of the page. Select _Add_ to include that cost into your collection. You can add all your Kubernetes or cloud costs into a collection by selecting _Add All_, displayed next to your total cost. Once an item has been added to the collection, changes will be automatically saved.

You can filter and recategorize your cost table using _Aggregate By_ and _Add Filters_. _Aggregate By_ allows you to organize your costs by a listed category, and supports single and multi-aggregation. _Add Filters_ allows for flexible filtering of your table items, including filtering by custom labels.

After having added items to your collection, selecting _Costs in Collection_ will provide a complete list of all items, as well as key cost metrics including total and percentage costs of both Kubernetes and cloud items. 

## Managing collections

The Collections page will list all existing collections with a chart displaying cost over time and total cost. You can begin editing a collection by selecting it. Selecting the three vertical dots in the top right of the collection tile will allow you to delete it. You can also adjust your Collections display by adjusting the window of time, aggregating by item or kind, or filtering.