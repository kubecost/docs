# Cost Events Audit API

> **Note**: This feature is in a beta state. It has limitations. Please read the documentation carefully.

The Cost Events Audit API aims to offer improved visibility on recent changes at cluster level and their estimated cost impact.

{% swagger method="get" path="/audit/events" baseUrl="http://<your-kubecost-address>/model" summary="Cost events Audit API" %}
{% swagger-description %}
Accesses the most recent cluster events and their predicted cost impact
{% endswagger-description %}

{% swagger-parameter in="path" name="count" type="int" %}
Number of events to return. If unspecified, it returns all events available.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterNamespaces" type="string" %}
Comma-separated list of namespaces to match; e.g.

`namespace-one,namespace-two`

will return change events that have occurred only in those two namespaces.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterEventTypes" type="string" %}
Filter query by event type. Currently, only

`add`

and

`delete`

are accepted. (more types coming soon) Also accepts comma-separated lists, like

`add,delete`

.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterResourceTypes" type="string" %}
Resource type. Currently, only

`deployment`

 is accepted. (more types coming soon)
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterTotalCostLowerBound" type="float" %}
Floating-point value representing the lower bound for the total event cost.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterTotalCostUpperBound" type="float" %}
Floating-point value representing the upper bound for the total event cost.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
```javascript
{
    "code": 200,
    "data": [
        {
            "eventType": "add",
            "resourceType": "deployment",
            "timestamp": "2023-02-28T13:58:44.552788548Z",
            "properties": {
                "cluster": "cluster-one",
                "name": "sample-deployment",
                "namespace": "kubecost"
            },
            "totalRequests": {
                "cpu": "100m",
                "memory": "32Mi"
            },
            "resourceCosts": {
                "costPerCPUCoreHour": 0.031616438356164386,
                "costPerRAMByteHour": 3.94217363775593e-12,
                "costPerGPUHour": 0.95
            },
            "costPrediction": {
                "totalMonthlyRate": 2.4045625000000004,
                "cpuMonthlyRate": 2.3080000000000003,
                "ramMonthlyRate": 0.0965625,
                "gpuMonthlyRate": 0
            }
        },
        ...
    ]
}
```
{% endswagger-response %}
{% endswagger %}

## Event tracking

Changes at cluster level can range from actions triggered by declarative statements submitted by users (e.g. creation of a Deployment) to automated actions (e.g. cluster autoscaling) or performance events. We detect changes that would have an impact on the overall cluster cost using watchers on the Kubernetes API client.

The watchers are tracking change events across all namespaces within the local/primary cluster. (the cluster that the instance of Kubecost you are interacting with via HTTP is running on)

### Supported events

* Deployment creation
* Deployment deletion

> **Note**: This page will be updated as more event types are supported.

## Estimated cost impact

Cost implications of cluster events are handled by passing the Kubernetes spec inferred from the change event to the Kubecost Predict API.

## Current limitations

* The Cost Events Audit API can return up to 1000 of the most recent cluster events. There is no time expiration limit on the events.
* Events returned by the Cost Events Audit API are currently not persisted between Kubecost pod restarts.
* The Cost Events Audit API does not track events for clusters _other_ than the local/primary cluster.