# Advanced Networking

{% hint style="info" %}
Advanced Networking is only officially supported on Kubecost Enterprise plans.
{% endhint %}

Advanced Networking is a monitoring page which helps visualize your [network costs](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/network-allocation.md). You will be able to analyze network costs by their connection to your pods, namespaces, or clusters. This may be beneficial for larger teams or teams with complex environments hoping to better understand their network costs.

The Advanced Networking page is a web of draggable icons which represent your network cost sources, as well as all pods/namespaces/clusters connected to them. Green-border icons represent network costs, while blue-border icons represent your Kubernetes objects that are driving spending. Arrows connecting icons together are colored to represent internal and external spend. Icons are equally-sized; they are not proportionate to spend values.

![Advanced Networking](/images/networking.png)

## Getting started

Before accessing Advanced Networking, make sure you've [enabled the network costs daemonset](/install-and-configure/advanced-configuration/network-costs-configuration.md#enabling-network-costs) for accurate cost metrics.

## Adjusting your display

For a summary of your network costs, select *View details*, which will open a tab containing key metrics including internal and external spend, ingress and egress size per node, number of nodes, and total cost.

Adjustable dropdowns will also affect your display. You can sample costs in a window of time as short as 3 hours, and as long as 1 day ago. Another dropdown allows you to choose network costs from *pod*, *namespace*, or *cluster* values.

Selecting an individual icon will display a window containing cost metrics relating to the service or object the icon represents. Selecting the green arrow icon in this window will reorient your display to only show the selected service/object, as well as all services/objects connected to it. It will also display additional key metrics including a scrollable table of all connected entities and their costs (this can also be opened by selecting *View Details* at the bottom of your page). You can continue performing this process on any icons still displayed, until only a single service and object remain, at which point the UI will not display new icons. You can undo this display by selecting *To Overview*.

You can zoom in and out of your Advanced Networking display using the scroll wheel. Selecting *Legend* in the bottom right will open a legend which identifies the significance of colored icons and lines.
