# GPU Optimization

The GPU optimization page, a Kubecost Enterprise feature, shows you details on your workloads (containers and their relatives) which are using GPUs and proactively identifies ways in which you can save money on them. Kubecost collects and processes [GPU utilization metrics](/install-and-configure/advanced-configuration/gpu.md) to power the contents of this page. The page is broken down into two main sections: a workload utilization table and recommendation cards.

{% hint style="info" %}
If the GPU Optimization savings card appears to be greyed out, click the meatballs menu in the upper right and select "Unarchive".
{% endhint %}

![GPU Optimization dashboard](/images/gpu-savings-optimize-dashboard.png)

## Utilization Table

The utilization table displays the GPU-related workloads in your Kubecost environment and provides many details which can be helpful to understand what is going on. Unlike other pages in Kubecost which display all workloads, the utilization table on this page is constrained to only workloads which are requesting some amount of GPU. It is not an extraction of the Allocation page, for example. Aggregations which do not feature a GPU in some way will be intentionally absent from this table. For example, your Kubecost estate has three (3) clusters but only one (1) of them has GPUs. Only the cluster with GPUs will display content on this table.

Depending on the aggregation, there will be information presented specific to that aggregation that may not be found on others. For example, aggregating by cluster shows the the number of nodes containing at least one GPU as well as the number of containers requesting at least one GPU during the given time window. The container and pod aggregations show, among other columns, the node on which this ran or is running, whether it is using [shared GPUs](/install-and-configure/advanced-configuration/gpu.md#shared-gpu-support), and its average and max utilization of those GPUs.

A utilization threshold slider is provided at the top of this table allowing you to constrain the returned results to a value of the GPU utilization, either maximum or average, up to and inclusive of that number. This is to allow easier identification of GPU-related workloads across your estate. For example, you wish to view workloads which are using a maximum GPU utilization of up to 80%. Set the slider to 80% and Kubecost filters from view any workloads above this number.

## Recommendations

The bottom half of the page presents recommendations on where and how to save money on GPU workloads. Depending on the time window defined at the top of the page, Kubecost locates and displays one card per container where it has identified a possible savings opportunity. Each recommendation is presented as a separate card.

Kubecost provides proactive recommendations on how to save money on GPU workloads in three different categories: Optimize, Remove, and Share.

- **Optimize**: Containers which request more than one GPU but are not using at least one of those GPUs will trigger the Optimize recommendation. In this card, Kubecost shows the container which can be optimized by reconfiguring it to remove the number of unused GPUs observed during the time window selected. This can be useful, for example, in cases where the application in the container was either not written to make use of multiple GPUs or where use of multiple GPUs is not achieved due to the nature of the workload. The possible savings displayed on this tile is the cost of only the unused GPUs over the course of a month.
- **Remove**: Containers which request a single GPU but are found to not use it are flagged for removal. In this card, Kubecost shows the container which can be removed from the cluster thereby freeing up its GPU. You may see this card if, for example, a workload has been created which requests a GPU but never uses it due to a misconfiguration, or where a workload did use a GPU for a period of time but that use has ended yet the container continues to run. Whatever your case, containers which request but do not use a GPU make it such that other workloads such as pending jobs cannot be scheduled due to "GPU squatting." The possible savings displayed on this tile is the cost of removing this container entirely from the cluster over the course of a month.
- **Share**: Containers which request a single GPU but are using somewhere between zero and 100% are identified as candidates for GPU sharing. In this card, Kubecost shows the container which is not fully utilizing a GPU and can potentially request access to a shared GPU instead. GPU sharing is a technique whereby multiple containers, each which need some GPU resources, all execute concurrently on a single GPU thereby potentially reducing costs by requiring fewer total GPUs. See the section on GPU sharing [here](/install-and-configure/advanced-configuration/gpu.md#shared-gpu-support) for more details on how or if this is right for you. Because reconfiguring a workload to request access to a shared GPU is highly variable and depends on many factors, Kubecost does not show a possible savings number associated with this recommendation type. This does not mean, however, that no savings are likely to result in configuring your cluster and appropriate workloads for GPU sharing.

Clicking on each recommendation tile displays a window with further details on the recommendation designed to help you identify exactly which workload Kubecost has flagged and more information on why the recommendation was made all with the goal of helping you gain confidence in the accuracy of the recommendation. The window contains a utilization graph over the selected time window, details on the container and its location in the cluster, and an explanation with more details on the recommendation.

![GPU Optimization savings modal](/images/gpu-savings-optimize-modal.png)

## Known Limitations

In the first version of the GPU Optimization Savings Insights card there are a few known limitations.

- Multiple containers with the same name and running on the same cluster, node, and namespace combination (i.e., "identical" containers) might result in the following effects:
  - The savings number provided on Optimize and Remove cards may be an implicit sum of the total cost these containers.
  - Recommendations will only be provided for one of them.
  - The utilization table may not show these identical containers.
- GPU nodes must be running or have run at least one container utilizing a GPU for it to be represented on the utilization table in either the Cluster aggregation’s GPU nodes column or on the Node aggregation.
- The Optimize recommendation may not be as accurate as possible in certain cases since Kubecost currently infers utilization about all GPUs from a single averaged utilization number.
- For upgrades from prior versions to 2.5.0, there may be cases where Max. GPU Utilization could be a smaller percentage than Avg. GPU Utilization. This will self correct once the chosen window size is smaller than the time the 2.5.0 instance has been collecting the new max. GPU util. metric.
- The GPU Optimization card on the Savings Insights screen may initially appear greyed out. Click the meatballs icon in the upper right and choose "Unarchive" to make the card appear as the others.
