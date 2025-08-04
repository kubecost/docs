# Cluster Right-Sizing Recommendation API

Kubecost's Cluster Right-Sizing Recommendation API can monitor the resource utilization of your clusters and offer cost-effective right-sizing solutions.

{% swagger method="get" path="/clusterSizingETL" baseUrl="http://<your-kubecost-address>/model/savings" summary="Cluster Right-Sizing Recommendation API" %}
{% swagger-description %}

{% endswagger-description %}

{% swagger-parameter required="false" in="path" name="window" type="string" %}
Duration of time over which to query. Accepts multiple different formats of time (see this [Using the `window` parameter](/apis/apis-overview.md#using-the-window-parameter) section for more info).
{% endswagger-parameter %}

{% swagger-parameter in="path" type="float in the range (0, 1]" name="targetUtilization" %}
Target CPU/RAM utilization which parallels environment profiles. For reference, Development should equal `.80`, Production should equal `.65`, and High Availability should equal `.5`. Also supports custom values within the range.
{% endswagger-parameter %}

{% swagger-parameter in="path" type="int" name="minNodeCount" %}
Minimum node count to be recommended which parallels environment profiles. For reference, Development should equal `1`, Production should equal `2`, and High Availability should equal `3`. Also supports custom values within the range.
{% endswagger-parameter %}

{% swagger-parameter in="path" type="boolean" name="allowSharedCore" %}
Whether you want to allow shared core node types to be included in your recommendation. Accepts `true` or `false`.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="architecture" type="string" %}
Accepts `x86` or `ARM`. Currently, `ARM` is only supported on AWS clusters.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
{% code overflow="wrap" %}

````
```json
{
    "code": 200,
    "data": {
        "cluster-one": {
            "recommendations": {
                "multi": {
                    "pools": [
                        {
                            "type": {
                                "provider": "GCP",
                                "name": "f1-micro",
                                "vCPUs": 0.2,
                                "RAMGB": 0.6,
                                "hourlyPrice": 0.0076,
                                "spotHourlyPrice": 0.0035,
                                "sharedCore": true,
                                "architecture": "x86",
                                "region": "us-west1",
                                "pricePerRAMByteHr": 3.946013748645783e-12,
                                "pricePerCPUCoreHr": 0.031611,
                                "spotPricePerRAMByteHr": 8.307397365570068e-13,
                                "spotPricePerCPUCoreHr": 0.006655
                            },
                            "count": 3,
                            "totalMonthlyCost": 16.644,
                            "totalRAMGB": 1.7999999999999998,
                            "totalVCPUs": 0.6000000000000001
                        },
                        {
                            "type": {
                                "provider": "GCP",
                                "name": "n1-highcpu-2",
                                "vCPUs": 2,
                                "RAMGB": 1.8,
                                "hourlyPrice": 0.049594019999999996,
                                "spotHourlyPrice": 0.014915600000000001,
                                "sharedCore": false,
                                "architecture": "x86",
                                "region": "us-west1",
                                "pricePerRAMByteHr": 2.7622096240520478e-12,
                                "pricePerCPUCoreHr": 0.0221277,
                                "spotPricePerRAMByteHr": 8.307397365570068e-13,
                                "spotPricePerCPUCoreHr": 0.006655
                            },
                            "count": 1,
                            "totalMonthlyCost": 36.203634599999994,
                            "totalRAMGB": 1.8,
                            "totalVCPUs": 2
                        }
                    ],
                    "nodeCount": 4,
                    "monthlySavings": 20.5239354,
                    "totalMonthlyCost": 52.84763459999999,
                    "requiredRAMGB": 2.7075592279434204,
                    "totalRAMGB": 3.5999999999999996,
                    "utilizationRAMGB": 0.752099785539839,
                    "requiredVCPUs": 1.9305600746179477,
                    "totalVCPUs": 2.6,
                    "utilizationVCPUs": 0.7425231056222875
                },
                "single": {
                    "pools": [
                        {
                            "type": {
                                "provider": "GCP",
                                "name": "n1-standard-1",
                                "vCPUs": 1,
                                "RAMGB": 3.75,
                                "hourlyPrice": 0.033249825,
                                "spotHourlyPrice": 0.01,
                                "sharedCore": false,
                                "architecture": "x86",
                                "region": "us-west1",
                                "pricePerRAMByteHr": 2.7622096240520478e-12,
                                "pricePerCPUCoreHr": 0.0221277,
                                "spotPricePerRAMByteHr": 8.307397365570068e-13,
                                "spotPricePerCPUCoreHr": 0.006655
                            },
                            "count": 3,
                            "totalMonthlyCost": 72.81711675,
                            "totalRAMGB": 11.25,
                            "totalVCPUs": 3
                        }
                    ],
                    "nodeCount": 3,
                    "monthlySavings": 0.5544532499999946,
                    "totalMonthlyCost": 72.81711675,
                    "requiredRAMGB": 2.2937504053115845,
                    "totalRAMGB": 11.25,
                    "utilizationRAMGB": 0.20388892491658528,
                    "requiredVCPUs": 1.800551426660732,
                    "totalVCPUs": 3,
                    "utilizationVCPUs": 0.6001838088869107
                }
            },
            "parameters": {
                "clusterId": "cluster-one",
                "clusterName": "",
                "staticVCPUs": 1.4105254827890852,
                "staticRAMGB": 1.0523239374160767,
                "nonDaemonSetPodCount": 20,
                "daemonSetVCPUs": 0.13000864795721567,
                "daemonSetRAMGB": 0.41380882263183594,
                "daemonSetCount": 5,
                "maxPodVCPUs": 0.26021418473138547,
                "maxPodRAMGB": 0.13831710815429688
            },
            "preferences": {
                "minNodeCount": 3,
                "strategies": null,
                "targetUtilization": 0.8,
                "allowSharedCore": true,
                "architecture": ""
            },
            "currentClusterInfo": {
                "monthlyRate": 73.37156999999999,
                "nodes": [
                    {
                        "name": "e2-medium",
                        "provider": "GCP",
                        "architecture": "x86",
                        "count": 3,
                        "RAMGB": 4,
                        "vCPUs": 1
                    }
                ],
                "totalCounts": {
                    "totalNodeCount": 3,
                    "totalRAMGB": 12,
                    "totalVCPUs": 3
                }
            }
        }
    }
}
```
````

{% endcode %}
{% endswagger-response %}
{% endswagger %}

## Examples

Receive right-sizing recommendations taking into account cluster activity for the past two weeks, and ideal CPU and RAM utilization for a high availability environment.

{% code overflow="wrap" %}

```http
http://<your-kubecost-address>/savings/clusterSizingETL?range=2w&targetUtilization=.5&minNodeCount=3&allowSharedCore=false&architecture=x86
```

{% endcode %}

Receive recommendations taking into account AWS cluster activity for the past five days, ideal CPU and RAM utilization for a production environment, and allowing shared cores.

{% code overflow="wrap" %}

```http
http://<your-kubecost-address>/savings/clusterSizingETL?range=5d&targetUtilization=.65&minNodeCount=2&allowSharedCore=true&architecture=ARM
```

{% endcode %}

## Adopting cluster right-sizing recommendations

The Cluster Right-Sizing Recommendation API is not able to directly implement its recommendations. To adopt right-sizing recommendations for your cluster(s), view [this section](cluster-right-sizing-recommendation-api.md#cluster-right-sizing-recommendation-api) of our Cluster Right-Sizing doc.
