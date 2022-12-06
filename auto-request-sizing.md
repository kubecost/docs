# Automatic request right-sizing

> **Note**: This feature is in a pre-release (alpha/beta) state. It has limitations. Please read the documentation carefully.

Kubecost can automatically implement its [recommendations](https://github.com/kubecost/docs/blob/main/api-request-right-sizing.md) for container
[resource requests](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits) if you have the [Cluster Controller](https://github.com/kubecost/docs/blob/main/controller.md) component
enabled. Using automatic request right-sizing allows you to instantly
optimize resource allocation across your entire cluster, without fiddling with
excessive YAML or arcane `kubectl` commands. You can easily eliminate resource
over-allocation in your cluster, which paves the way for vast savings via
cluster right-sizing and other optimizations.

> Cluster Controller is disabled by default because it is the only component of
> Kubecost with write access to cluster resources.

## Setup

To enable this functionality, set the value `clusterController.enabled=true`, like so:
```sh
helm upgrade \
    -i \
    --create-namespace kubecost \
    kubecost/cost-analyzer \
    --set kubecostToken="YXV0b3JlcXVlc3RzaXppbmcK" \
    --set clusterController.enabled=true
```

> While the full Cluster Controller setup (with provider key) is not required,
> it doesn't hurt.

## Usage

Once enabled, you can follow the detailed usage guides for "1-click" (instantaneous) and "Continuous" right-sizing.

- [1-click](https://github.com/kubecost/docs/blob/main/guide-one-click-request-sizing.md)
- [Continuous](https://github.com/kubecost/docs/blob/main/continuous-request-sizing.md)

