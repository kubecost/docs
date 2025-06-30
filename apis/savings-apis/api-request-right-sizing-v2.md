# Container Request Right Sizing Recommendation API

{% swagger method="get" path="savings/requestSizingV2" baseUrl="http://<kubecost-address>/model/" summary="Container Request Right Sizing Recommendation API (V2)" %}
{% swagger-description %}
The container request right sizing recommendation API provides recommendations for [container resource requests](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) based on configurable parameters and estimates the savings from implementing those recommendations on a per-container, per-controller level. If the cluster-level resources stay static, then there may not be significant savings from applying Kubecost's recommendations until you reduce your cluster resources. Instead, your idle allocation will increase.
{% endswagger-description %}

{% swagger-parameter in="query" name="window" required="true" type="string" %}
Duration of time over which to query. Accepts multiple different formats of time (see this [Using the `window` parameter](/apis/apis-overview.md#using-the-window-parameter) section for more info). It's recommended to provide a window greater than `2d` for accurate sampling.
{% endswagger-parameter %}

{% swagger-parameter in="query" name="algorithmCPU" type="string" required="false" %}
The algorithm to be used to calculate CPU recommendations based on historical CPU usage data. Options are `max` and `quantile`. Max recommendations are based on the maximum-observed usage in `window`. Quantile recommendations are based on a quantile of observed usage in `window` (requires the `qCPU` parameter to set the desired quantile). Defaults to `max`.
{% endswagger-parameter %}

{% swagger-parameter in="query" name="algorithmRAM" type="string" required="false" %}
Like `algorithmCPU`, but for RAM recommendations.
{% endswagger-parameter %}

{% swagger-parameter in="query" name="qCPU" type="float in the range (0, 1]" required="false" %}
The desired quantile to base CPU recommendations on. Only used if `algorithmCPU` is set to `quantile`, `quantileOfAverages`, or `quantileOfMaxes`. **Note**: a quantile of `0.95` is the same as a 95th percentile.
{% endswagger-parameter %}

{% swagger-parameter in="query" name="qRAM" type="float in the range (0, 1]" required="false" %}
Like `qCPU`, but for RAM recommendations.
{% endswagger-parameter %}

{% swagger-parameter in="query" name="targetCPUUtilization" type="float in the range (0, 1]" required="false" %}
A ratio of headroom on the base recommended CPU request. If the base recommendation is 100 mCPU and this parameter is `0.8`, the recommended CPU request will be `100 / 0.8 = 125` mCPU. Defaults to `0.7`. Inputs that fail to parse (see [Go docs here](https://pkg.go.dev/strconv#ParseFloat)) will default to `0.7`.
{% endswagger-parameter %}

{% swagger-parameter in="query" name="targetRAMUtilization" type="float in the range (0, 1]" required="false" %}
Calculated like `targetCPUUtilization`.
{% endswagger-parameter %}

{% swagger-parameter in="query" name="minRecCPUMillicores" type="float" required="false" %}
Lower bound, in millicores, of the CPU recommendation. Defaults to 10. Be careful when modifying below 10 for the following reason. Kubernetes currently recommends a maximum of 110 pods per node. A 10m minimum recommendation allows close to that (if all nodes are single core) while also being a round number.
{% endswagger-parameter %}

{% swagger-parameter in="query" name="minRecRAMBytes" type="float" required="false" %}
Lower bound, in bytes, of the RAM recommendation. Defaults to 20MiB (20 \* 1024 \* 1024).
{% endswagger-parameter %}

{% swagger-parameter in="query" name="filter" type="string" required="false" %}
A filter to reduce the set of workloads for which recommendations will be calculated. See our [Filter Parameters](/apis/filters-api.md) doc for syntax. v1 filters are also supported.
{% endswagger-parameter %}

{% swagger-parameter in="query" name="sortBy" type="string" required="false" %}
Column to sort the response by. Defaults to `totalSavings`. Options are `totalSavings`, `currentEfficiency`, `cpuRecommended`, `cpuLatest`, `memoryRecommended`, and `memoryLatest`.
{% endswagger-parameter %}

{% swagger-parameter in="query" name="sortByOrder" type="string" required="false" %}
Order to sort by. Defaults to `descending`. Options are `descending` and `ascending`.
{% endswagger-parameter %}

{% swagger-parameter in="query" name="includeLabelsAndAnnotations" type="boolean" required="false" %}
Displays all labels and annotations associated with each container request when set to `true`. Default is `false`.
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

## Querying with `/topline` endpoint to view cost totals across query

`/topline` is an optional API endpoint which can be added to your right-sizing query via `.../savings/RequestSizingV2/topline...` to provide a condensed overview of all items sampled. `TotalMonthlySavings` is the total estimated savings value from adopting right-sizing recommendations. `Count` refers to the number of items sampled. `Recommendations` should return `null`, as it is unable to provide a universal right-sizing recommendation.

```
{
    "TotalMonthlySavings": ,
    "Count": ,
    "Recommendations": null 
}
```

## Recommendation methodology

The "base" recommendation is calculated from the observed usage of each resource per unique container _spec_ (e.g. a 2-replica, 3-container deployment will have 3 recommendations: one for each container spec).

Say you have a single-container deployment with two replicas: A and B.

* A's container had peak usages of 120 mCPU and 300 MiB of RAM.
* B's container had peak usages of 800 mCPU and 120 MiB of RAM.

The max algorithm recommendation for the deployment's container will be 800 mCPU and 300 MiB of RAM. Overhead will be added to the base recommendation according to the target utilization parameters as described above.

## Applying your request sizing recommendations

After providing you with right sizing recommendations, Kubecost can additionally directly implement these recommendations into your environment. For more information, see the [Container Request Recommendation Apply/Plan APIs](api-request-recommendation-apply.md) doc.

## Savings projection methodology

See [V1 docs](/apis/deprecated-apis/api-request-right-sizing.md).
