Continuous Request Right-Sizing with Kubecost's Kubescaler
=================================================================

> **Note**: This feature is in a pre-release (alpha/beta) state and has limitations. Please read the documentation carefully.

Kubecost's Kubescaler implements continuous request right-sizing: the automatic application of Kubecost's high-fidelity [recommendations](https://github.com/kubecost/docs/blob/main/api-request-right-sizing-v2.md) to your containers' resource requests. This provides an easy way to automatically improve your allocation of cluster resources by improving efficiency.

Kubescaler can be enabled and configured on a per-workload basis so that only
the workloads you want edited will be edited.

## Setup

Kubescaler is part of the [cluster-controller](https://github.com/kubecost/docs/blob/main/controller.md) component of Kubecost. Follow the instructions in that doc to get it running in your cluster. Please note that the cloud provider "key" setup is not
required for Kubescaler to work.

## Usage

Kubescaler is configured on a workload-by-workload basis via annotations.

Supported workload types:
- Deployments

Planned support:
- DaemonSets
- Uncontrolled Pods
- ...and more!

| Annotation | Description | Example(s) |
| ---------- | ----------- | ---------- |
| `request.autoscaling.kubecost.com/enabled` | Whether to autoscale the workload. See note on `KUBESCALER_RESIZE_ALL_DEFAULT`. | `true`, `false` |
| `request.autoscaling.kubecost.com/frequencyMinutes` | How often to autoscale the workload, in minutes. If unset, a conservative default is used. | `73` |
| `request.autoscaling.kubecost.com/scheduleStart` | Optional augmentation to the frequency parameter. If both are set, the workload will be resized on the scheduled frequency, aligned to the start. If frequency is 24h and the start is midnight, the workload will be rescheduled at (about) midnight every day. Formatted as RFC3339. | `2022-11-28T00:00:00Z` |
| `cpu.request.autoscaling.kubecost.com/targetUtilization` | Target utilization  (CPU) for the recommendation algorithm. If unset, the backing recommendation service's default is used. | `0.8` |
| `memory.request.autoscaling.kubecost.com/targetUtilization` | Target utilization (Memory/RAM) for the recommendation algorithm. If unset, the backing recommendation service's default is used. | `0.8` |

Notable Helm values:

| Helm value | Description | Example(s) |
| ---------- | ----------- | ---------- |
| `clusterController.kubescaler.resizeAllDefault` | If true, Kubescaler will switch to default-enabled for all workloads unless they are annotated with `request.autoscaling.kubecost.com/enabled=false`. This is recommended for low-stakes clusters where you want to prioritize workload efficiency without reworking deployment specs for all workloads. | `true` |

### Example

``` sh
export NS="kubecost"
export DEP="kubecost-cost-analyzer"
export AN_ENABLE="request.autoscaling.kubecost.com/enabled=true"
export AN_FREQ="request.autoscaling.kubecost.com/frequencyMinutes=660"
export AN_TCPU="cpu.request.autoscaling.kubecost.com/targetUtilization=0.9"
export AN_TMEM="memory.request.autoscaling.kubecost.com/targetUtilization=0.9"

kubectl annotate -n "${NS}" deployment "${DEP}" "${AN_ENABLE}"
kubectl annotate -n "${NS}" deployment "${DEP}" "${AN_FREQ}"
kubectl annotate -n "${NS}" deployment "${DEP}" "${AN_TCPU}"
kubectl annotate -n "${NS}" deployment "${DEP}" "${AN_TMEM}"
```

Kubescaler will take care of the rest. It will apply the best-available
recommended requests to the annotated controller every 11 hours.

To check current requests for your Deployments, use the following command:
``` sh
kubectl get deployment -n "kubecost" -o=jsonpath="{range .items[*]}"deployment/"{.metadata.name}{'\n'}{range .spec.template.spec.containers[*]}{.name}{'\t'}{.resources.requests}{'\n'}{end}{'\n'}{end}"
```
