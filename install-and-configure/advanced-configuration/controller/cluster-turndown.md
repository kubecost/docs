# Cluster Turndown

Cluster turndown is an automated scale down and scaleup of a Kubernetes cluster's backing nodes based on a custom schedule and turndown criteria. This feature can be used to reduce spend during down hours and/or reduce surface area for security reasons. The most common use case is to scale non-production (prod) environments (e.g. development (dev) clusters) to zero during off hours.

## How it works

{% hint style="warning" %}
Cluster turndown is only available for clusters on GKE, EKS, or Kops-on-AWS.
{% endhint %}

<details>

<summary>Managed cluster strategy (e.g. GKE + EKS)</summary>

When the turndown schedule occurs, a new node pool with a single g1-small node is created. Taints are added to this node to only allow specific pods to be scheduled there. The `cluster-turndown` pod deployment is updated so the pod is allowed to schedule on the singleton node. Once the pod is moved to the new node, it will start back up and resume scale down. This is done by cordoning all nodes in the cluster (other than our new g1-small node), and then reducing the node pool sizes to 0.

</details>

<details>

<summary>GKE autoscaler strategy</summary>

Whenever there exists at least one NodePool with the `cluster-autoscaler` enabled, the `cluster-turndown` pod will:

1. Resize all non-autoscaling nodepools to 0
2. Schedule the turndown on one of the autoscaler nodepool nodes
3. Once it is brought back up (rescheduled to the selected node), the turndown pod will start a process called "flattening" which attempts to set deployment replicas to 0, turn off jobs, and annotate pods with labels that allow the autoscaler to do the rest of the work. Flattening persists pre-turndown values in the annotations of Kubernetes objects. The GKE autoscaler behavior is expected to handle the rest: removing now-unneeded nodes from the node pools. A limitation of this strategy is that the autoscaled node pools won't go below their configured minimum node count.
4. When turn up occurs, deployments and DaemonSets are "expanded" to their original sizes/replicas.

There are four annotations that can be applied for this process:

* `kubecost.kubernetes.io/job-suspend`: Stores a bool containing the previous paused state of a kubernetes CronJob.
* `kubecost.kubernetes.io/turn-down-replicas`: Stores the previous number of replicas set on the deployment.
* `kubecost.kubernetes.io/turn-down-rollout`: Stores the previous maxUnavailable for the deployment rollout.
* `kubecost.kubernetes.io/safe-evict`: Uses the `cluster-autoscaler.kubernetes.io/safe-to-evict` for autoscaling clusters to have the autoscaler preserve any deployments that previously had this annotation set, so scale up occurs, this value isn't unintentionally reset.

</details>

<details>

<summary>AWS Kops strategy</summary>

This turndown strategy schedules the `cluster-turndown` pod on the Master node, then resizes all Auto Scaling Groups (ASG) other than the master to 0. Similar to flattening in GKE (see above), the previous min/max/current values of the ASG prior to turndown will be set on the tag. When turn up occurs, those values can be read from the tags and restored to their original sizes. For the standard strategy, turn up will reschedule the turndown pod off the Master upon completion (occurs 5 minutes after turn up). This is to allow any modifications via Kops without resetting any cluster specific scheduling setup by turndown. The tag label used to store the min/max/current values for a node group is `cluster.turndown.previous`. Once turn up happens and the node groups are resized to their original size, the tag is deleted.

</details>

## Setup

### Prerequisites

* [kubectl](https://kubernetes.io/docs/tasks/tools/)
* Enable the [Cluster Controller](cluster-controller.md)

You will receive full turndown functionality once the Cluster Controller is enabled via a provider service key setup and Helm upgrade. Review the Cluster Controller doc linked above under Prerequisites for more information, then return here when you've [confirmed the Cluster Controller is running](https://app.gitbook.com/o/MQuX6uFwV0j7vIHtR15E/s/cjJbIkEBCZifkHo05tVh/\~/changes/230/install-and-configure/advanced-configuration/controller/cluster-turndown#setup).

### Verify the pod is running

You can verify that the `cluster-turndown` pod is running with the following command:

```bash
kubectl get pods -l app=cluster-turndown -n turndown
```

## Setting a turndown schedule

Turndown uses a Kubernetes Custom Resource Definition to create schedules. Here is an example resource located at _artifacts/example-schedule.yaml_:

```yaml
apiVersion: kubecost.com/v1alpha1
kind: TurndownSchedule
metadata:
  name: example-schedule
  finalizers:
  - "finalizer.kubecost.com"
spec:
  start: 2020-03-12T00:00:00Z
  end: 2020-03-12T12:00:00Z
  repeat: daily
```

This definition will create a schedule that starts by turning down at the designated `start` date-time and turning back up at the designated `end` date-time. Both the `start` and `end` times should be in [RFC3339](https://tools.ietf.org/html/rfc3339) format, i.e. times based on offsets to UTC. There are three possible values for `repeat`:

* `none`: Single schedule turndown and turnup.
* `daily`: Start and end times will reschedule every 24 hours.
* `weekly`: Start and end times will reschedule every 7 days.

To create this schedule, you may modify _example-schedule.yaml_ to your desired schedule and run:

```bash
kubectl apply -f artifacts/example-schedule.yaml
```

Currently, updating a resource is not supported, so if the scheduling of the _example-schedule.yaml_ fails, you will need to delete the resource via:

```bash
kubectl delete tds example-schedule
```

Then make the modifications to the schedule and re-apply.

## Viewing a turndown schedule

The `turndownschedule` resource can be listed via `kubectl` as well:

```bash
kubectl get turndownschedules
```

or using the shorthand:

```bash
kubectl get tds
```

Details regarding the status of the turndown schedule can be found by outputting as a JSON or YAML:

```bash
kubectl get tds example-schedule -o yaml
```

{% code overflow="wrap" %}

```yaml
apiVersion: kubecost.com/v1alpha1
kind: TurndownSchedule
metadata:
  annotations:
    kubectl.kubernetes.io/last-applied-configuration: |
      {"apiVersion":"kubecost.com/v1alpha1","kind":"TurndownSchedule","metadata":{"annotations":{},"finalizers":["finalizer.kubecost.com"],"name":"example-schedule"},"spec":{"end":"2020-03-17T00:35:00Z","repeat":"daily","start":"2020-03-17T00:20:00Z"}}
  creationTimestamp: "2020-03-17T00:18:39Z"
  finalizers:
  - finalizer.kubecost.com
  generation: 1
  name: example-schedule
  resourceVersion: "33573"
  selfLink: /apis/kubecost.com/v1alpha1/turndownschedules/example-schedule
  uid: d9b16aed-67e4-11ea-b591-42010a8e0075
spec:
  end: "2020-03-17T00:35:00Z"
  repeat: daily
  start: "2020-03-17T00:20:00Z"
status:
  current: scaledown
  lastUpdated: "2020-03-17T00:36:39Z"
  nextScaleDownTime: "2020-03-18T00:21:38Z"
  nextScaleUpTime: "2020-03-18T00:36:38Z"
  scaleDownId: 38ebf595-4e2b-46e9-951a-1e3ceff30536
  scaleDownMetadata:
    repeat: daily
    type: scaledown
  scaleUpID: 869ec89f-a8d8-450b-9ebb-71cd4d7fbaf8
  scaleUpMetadata:
    repeat: daily
    type: scaleup
  state: ScheduleSuccess
```

{% endcode %}

The `status` field displays the current status of the schedule including next schedule times, specific schedule identifiers, and the overall state of schedule.

* `state`: The state of the turndown schedule. This can be:
  * `ScheduleSuccess`: The schedule has been set and is waiting to run.
  * `ScheduleFailed`: The scheduling failed due to a schedule already existing, scheduling for a date-time in the past.
  * `ScheduleCompleted`: For schedules with repeat: none, the schedule will move to a completed state after turn up.
* `current`: The next action to run.
* `lastUpdated`: The last time the status was updated on the schedule.
* `nextScaleDownTime`: The next time a turndown will be executed.
* nextScaleUpTime: The next time at turn up will be executed.
* `scaleDownId`: Specific identifier assigned by the internal scheduler for turndown.
* `scaleUpId`: Specific identifier assigned by the internal scheduler for turn up.
* `scaleDownMetadata`: Metadata attached to the scaledown job, assigned by the turndown scheduler.
* `scaleUpMetadata`: Metadata attached to the scale up job, assigned by the turndown scheduler.

## Canceling a turndown schedule

A turndown can be canceled before turndown actually happens or after. This is performed by deleting the resource:

```bash
kubectl delete tds example-schedule
```

Canceling while turndown is currently scaling down or scaling up will result in a delayed cancellation, as the schedule must complete its operation before processing the deletion/cancellation.

If the turndown schedule is canceled between a turndown and turn up, the turn up will occur automatically upon cancellation.

## Using cluster turndown via UI

Cluster turndown has limited functionality via the Kubecost UI. To access cluster turndown in the UI, you must first enable [Kubecost Actions](/using-kubecost/navigating-the-kubecost-ui/savings/savings-actions.md#enabling-kubecost-actions). Once this is completed, you will be able to create and delete turndown schedules instantaneously for your supported clusters. Read more about turndown's UI functionality in [this section](/using-kubecost/navigating-the-kubecost-ui/savings/savings-actions.md#cluster-turndown) of the above Kubecost Actions doc. Review the entire doc for more information on Kubecost Actions functionality and limitations.

## Limitations

* The internal scheduler only allows one schedule at a time to be used. Any additional schedule resources created will fail (`kubectl get tds -o yaml` will display the status).
* Do not attempt to `kubectl edit` a turndown schedule. This is currently not supported. Recommended approach for modifying is to delete and then create a new schedule.
* There is a 20-minute minimum time window between start and end of turndown schedule.
