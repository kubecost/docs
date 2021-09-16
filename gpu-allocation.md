## GPU Allocation

Kubecost performs GPU allocation through [container resource limits](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/), which are parsed for each pod which has a container resource request or limit of type `nvidia.com/gpu`. A pod requesting GPU resources will have a field `spec.containers.resources` as follows:

```
    resources:
      requests:
        nvidia.com/gpu: 1
      limits:
        nvidia.com/gpu: 1
```

The number of GPUs requested is parsed for each container with GPU resource request. If no request exists, the limit will be used. If neither is found, the number of allocated GPUs is `0.0`, and no allocation is recorded.

A pod requesting virtual GPUs using the [AWS Virtual GPU device plugin](https://github.com/awslabs/aws-virtual-gpu-device-plugin) will also follow the same pattern, the allocation parsed being requests/limits for `k8s.amazonaws.com/vgpu`. In this case, the vGPUs allocated are multiplied by a coefficient representing the vGPUs per physical GPU as defined in the [vGPU device plugin daemonset](https://github.com/awslabs/aws-virtual-gpu-device-plugin/blob/master/manifests/device-plugin.yml). This defaults at `10.0` vGPUs per physical GPU.

More information about consuming GPU resources can be found [here](https://kubernetes.io/docs/tasks/manage-gpus/scheduling-gpus/).
