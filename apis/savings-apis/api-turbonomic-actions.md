# Turbonomic Actions

{% swagger method="get" path="turbonomic/resizeWorkloadControllers" baseUrl="http://<kubecost-address>/model/savings/" summary="Turbonomic Actions: Resize Workload Controllers" %}
{% swagger-description %}
The Resize Workload Controllers API returns workloads for which request resizing has been recommended by Turbonomic. The list of results returned should align with those in the Turbonomic Actions Center. 
{% endswagger-description %}

{% swagger-parameter in="path" name="filter" type="string" required="false" %}
Filter your results by cluster, namespace and/or controller.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
```json
{
  "code": 200,
  "data": {
    "numResults": 1,
    "totalSavings": 2.00,
    "actions": [
      {
        "action": {
          "cluster": "standard-cluster-1",
          "namespace": "kubecost",
          "controller": "kubecost-cost-analyzer",
          "replicaCount": 1,
          "compoundActions": {
            "cost-model": [
              {
                "target": "VCPURequest",
                "unit": "mCores",
                "oldValue": 200,
                "newValue": 100
              }
            ]
          },
          "available": true,
          "targetId": "11111111111111"
        },
        "currentMonthlyRate": 4.00,
        "predictedMonthlyRate": 2.00,
        "predictedSavings": 2.00
      }
    ]
  }
}
```
{% endswagger-response %}
{% endswagger %}

{% swagger method="get" path="turbonomic/suspendContainerPods" baseUrl="http://<kubecost-address>/model/savings/" summary="Turbonomic Actions: Suspend Container Pods" %}
{% swagger-description %}
The Suspend Container Pods API returns pods that Turbonomic recommends for suspension. The list of results returned should align with those in the Turbonomic Actions Center.
{% endswagger-description %}

{% swagger-parameter in="path" name="filter" type="string" required="false" %}
Filter your results by cluster, namespace, controller and/or pod.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
```json
{
  "code": 200,
  "data": {
    "numResults": 1,
    "totalSavings": 12.37,
    "actions": [
      {
        "action": {
          "cluster": "standard-cluster-1",
          "namespace": "infra-cost",
          "controller": "infra-cost-agent",
          "pod": "infra-cost-agent-xdj34",
          "available": true,
          "targetId": "11111111111111"
        },
        "currentMonthlyRate": 12.37,
        "predictedMonthlyRate": 0,
        "predictedSavings": 12.37
      }
    ]
  }
}
```
{% endswagger-response %}
{% endswagger %}

{% swagger method="get" path="turbonomic/suspendVirtualMachines" baseUrl="http://<kubecost-address>/model/savings/" summary="Turbonomic Actions: Suspend Virtual Machines" %}
{% swagger-description %}
The Suspend Container Pods API returns virtual machines that Turbonomic recommends for suspension. The list of results returned should align with those in the Turbonomic Actions Center.
{% endswagger-description %}

{% swagger-parameter in="path" name="filter" type="string" required="false" %}
Filter your results by cluster.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
```json
{
  "code": 200,
  "data": {
    "numResults": 1,
    "totalSavings": 9.03,
    "actions": [
      {
        "action": {
          "cluster": "standard-cluster-1",
          "node": "gke-standard-cluster-1-spotpool-b4a02c44-1001",
          "available": true,
          "targetId": "11111111111111"
        },
        "currentMonthlyRate": 9.03,
        "predictedMonthlyRate": 0,
        "predictedSavings": 9.03
      }
    ]
  }
}
```
{% endswagger-response %}
{% endswagger %}

{% swagger method="get" path="turbonomic/moveContainerPods" baseUrl="http://<kubecost-address>/model/savings/" summary="Turbonomic Actions: Move Container Pods" %}
{% swagger-description %}
The Move Container Pods API returns pods that Turbonomic recommends to be moved from one node to another. The list of results returned should align with those in the Turbonomic Actions Center.
{% endswagger-description %}

{% swagger-parameter in="path" name="filter" type="string" required="false" %}
Filter your results by cluster, namespace, controller and/or pod.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
```json
{
  "code": 200,
  "data": {
    "numResults": 2,
    "totalSavings": 30.0,
    "actions": [
      {
        "action": {
          "cluster": "standard-cluster-1",
          "namespace": "turbo-server",
          "controller": "db",
          "pod": "db-ffbdfb97b-aroxf",
          "originNode": "gke-standard-cluster-1-pool-1-b4a02c44-1001",
          "destinationNode": "gke-standard-cluster-1-pool-2-91dc432d-1002",
          "available": true,
          "targetId": "11111111111111"
        },
        "currentMonthlyRate": 27.90,
        "predictedMonthlyRate": 0,
        "predictedSavings": 27.90
      },
      {
        "action": {
          "cluster": "standard-cluster-1",
          "namespace": "infra-kubecost",
          "controller": "infra-kubecost-cost-analyzer",
          "pod": "infra-kubecost-cost-analyzer-566b488b69-1001a",
          "originNode": "gke-standard-cluster-1-pool-2-91dc432d-1002",
          "destinationNode": "gke-standard-cluster-1-pool-3-57364626-1003",
          "available": true,
          "targetId": "11111111111112"
        },
        "currentMonthlyRate": 2.10,
        "predictedMonthlyRate": 0,
        "predictedSavings": 2.10
      }
    ]
  }
}
```
{% endswagger-response %}
{% endswagger %}