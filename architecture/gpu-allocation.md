## GPU Allocation

Kubecost performs GPU allocation through [container resource block](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) in the pod spec, which are parsed for each pod which has a container resource request or limit of type `nvidia.com/gpu` for NVIDIA GPUs. A pod requesting NVIDIA GPU resources will have a field `spec.containers.resources.limits` in which the resource `nvidia.com/gpu` will be requested.

```yaml
resources:
  limits:
    nvidia.com/gpu: 1
```

The number of NVIDIA GPUs requested is parsed for each container with GPU resource request. If no request exists, the limit will be used. If neither is found, the number of allocated GPUs is `0.0`, and no allocation is recorded. This is used to calculate GPU costs, as in the [Kubecost Allocation view](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/README.md).

A pod requesting virtual GPUs using the [AWS Virtual GPU device plugin](https://github.com/awslabs/aws-virtual-gpu-device-plugin) will also follow the same pattern, with the allocation being that of the `k8s.amazonaws.com/vgpu` resource. In this case, the vGPUs allocated are adjusted by a coefficient representing the vGPUs per physical GPU as defined in the [vGPU device plugin daemonset](https://github.com/awslabs/aws-virtual-gpu-device-plugin/blob/master/manifests/device-plugin.yml) to get the proportion of physical GPU being used by the container. This defaults at `10.0` vGPUs per physical GPU, meaning a container with a request of `k8s.amazonaws.com/vgpu: 5` would be using half of a physical GPU by default.

More information about consuming GPU resources can be found in Kubernetes' [Schedule GPU](https://kubernetes.io/docs/tasks/manage-gpus/scheduling-gpus/) doc.
