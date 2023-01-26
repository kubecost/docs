# Container Request Right Sizing Recommendation API (V2)

{% swagger method="get" path="savings/requestSizingV2" baseUrl="http://<kubecost-address>/model/" summary="Container Request Right Sizing Recommendation API (V2)" %}
{% swagger-description %}
The container request right sizing recommendation API provides recommendations for 

[container resource requests](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)

 based on configurable parameters and estimates the savings from implementing those recommendations on a per-container, per-controller level. Of course, if the cluster-level resources stay static then you will likely not enjoy real savings from applying these recommendations until you reduce your cluster resources. Instead, your idle allocation will increase.
{% endswagger-description %}

{% swagger-parameter in="path" name="algorithmCPU" type="string" %}
The algorithm to be used to calculate CPU recommendations based on historical CPU usage data. Options are 

`max`

 and 

`quantile`

. Max recommendations are based on the maximum-observed usage in 

`window`

. Quantile recommendations are based on a quantile of observed usage in 

`window`

 (requires the 

`qCPU`

 parameter to set the desired quantile). Defaults to 

`max`

. To use the 

`quantile`

 algorithm, the 

[ContainerStats Pipeline](/containerstats-pipeline.md)

 must be enabled.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="algorithmRAM" type="string" %}
Like 

`algorithmCPU`

, but for RAM recommendations.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="qCPU" type="float in the range (0, 1]" %}
The desired quantile to base CPU recommendations on. Only used if 

`algorithmCPU=quantile`

. Note: a quantile of 

`0.95`

 is the same as a 95th percentile.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="qRAM" type="float in the range (0, 1]" %}
Like 

`qCPU`

, but for RAM recommendations.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="targetCPUUtilization" type="float in the range (0, 1]" %}
A ratio of headroom on the base recommended CPU request. If the base recommendation is 100 mCPU and this parameter is 

`0.8`

, the recommended CPU request will be 

`100 / 0.8 = 125`

 mCPU. Defaults to 

`0.7`

. Inputs that fail to parse (see 

[Go docs here](https://pkg.go.dev/strconv#ParseFloat)

) will default to 

`0.7`

.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="targetRAMUtilization" type="float in the range (0, 1]" %}
Calculated like 

`targetCPUUtilization`

.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="window" required="true" type="string" %}
Required parameter. Duration of time over which to calculate usage. Supports days before the current time in the following format: 

`3d`

. Note: Hourly windows are not currently supported. Note: It's recommended to provide a window greater than 

`2d`

. See the 

[Allocation API documentation](/allocation.md)

 for more a more detailed explanation of valid inputs to 

`window`

.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filter" type="string" %}
A filter to reduce the set of workloads for which recommendations will be calculated. See 

[Filter parameters](filters-api.md)

 for syntax. V1 filters are also supported.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
```javascript
[
    {
        "clusterID": "...",
        "namespace": "...",
        "controllerKind": "...",
        "controllerName": "...",
        "containerName": "...",
        "recommendedRequest": {
            "cpu": "00m",
            "memory": "00Mi"
        },
        "monthlySavings": {
            "cpu": 0.00,
            "memory": 0.00
        },
        "latestKnownRequest": {
            "cpu": "00m",
            "memory": "00Mi"
        },
        "currentEfficiency": {
            "cpu": 0.00,
            "memory": 0.00,
            "total": 0.00
        }
    }
]
```
{% endswagger-response %}
{% endswagger %}

## API examples

```bash
KUBECOST_ADDRESS='http://localhost:9090/model'

curl -G \
  -d 'algorithmCPU=quantile' \
  -d 'qCPU=0.95' \
  -d 'algorithmRAM=max' \
  -d 'targetCPUUtilization=0.8' \
  -d 'targetRAMUtilization=0.8' \
  -d 'window=3d' \
  --data-urlencode 'filter=namespace:"kubecost"+container:"cost-model"' \
  ${KUBECOST_ADDRESS}/savings/requestSizingV2
```

## Recommendation methodology

The "base" recommendation is calculated from the observed usage of each resource per unique container _spec_ (e.g. a 2-replica, 3-container deployment will have 3 recommendations: one for each container spec).

Say you have a single-container deployment with two replicas: A and B.

* A's container had peak usages of 120 mCPU and 300 MiB of RAM.
* B's container had peak usages of 800 mCPU and 120 MiB of RAM.

The max algorithm recommendation for the deployment's container will be 800 mCPU and 300 MiB of RAM. Overhead will be added to the base recommendation according to the target utilization parameters as described above.

## Savings projection methodology

See [V1 docs](https://docs.kubecost.com/apis/deprecated-apis/api-request-right-sizing).
