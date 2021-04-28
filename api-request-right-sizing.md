# Container Request Right-Sizing API

The container request right-sizing API provides recommendations for
[container resource requests](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
based on configurable parameters and estimates the savings from implementing those recommendations
on a per-container, per-controller level. Of course, if the cluster-level resources stay static then
you will likely not enjoy real savings from applying these recommendations until you reduce
your cluster resources. Instead, your idle allocation will increase.

The endpoint is available at
```
http://<kubecost-address>/model/savings/requestSizing
```

## Parameters


| Name | Type | Description |
|------|------|-------------|
| `targetCPUUtilization` | float between 0 and 1 | An amount of headroom to enforce with the new request, based on the calculated (real) usage. If the calculated usage is, for example, 100 mCPU and this parameter is `0.8`, the recommended CPU request will be `100 / 0.8 = 125` mCPU. |
| `targetRAMUtilization` | float between 0 and 1 | Calculated like CPU. |
| `window` | string | Duration of time over which to calculate usage. Supports hours or days before the current time in the following format: `2h` or `3d`. |
| `algorithm` | string | The method with which to calculate usage. Currently supports either `max-headroom` or `percentile-headroom`. See subsections for additional parameters. If omitted, defaults to `percentile-headroom` for compatibility reasons. |

### Max Headroom Algorithm

The max headroom algorithm, available with `algorithm=max-headroom`, uses data in the Kubecost ETL to calculate the maximum resource usage (CPU and RAM) over the window. It requires no additional parameters. The max headroom algorithm is substantially more performant for large Kubernetes clusters because of the efficiency of Kubecost's ETL. 

### Percentile Headroom

The percentile headroom algorithm, available with `algorithm=percentile-headroom`, uses Prometheus' `quantile_over_time` to calculate resource usage. It therefore requires an additional parameter, `p`, to specify the quantile. For example, `algorithm=percentile-headroom&p=0.99` will use the 99th-percentile usage as the calculated usage.


## Examples

```
KUBECOST_ADDRESS=http://localhost:9090

curl -G \
  -d 'algorithm=max-headroom' \
  -d 'targetCPUUtilization=0.8' \
  -d 'targetRAMUtilization=0.8' \
  -d 'window=3d' \
  ${KUBECOST_ADDRESS}/model/savings/requestSizing
```


```
KUBECOST_ADDRESS=http://localhost:9090

curl -G \
  -d 'algorithm=percentile-headroom' \
  -d 'p=0.95' \
  -d 'targetCPUUtilization=0.8' \
  -d 'targetRAMUtilization=0.8' \
  -d 'window=3d' \
  ${KUBECOST_ADDRESS}/model/savings/requestSizing
```
