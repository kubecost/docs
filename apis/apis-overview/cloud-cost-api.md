# Cloud Cost API

> **Warning**: The Cloud Cost API cannot be used until you have enabled Cloud Costs via Helm. See the doc on using Kubecost's Cloud Cost page [here](https://docs.kubecost.com/using-kubecost/getting-started/cloud-costs-explorer) for instructions.

{% swagger method="get" path="/model/cloudCost/aggregate" baseUrl="http://<your-kubecost-address>" summary="Cloud Cost API" %}
{% swagger-description %}
Query cloud cost aggregate data
{% endswagger-description %}

{% swagger-parameter in="path" name="window" required="true" type="string" %}
Window of the query. Accepts all standard Kubecost window formats (See our doc on using 

[the `window` parameter](https://docs.kubecost.com/apis/apis-overview/assets-api#using-window-parameter)

).
{% endswagger-parameter %}

{% swagger-parameter in="path" name="aggregate" type="string" %}
Field by which to aggregate the results. Accepts: 

`billingID`

, 

`provider`

, 

`service`

, 

`workspace`

and 

`label:<name>`

. Supports multi-aggregation using comma-separated lists. Example: 

`aggregate=billingID,service`
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterBillingIDs" type="string" %}
Filter for account
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterWorkGroupIDs" type="string" %}
Filter for project
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterProviders" type="string" %}
Filter for cloud service provider
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterServices" type="string" %}
Filter for cloud service
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
```
{
    "code": 200,
    "data": {
        "sets": [
            {
                "aggregates": {
                    "": {
                        "properties": {
                            "provider": "",
                            "workGroupID": "",
                            "billingID": "",
                            "service": "",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0,
                        "netCost": 0
                    },
                    
                },
                "window": {
                    "start": "2023-02-26T00:00:00Z",
                    "end": "2023-02-27T00:00:00Z"
                }
            }
        ]
    }
}
```
{% endswagger-response %}
{% endswagger %}

### Example

**Query for cloud costs within the past three days, aggregated by cloud service, filtered for only services provided by AWS.**

{% tabs %}
{% tab title="Request" %}
```
http://<your-kubecost-address>/model/cloudCost/aggregate?window=3d&aggregate=service&filterProviders=AWS
```
{% endtab %}

{% tab title="Response" %}
```json
{
    "code": 200,
    "data": {
        "sets": [
            {
                "aggregates": {
                    "AWSBackup": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AWSBackup",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 4e-10,
                        "netCost": 4e-10
                    },
                    "AWSCloudTrail": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AWSCloudTrail",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 6.722614000000006,
                        "netCost": 6.722614000000006
                    },
                    "AWSCostExplorer": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AWSCostExplorer",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0.2894083871,
                        "netCost": 0.2894083871
                    },
                    "AWSELB": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "",
                            "billingID": "297945954695",
                            "service": "AWSELB",
                            "label": ""
                        },
                        "kubernetesPercent": 0.7817130327643118,
                        "cost": 40.462106329800015,
                        "netCost": 40.462106329800015
                    },
                    "AWSGlue": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AWSGlue",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0.4614631999999999,
                        "netCost": 0.4614631999999999
                    },
                    "AWSLambda": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AWSLambda",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0,
                        "netCost": 0
                    },
                    "AWSQueueService": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AWSQueueService",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0,
                        "netCost": 0
                    },
                    "AmazonAthena": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonAthena",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 18.8635215,
                        "netCost": 18.8635215
                    },
                    "AmazonCloudWatch": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonCloudWatch",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 3.2135763941000017,
                        "netCost": 3.2135763941000017
                    },
                    "AmazonEC2": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "",
                            "billingID": "297945954695",
                            "service": "AmazonEC2",
                            "label": ""
                        },
                        "kubernetesPercent": 0.8594287373045936,
                        "cost": 409.32526533589765,
                        "netCost": 409.32526533589765
                    },
                    "AmazonECR": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonECR",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0.00017718000000000006,
                        "netCost": 0.00017718000000000006
                    },
                    "AmazonECRPublic": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonECRPublic",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0,
                        "netCost": 0
                    },
                    "AmazonEFS": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonEFS",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 5.937000000000001e-07,
                        "netCost": 5.937000000000001e-07
                    },
                    "AmazonEKS": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "",
                            "billingID": "297945954695",
                            "service": "AmazonEKS",
                            "label": ""
                        },
                        "kubernetesPercent": 1,
                        "cost": 71.09614764060001,
                        "netCost": 71.09614764060001
                    },
                    "AmazonFSx": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonFSx",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 5.420359209200005,
                        "netCost": 5.420359209200005
                    },
                    "AmazonPrometheus": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonPrometheus",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 3.12611436,
                        "netCost": 3.12611436
                    },
                    "AmazonQuickSight": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonQuickSight",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0.7741935359999996,
                        "netCost": 0.7741935359999996
                    },
                    "AmazonRoute53": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonRoute53",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0.0003384000000000001,
                        "netCost": 0.0003384000000000001
                    },
                    "AmazonS3": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "",
                            "billingID": "297945954695",
                            "service": "AmazonS3",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 59.97982600390022,
                        "netCost": 59.97982600390022
                    },
                    "AmazonSNS": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonSNS",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0,
                        "netCost": 0
                    },
                    "AmazonVPC": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonVPC",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 2.880004444499996,
                        "netCost": 2.880004444499996
                    },
                    "awskms": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "awskms",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0.16129031999999963,
                        "netCost": 0.16129031999999963
                    }
                },
                "window": {
                    "start": "2023-03-07T00:00:00Z",
                    "end": "2023-03-08T00:00:00Z"
                }
            },
            {
                "aggregates": {
                    "AWSCloudTrail": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AWSCloudTrail",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 5.656379999999999,
                        "netCost": 5.656379999999999
                    },
                    "AWSCostExplorer": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AWSCostExplorer",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0.29795548390000004,
                        "netCost": 0.29795548390000004
                    },
                    "AWSELB": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "",
                            "billingID": "297945954695",
                            "service": "AWSELB",
                            "label": ""
                        },
                        "kubernetesPercent": 0.7815670307151087,
                        "cost": 40.45756354790004,
                        "netCost": 40.45756354790004
                    },
                    "AWSGlue": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AWSGlue",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0.42755856000000003,
                        "netCost": 0.42755856000000003
                    },
                    "AWSLambda": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AWSLambda",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0,
                        "netCost": 0
                    },
                    "AWSQueueService": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AWSQueueService",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0,
                        "netCost": 0
                    },
                    "AmazonAthena": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonAthena",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 18.85846949999999,
                        "netCost": 18.85846949999999
                    },
                    "AmazonCloudWatch": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonCloudWatch",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 3.2157586559000007,
                        "netCost": 3.2157586559000007
                    },
                    "AmazonEC2": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "",
                            "billingID": "297945954695",
                            "service": "AmazonEC2",
                            "label": ""
                        },
                        "kubernetesPercent": 0.8594891926690086,
                        "cost": 410.28499241199773,
                        "netCost": 410.28499241199773
                    },
                    "AmazonECR": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonECR",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0.0001771800000000001,
                        "netCost": 0.0001771800000000001
                    },
                    "AmazonECRPublic": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonECRPublic",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0,
                        "netCost": 0
                    },
                    "AmazonEFS": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonEFS",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 5.937e-07,
                        "netCost": 5.937e-07
                    },
                    "AmazonEKS": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "",
                            "billingID": "297945954695",
                            "service": "AmazonEKS",
                            "label": ""
                        },
                        "kubernetesPercent": 1,
                        "cost": 71.0962322655,
                        "netCost": 71.0962322655
                    },
                    "AmazonFSx": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonFSx",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 5.420361553700005,
                        "netCost": 5.420361553700005
                    },
                    "AmazonPrometheus": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonPrometheus",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 3.1324544100000002,
                        "netCost": 3.1324544100000002
                    },
                    "AmazonQuickSight": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonQuickSight",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0.7741935359999996,
                        "netCost": 0.7741935359999996
                    },
                    "AmazonRoute53": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonRoute53",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0.00030359999999999995,
                        "netCost": 0.00030359999999999995
                    },
                    "AmazonS3": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "",
                            "billingID": "297945954695",
                            "service": "AmazonS3",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 60.10552118050003,
                        "netCost": 60.10552118050003
                    },
                    "AmazonSNS": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonSNS",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0,
                        "netCost": 0
                    },
                    "AmazonVPC": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonVPC",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 2.880004457399996,
                        "netCost": 2.880004457399996
                    },
                    "awskms": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "awskms",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0.16129031999999963,
                        "netCost": 0.16129031999999963
                    }
                },
                "window": {
                    "start": "2023-03-08T00:00:00Z",
                    "end": "2023-03-09T00:00:00Z"
                }
            },
            {
                "aggregates": {
                    "AWSCloudTrail": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AWSCloudTrail",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 3.271654,
                        "netCost": 3.271654
                    },
                    "AWSCostExplorer": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AWSCostExplorer",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0.03,
                        "netCost": 0.03
                    },
                    "AWSELB": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "",
                            "billingID": "297945954695",
                            "service": "AWSELB",
                            "label": ""
                        },
                        "kubernetesPercent": 0.7816112430769544,
                        "cost": 20.21870167819999,
                        "netCost": 20.21870167819999
                    },
                    "AWSGlue": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AWSGlue",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0.20161768,
                        "netCost": 0.20161768
                    },
                    "AWSLambda": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AWSLambda",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0,
                        "netCost": 0
                    },
                    "AWSQueueService": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AWSQueueService",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0,
                        "netCost": 0
                    },
                    "AmazonAthena": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonAthena",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 9.43576475,
                        "netCost": 9.43576475
                    },
                    "AmazonCloudWatch": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonCloudWatch",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 1.8059822267000005,
                        "netCost": 1.8059822267000005
                    },
                    "AmazonEC2": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "",
                            "billingID": "297945954695",
                            "service": "AmazonEC2",
                            "label": ""
                        },
                        "kubernetesPercent": 0.8638156396085854,
                        "cost": 180.9191299668006,
                        "netCost": 180.9191299668006
                    },
                    "AmazonECR": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonECR",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0.00008501639999999999,
                        "netCost": 0.00008501639999999999
                    },
                    "AmazonECRPublic": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonECRPublic",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0,
                        "netCost": 0
                    },
                    "AmazonEFS": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonEFS",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 3.0720000000000005e-07,
                        "netCost": 3.0720000000000005e-07
                    },
                    "AmazonEKS": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "",
                            "billingID": "297945954695",
                            "service": "AmazonEKS",
                            "label": ""
                        },
                        "kubernetesPercent": 1,
                        "cost": 32.238463977100004,
                        "netCost": 32.238463977100004
                    },
                    "AmazonFSx": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonFSx",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 2.4844086337000006,
                        "netCost": 2.4844086337000006
                    },
                    "AmazonPrometheus": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonPrometheus",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 1.56778425,
                        "netCost": 1.56778425
                    },
                    "AmazonQuickSight": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonQuickSight",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0.3870967679999999,
                        "netCost": 0.3870967679999999
                    },
                    "AmazonRoute53": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonRoute53",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0.000056000000000000006,
                        "netCost": 0.000056000000000000006
                    },
                    "AmazonS3": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "",
                            "billingID": "297945954695",
                            "service": "AmazonS3",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 32.425120581700035,
                        "netCost": 32.425120581700035
                    },
                    "AmazonVPC": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "AmazonVPC",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 1.560002328400001,
                        "netCost": 1.560002328400001
                    },
                    "awskms": {
                        "properties": {
                            "provider": "AWS",
                            "workGroupID": "297945954695",
                            "billingID": "297945954695",
                            "service": "awskms",
                            "label": ""
                        },
                        "kubernetesPercent": 0,
                        "cost": 0.08064515999999997,
                        "netCost": 0.08064515999999997
                    }
                },
                "window": {
                    "start": "2023-03-09T00:00:00Z",
                    "end": "2023-03-10T00:00:00Z"
                }
            }
        ],
        "window": {
            "start": "2023-03-07T00:00:00Z",
            "end": "2023-03-10T00:00:00Z"
        }
    }
}http://eks.dev1.niko.kubecost.xyz:9090/model/cloudCost/aggregate?window=3d&aggregate=service&filterProviders=AWShttp://eks.dev1.niko.kubecost.xyz:9090/model/cloudCost/aggregate?window=3d&aggregate=service&filterProviders=AWShttp://eks.dev1.niko.kubecost.xyz:9090/model/cloudCost/aggregate?window=3d&aggregate=service&filterProviders=AWShttp://eks.dev1.niko.kubecost.xyz:9090/model/cloudCost/aggregate?window=3d&aggregate=service&filterProviders=AWShttp://eks.dev1.niko.kubecost.xyz:9090/model/cloudCost/aggregate?window=3d&aggregate=service&filterProviders=AWShttp://eks.dev1.niko.kubecost.xyz:9090/model/cloudCost/aggregate?window=3d&aggregate=service&filterProviders=AWS
```
{% endtab %}
{% endtabs %}
