# Automatic request right-sizing

> **Note**: This feature is in a pre-release (alpha/beta) state. It has limitations. Please read the documentation carefully.

Kubecost can automatically implement its [recommendations](https://docs.kubecost.com/apis/apis/api-request-right-sizing-v2) for container
[resource requests](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits) if you have the [Cluster Controller](https://github.com/kubecost/docs/blob/main/controller.md) component
enabled. Using automatic request right-sizing allows you to instantly
optimize resource allocation across your entire cluster, without fiddling with
excessive YAML or arcane `kubectl` commands. You can easily eliminate resource
over-allocation in your cluster, which paves the way for vast savings via
cluster right-sizing and other optimizations.

> **Note**: Cluster Controller is disabled by default because it is the only component of
> Kubecost with write access to cluster resources.

## Setup

To enable this functionality, set the value `clusterController.enabled=true`, as seen below:

```sh
helm upgrade \
    -i \
    --create-namespace kubecost \
    kubecost/cost-analyzer \
    --set kubecostToken="YXV0b3JlcXVlc3RzaXppbmcK" \
    --set clusterController.enabled=true
```

> **Note**: This setup will only provide functionality for continuous request right-sizing. For 1-click right-sizing and automated cluster scaledown functionality, follow the setup for your corresponding Kubernetes service (GKE or EKS) on the [Cluster Controller](https://github.com/kubecost/docs/blob/main/controller.md) page to create a provider key.

## Usage

Once enabled, you can follow the detailed usage guides for "1-click" (instantaneous) and "Continuous" right-sizing.

- [1-click](https://github.com/kubecost/docs/blob/main/guide-one-click-request-sizing.md)
- [Continuous](https://github.com/kubecost/docs/blob/main/continuous-request-sizing.md)
