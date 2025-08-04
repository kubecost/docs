# Calculating Node Pricing

When explicit RAM, CPU or GPU prices are not provided by your cloud provider, the Kubecost model falls back to the ratio of base CPU, GPU and RAM price inputs supplied. The default values for these parameters are based on the marginal resource rates of the cloud provider, but they can be customized within Kubecost.

These base resource (RAM/CPU/GPU) prices are normalized to ensure the sum of each component is equal to the total price of the node provisioned, based on billing rates from your provider. When the sum of resource costs is greater (or less) than the price of the node, then the ratio between the input prices is held constant.

For example, imagine a node with 1 GPU, 1 CPU and 1 Gb of RAM that costs $35/mo. If your base GPU price is $30, base CPU price is $30 and RAM GB price is $10, then these inputs will be normalized to $15 for GPU, $15 for CPU and $5 for RAM so that the sum equals the cost of the node. Note that the price of a GPU, as well as the price of a CPU, remains 3x the price of a GB of RAM.

{% code overflow="wrap" %}
```text
NodeHourlyCost = NORMALIZED_GPU_PRICE * # of GPUs + NORMALIZED_CPU_PRICE * # of CPUs + NORMALIZED_RAM_PRICE * # of RAM GB
```
{% endcode %}

[Code Reference](https://github.com/opencost/opencost/blob/v1.98.0/pkg/costmodel/costmodel.go#L933)
