# Continuous Cluster Right-Sizing

Kubecost can implement continuous cluster right-sizing to automatically maintain efficient size of your clusters.

## How it works

Continuous Cluster Right-Sizing is configured in the UI, where the schedule is stored in a ConfigMap in your cluster. At the scheduled time, the [Cluster Controller](https://docs.kubecost.com/install-and-configure/advanced-configuration/controller) will initiate a cluster right-sizing operation by retrieving Kubecost's cluster right-sizing recommendation based on the provided configuration. Kubecost will continue implementing right-sizing at the user-scheduled interval.

## Prerequisites

Continuous cluster right-sizing requires the same prerequisites as adopting cluster right-sizing recommendations. Follow the [Cluster Right-Sizing](https://docs.kubecost.com/using-kubecost/navigating-the-kubecost-ui/savings/cluster-right-sizing-recommendations#prerequisites) guide.

## Usage

Continuous Cluster Right-Sizing is accessible via [Actions](https://docs.kubecost.com/using-kubecost/navigating-the-kubecost-ui/savings/savings-actions), then select Guided Sizing. This feature implements both container request right-sizing and cluster right-sizing.

For a tutorial on using Guided Sizing, see here.

## Troubleshooting

### EBS-related scheduling challenges on EKS

If you are using Persistent Volumes (PVs) with AWS's Elastic Block Store (EBS) Container Storage Interface (CSI), you may run into a problem post-resize where pods are in a Pending state because of a "volume node affinity conflict". This may be because the pod needs to mount an already-created PV which is in an Availability Zone (AZ) without node capacity for the pod. This is a limitation of the EBS CSI.

Kubecost mitigates this problem by ensuring continuous cluster right-sizing creates at least one node per AZ by forcing NodeGroups to have a node count greater than or equal to the number of AZs of the EKS cluster. This will also prevent you from setting a minimum node count for your recommendation below the number of AZs for your cluster. If the EBS CSI continues to be problematic, you can consider switching your CSI to services like Elastic File System (EFS) or FSx for Lustre.

Using Cluster Autoscaler on AWS may result in a similar error. See more [here](https://github.com/kubernetes/autoscaler/blob/master/cluster-autoscaler/cloudprovider/aws/README.md#common-notes-and-gotchas).
