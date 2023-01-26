# Spot Checklist

The Spot Readiness Checklist investigates your Kubernetes workloads to attempt to identify those that are candidates to be schedulable on spot (preemptible) nodes. Spot nodes are deeply-discounted nodes (up to 90% cheaper) from your cloud provider that do not come with an availability guarantee. They can disappear at any time, though most cloud providers guarantee some sort of alert and a small shutdown window, on the order of tens of seconds to minutes, before the node disappears. Spot-ready workloads, therefore, are workloads that can tolerate some level of instability in the nodes they run on. Examples of spot-ready workloads are usually state-free: many microservices, Spark/Hadoop nodes, etc.

The Spot Readiness Checklist performs a series of checks that use your own workload configuration to determine readiness:

* Controller Type (Deployment, StatefulSet, etc.)
* Replica count
* Local storage
* Controller Pod Disruption Budget
* Rolling update strategy (Deployment-only)
* Manual annotation overrides

## How to interpret Checklist results

### Controller Type

The checklist is configured to investigate a fixed set of controllers, currently only Deployments and StatefulSets. More to come!

Deployments are considered spot-ready because they are relatively stateless, intended to only ensure a certain number of pods are running at a given time.

StatefulSets should generally be considered not spot ready; they, as their name implies, usually represent stateful workloads that require the guarantees that StatefulSets. Scheduling StatefulSet pods on spot nodes can lead to data loss.

### Replica count

Workloads with a configured replica count of 1 are not considered spot-ready because if the single replica is removed from the cluster due to a spot node outage, the workload goes down. Replica counts greater than 1 signify a level of spot-readiness because workloads that can be replicated tend to also support a variable number of replicas that can occur as a result of replicas disappearing due to spot node outages.

### Local storage

Currently, workloads are only checked for the presence of an `emptyDir` volume. If one is present, the workload is assumed to be not spot-ready.

More generally, the presence of a writable volume implies a lack of spot readiness. If a pod is shut down non-gracefully while it is in the middle of a write, data integrity could be compromised. More robust volume checks are currently under consideration.

### Pod Disruption Budget

It is possible to configure a [Pod Disruption Budget (PDB)](https://kubernetes.io/docs/tasks/run-application/configure-pdb/) for controllers that causes the scheduler to (where possible) adhere to certain availability requirements for the controller. If a controller has a PDB set up, we read it and compute its minimum available replicas and use a simple threshold on the ratio `min available / replicas` to determine if the PDB indicates readiness. We chose to interpret a ratio of > 0.5 to indicate a lack of readiness because it implies a reasonably high availability requirement.

If you are considering this check while evaluating your workloads for spot-readiness, do not immediately discount them because of this check failing. Workloads should always be evaluated on a case-by-case basis and it is possible that an unnecessarily strict PDB was configured.

### (Deployment only) Rolling update strategy

Deployments have multiple options for update strategies and by default they are configured with a Rolling Update Strategy (RUS) with 25% max unavailable. If a deployment has an RUS configured, we do a similar min available (calculated from max unavailable in rounded-down integer form and replica count) calculation as with PDBs, but threshold it at 0.9 instead of 0.5. Doing so ensures that default-configured deployments with replica counts greater than 3 will pass the check.

### Manual annotation overrides

We also support manually overriding the spot readiness of a controller by annotating the controller itself or the namespace it is running in with `spot.kubecost.com/spot-ready=true`.

## Implementing spot nodes in your cluster

The Checklist is now deployed alongside a [recommended cluster configuration](/spot-cluster-sizing.md) which automatically suggests a set of spot and on-demand nodes to use in your cluster based on the Checklist. If you do not want to use that, read the following for some important information:

Kubecost marking a workload as spot ready is not a guarantee. A domain expert should always carefully consider the workload before approving it to run on spot nodes.

Most cloud providers support a mix of spot and non-spot nodes in the cluster and they have guides:

* [AWS (EKS)](https://docs.aws.amazon.com/eks/latest/userguide/managed-node-groups.html#managed-node-group-capacity-types)
* [GCP (GKE)](https://cloud.google.com/kubernetes-engine/docs/how-to/preemptible-vms)
* [Azure (AKS)](https://docs.microsoft.com/en-us/azure/aks/spot-node-pool)

Different cloud providers have different guarantees on shutdown windows and automatic draining of spot nodes that are about to be removed. Consult your provider’s documentation before introducing spot nodes to your cluster.

It is a good idea to use [taints and tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) to schedule only spot-ready workloads on spot nodes.

Additionally, it is generally wise to use smaller size spot nodes. This minimizes the scheduling impact of individual spot nodes being reclaimed by your cloud provider. Consider one spot node of 20 CPU cores and 120 GB RAM against 5 spot nodes of 4 CPU and 24 GB. In the first case, that single node being reclaimed could force tens of pods to be rescheduled, potentially causing scheduling problems, especially if capacity is low and spinning up a new node takes too long. In the second case, fewer pods are forced to be rescheduled if a reclaim event occurs, thus lowering the likelihood of scheduling problems.
