# Spot Commander

Spot Commander is a Savings feature which identifies workloads where it is available and cost-effective to switch to Spot nodes, resizing the cluster in the process. Spot-readiness is determined through a [checklist](spot-checklist.md) which analyzes the workload and assesses the minimal cost required. It also generates CLI commands to help you implement the recommendation.

## Spot Cluster Sizing Recommendation

The recommended Spot cluster configuration uses all of the data available to Kubecost to compute a "resizing" of your cluster's nodes into a set of on-demand (standard) nodes `O` and a set of spot (preemptible) nodes `S`. This configuration is produced from applying a scheduling heuristic to the usage data for all of your workloads. This recommendation offers a more accurate picture of the savings possible from implementing spot nodes because nodes are what the cost of a cluster is made up of; once `O` and `S` have been determined, the savings are the current cost of your nodes minus the estimated cost of `O` and `S`.

### Implementing the recommended configuration

The recommended configuration assumes that all workloads considered spot-ready by the [Spot Checklist](spot-checklist.md) will be schedulable on spot nodes and that workloads considered not spot-ready will only be schedulable on on-demand nodes. Kubernetes has [taints and tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) for achieving this behavior. Cloud providers usually have guides for using spot nodes with taints and tolerations in your managed cluster:

* [AWS (EKS)](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html#managed-node-group-capacity-types)&#x20;
* [GCP (GKE)](https://cloud.google.com/kubernetes-engine/docs/how-to/preemptible-vms)
* [Azure (AKS)](https://docs.microsoft.com/en-us/azure/aks/spot-node-pool)&#x20;

Different cloud providers have different guarantees on shutdown windows and automatic draining of spot nodes that are about to be removed. Consult your provider’s documentation before introducing spot nodes to your cluster.

Kubecost marking a workload as spot ready is not a guarantee. A domain expert should always carefully consider the workload before approving it to run on spot nodes.

### How the recommended cluster configuration is determined

Determining `O` and `S` is achieved by first partitioning all workloads on the cluster (based on the results of the Checklist) into sets: spot-ready workloads `R` and non-spot-ready workloads `N`. Kubecost consults its maximum resource usage data (in each Allocation, Kubecost records the MAXIMUM CPU and RAM used in the window) and determines the following for each of `R` and `N`:

* The maximum CPU used by any workload
* The maximum RAM used by any workload
* The total CPU (sum of all individual maximums) required by non-DaemonSet workloads
* The total RAM (sum of all individual maximums) required by non-DaemonSet workloads
* The total CPU (sum of all individual maximums) required by DaemonSet workloads
* The total RAM (sum of all individual maximums) required by DaemonSet workloads

Kubecost uses this data with a configurable target utilization (e.g., 90%) for `R` and `N` to create `O` and `S`:

* Every node in `O` and `S` must reserve `100% - target utilization` (e.g., `100% - 90% = 10%`) of its CPU and RAM
* Every node in `O` must be able to schedule the DaemonSet requirements in `R` and `N`
* Every node in `S` must be able to schedule the DaemonSet requirements in `R`
* With the remaining resources:
* The largest CPU requirement in `N` must be schedulable on a node in `O`
* The largest RAM requirement in `N` must be schedulable on a node in `O`
* The largest CPU requirement in `R` must be schedulable on a node in `S`
* The largest RAM requirement in `R` must be schedulable on a node in `S`
* The total CPU requirements of `N` must be satisfiable by the total CPU available in `O`
* The total RAM requirements of `N` must be satisfiable by the total RAM available in `O`
* The total CPU requirements of `R` must be satisfiable by the total CPU available in `S`
* The total RAM requirements of `R` must be satisfiable by the total RAM available in `S`

### Usage tips

It is recommended to set the target utilization at or below 95% to allow resources for the operating system and the kubelet.

The configuration currently only recommends one node type for `O` and one node type for `S` but we are considering adding multiple node type support. If your cluster requires specific node types for certain workloads, consider using Kubecost's recommendation as a launching point for a cluster configuration that supports your specific needs.
