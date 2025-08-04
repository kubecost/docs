# Abandoned Workloads

{% swagger method="get" path="abandonedWorkloads" baseUrl="http://<kubecost-address>/model/savings/" summary="Abandoned Workloads API" %}
{% swagger-description %}
The abandoned workloads API suggests cluster workloads that have been abandoned based on network traffic levels.
{% endswagger-description %}

{% swagger-parameter in="path" name="days" type="int" %}
Number of historical days over which network traffic should be measured.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="threshold" type="int" %}
The threshold of total traffic (bytes in/out per second) at which a workload is determined abandoned.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}

```json
{
        "pod": "...",
        "namespace": "...",
        "node": "...",
        "clusterId": "...",
        "clusterName": "...",
        "owners": [
            {
                "name": "...",
                "kind": "..."
            }
        ],
        "ingressBytesPerSecond": 0,
        "egressBytesPerSecond": 0,
        "allocation": {
            "cpuCores": 0.00,
            "ramBytes": 0.00
        },
        "requests": {
            "cpuCores": 0.00,
            "ramBytes": 0
        },
        "usage": {
            "cpuCores": 0.00,
            "ramBytes": 0
        },
        "monthlySavings": 0.00
    },
```

{% endswagger-response %}
{% endswagger %}
