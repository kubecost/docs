Container Request Right Sizing Recommendation API (v2)
==================================

The container request right sizing recommendation API provides recommendations
for [container resource
requests](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
based on configurable parameters and estimates the savings from implementing
those recommendations on a per-container, per-controller level. Of course, if
the cluster-level resources stay static then you will likely not enjoy real
savings from applying these recommendations until you reduce your cluster
resources. Instead, your idle allocation will increase.

The endpoint is available at
```
http://<kubecost-address>/model/savings/requestSizingV2
```


## Parameters

| Name | Type | Description |
|------|------|-------------|
| `targetCPUUtilization` | float in the range (0,1] | An ratio of headroom on the base recommended CPU request. If the base recommendation is 100 mCPU and this parameter is `0.8`, the recommended CPU request will be `100 / 0.8 = 125` mCPU. Defaults to `0.7`. Inputs that fail to parse (see https://pkg.go.dev/strconv#ParseFloat) will default to `0.7`.|
| `targetRAMUtilization` | float in the range (0,1] | Calculated like CPU. |
| `window` | string | Required parameter. Duration of time over which to calculate usage. Supports days before the current time in the following format: `3d`. See the [Allocation API documentation](https://github.com/kubecost/docs/blob/main/allocation.md#querying) for more a more detailed explanation of valid inputs to `window`. |
| `filter` | string | A filter to reduce the set of workloads for which recommendations will be calculated. See [V2 Filters](https://github.com/kubecost/docs/blob/main/filteres-v2.md) for syntax. V1 filters are also supported, please see v1 API documentation. |


## API examples

```
KUBECOST_ADDRESS='http://localhost:9090/model'

curl -G \
  -d 'targetCPUUtilization=0.8' \
  -d 'targetRAMUtilization=0.8' \
  -d 'window=3d' \
  --data-urlencode 'filter=namespace:"kubecost"+container:"cost-model"' \
  ${KUBECOST_ADDRESS}/savings/requestSizingV2
```

## Recommendation methodology

The "base" recommendation is calculated from the maximum observed usage of each
resource per unique container _spec_ (e.g. a 2-replica, 3-container Deployment
will have 3 recommendations: one for each container spec).

Say you have a single-container Deployment with two replicas: A and B.
- A's container had peak usages of 120 mCPU and 300 MiB of RAM.
- B's container had peak usages of 800 mCPU and 120 MiB of RAM.

The base recommendation for the Deployment's container will be 800 mCPU and 300
MiB of RAM. Overhead will be added to the base recommendation according to the
target utilization parameters as described above.

## Savings projection methodology

See [v1 docs](https://github.com/kubecost/docs/blob/main/api-request-right-sizing.md#savings-projection-methodology).


<!--- {"article":"9176161195799","section":"4402829033367","permissiongroup":"1500001277122"} --->