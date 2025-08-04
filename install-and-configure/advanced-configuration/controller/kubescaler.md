# Kubescaler

{% hint style="warning" %}
This feature is in currently in alpha. Please read the documentation carefully.
{% endhint %}

Kubecost's Kubescaler implements continuous request right-sizing: the automatic application of Kubecost's high-fidelity [recommendations](/apis/savings-apis/api-request-right-sizing-v2.md) to your containers' resource requests. This provides an easy way to automatically improve your allocation of cluster resources by improving efficiency.

Kubescaler can be enabled and configured on a per-workload basis so that only the workloads you want edited will be edited.

## Setup

Kubescaler is part of [Cluster Controller](/install-and-configure/advanced-configuration/controller/cluster-controller.md), and should be configured after the Cluster Controller is enabled.

## Usage

Kubescaler is configured on a workload-by-workload basis via annotations. Currently, only deployment workloads are supported.

| Annotation                                                   | Description                                                                                                                                                                                                                                                                                                                                                                                                                 | Example(s)             |
| ------------------------------------------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------- |
| `request.autoscaling.kubecost.com/enabled`                   | Whether to autoscale the workload. See note on `KUBESCALER_RESIZE_ALL_DEFAULT`.                                                                                                                                                                                                                                                                                                                                             | `true`, `false`        |
| `request.autoscaling.kubecost.com/frequencyMinutes`          | How often to autoscale the workload, in minutes. If unset, a conservative default is used.                                                                                                                                                                                                                                                                                                                                  | `73`                   |
| `request.autoscaling.kubecost.com/scheduleStart`             | Optional augmentation to the frequency parameter. If both are set, the workload will be resized on the scheduled frequency, aligned to the start. If frequency is 24h and the start is midnight, the workload will be rescheduled at (about) midnight every day. Formatted as RFC3339.                                                                                                                                      | `2022-11-28T00:00:00Z` |
| `cpu.request.autoscaling.kubecost.com/targetUtilization`     | Target utilization (CPU) for the recommendation algorithm. If unset, the backing recommendation service's default is used.                                                                                                                                                                                                                                                                                                  | `0.8`                  |
| `memory.request.autoscaling.kubecost.com/targetUtilization`  | Target utilization (Memory/RAM) for the recommendation algorithm. If unset, the backing recommendation service's default is used.                                                                                                                                                                                                                                                                                           | `0.8`                  |
| `request.autoscaling.kubecost.com/recommendationQueryWindow` | Value of the `window` parameter to be used when acquiring recommendations. See Request sizing API for explanation of window parameter. If setting up autoscaling for a CronJob, it is strongly recommended to set this to a value greater than the duration between Job runs. For example, if you have a weekly CronJob, this parameter should be set to a value greater than `7d` to ensure a recommendation is available. | `2d`                   |

Notable Helm values:

| Helm value                                      | Description                                                                                                                                                                                                                                                                                              | Example(s) |
| ----------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| `clusterController.kubescaler.resizeAllDefault` | If true, Kubescaler will switch to default-enabled for all workloads unless they are annotated with `request.autoscaling.kubecost.com/enabled=false`. This is recommended for low-stakes clusters where you want to prioritize workload efficiency without reworking deployment specs for all workloads. | `true`     |

### Supported workload types

Kubescaler supports apps/v1 Deployments.

Kubescaler does not support "bare" pods. Learn more in [this GitHub issue](https://github.com/kubernetes/kubernetes/issues/24913).

### Example

```bash
export NS="kubecost"
export DEP="kubecost-cost-analyzer"
export AN_ENABLE="request.autoscaling.kubecost.com/enabled=true"
export AN_FREQ="request.autoscaling.kubecost.com/frequencyMinutes=660"
export AN_TCPU="cpu.request.autoscaling.kubecost.com/targetUtilization=0.9"
export AN_TMEM="memory.request.autoscaling.kubecost.com/targetUtilization=0.9"
export AN_WINDOW="request.autoscaling.kubecost.com/recommendationQueryWindow=3d"

kubectl annotate -n "${NS}" deployment "${DEP}" "${AN_ENABLE}"
kubectl annotate -n "${NS}" deployment "${DEP}" "${AN_FREQ}"
kubectl annotate -n "${NS}" deployment "${DEP}" "${AN_TCPU}"
kubectl annotate -n "${NS}" deployment "${DEP}" "${AN_TMEM}"
kubectl annotate -n "${NS}" deployment "${DEP}" "${AN_WINDOW}"
```

Kubescaler will take care of the rest. It will apply the best-available recommended requests to the annotated controller every 11 hours. If the recommended requests exceed the current limits, the update is currently configured to set the request to the current limit.

To check current requests for your Deployments, use the following command:

{% code overflow="wrap" %}
```bash
kubectl get deployment -n "kubecost" -o=jsonpath="{range .items[*]}"deployment/"{.metadata.name}{'\n'}{range .spec.template.spec.containers[*]}{.name}{'\t'}{.resources.requests}{'\n'}{end}{'\n'}{end}"
```
{% endcode %}
