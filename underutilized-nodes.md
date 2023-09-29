# Underutilized Nodes

Kubecost displays all nodes with both low CPU/RAM utilization, indicating they may need to be turned down or resized, while providing checks to ensure safe drainage can be performed.

You can access the Underutilized Nodes page by selecting *Savings* in the left navigation, then selecting *Manage underutilized nodes*.

![Underutilized Nodes](/images/underutilizednodes.png)

## Configuring maximum utilization

To receive accurate recommendations, you should set the maximum utilization percentage for CPU/RAM for your cluster. This is so Kubecost can determine if your environment can perform successfully below the selected utilization once a node has been drained. This is visualized by the Maximum CPU/RAM Request Utilization slider bar. In the Profile dropdown, you can select three preset values, or a custom option:

* *Development*: Sets the utilization to 80%.
* *Production*: Sets the utilization to 65%.
* *High Availability*: Sets the utilization to 50%.
* *Custom*: Allows you to manually move the slider.

## Node and pod checks

Kubecost provides recommendations by performing a Node Check and a Pod Check to determine if a node can be drained without creating problems for your environment. For example, if draining the node would put the cluster above the utilization request threshold, the Node Check will fail. Only a node that passes both Checks will be recommended for safe drainage. For nodes that fail at least one Check, selecting the node will provide a window of potential pod issues.

Kubecost does not directly assist in turning nodes down.
