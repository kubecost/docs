# Events API

Kubecost emits events when certain things happen. Those events are also recorded in an event log in the interest of diagnosing problems.

{% swagger method="get" path="/log" baseUrl="http://<your-kubecost-address>/model/etl" summary="Events API" %}
{% swagger-description %}
Accesses the most recent events in the event log
{% endswagger-description %}

{% swagger-parameter in="path" name="window" type="string" %}
Duration of time over which to query. Accepts all standard Kubecost window formats (See our docs on using [the `window` parameter](https://docs.kubecost.com/apis/apis-overview/assets-api#using-window-parameter)).
{% endswagger-parameter %}

{% swagger-parameter in="path" name="kind" type="string" %}
Filter query by event kind (see below).
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
```javascript
{
  "code": 200,
  "data": {
    "allocation": [
      {
        "kind": "AllocationSetAggregated",
        "metadata": {
          "size": 35,
          "window": {
            "start": "2022-06-03T00:00:00Z",
            "end": "2022-06-04T00:00:00Z"
          }
        },
        "time": "2022-06-03T16:58:41.289194368Z"
      },
      {
        "kind": "AllocationSetTotaled",
        "metadata": {
          "window": {
            "start": "2022-06-03T00:00:00Z",
            "end": "2022-06-04T00:00:00Z"
          }
        },
        "time": "2022-06-03T16:58:41.285759258Z"
      },
      {
        "kind": "AllocationSetSaved",
        "metadata": {
          "size": 97,
          "window": {
            "start": "2022-06-03T10:00:00Z",
            "end": "2022-06-03T11:00:00Z"
          }
        },
        "time": "2022-06-03T17:07:54.092619416Z"
      },
      ...
    ],
    "asset": [
      {
        "kind": "AssetSetTotaled",
        "metadata": {
          "window": {
            "start": "2022-06-03T00:00:00Z",
            "end": "2022-06-04T00:00:00Z"
          }
        },
        "time": "2022-06-03T16:58:18.340435496Z"
      },
      {
        "kind": "AssetSetAggregated",
        "metadata": {
          "size": 4,
          "window": {
            "start": "2022-06-03T00:00:00Z",
            "end": "2022-06-04T00:00:00Z"
          }
        },
        "time": "2022-06-03T16:58:18.341095359Z"
      },
      {
        "kind": "AssetSetSaved",
        "metadata": {
          "size": 29,
          "window": {
            "start": "2022-06-03T10:00:00Z",
            "end": "2022-06-03T11:00:00Z"
          }
        },
        "time": "2022-06-03T17:07:54.3346484Z"
      },
      ...
    ],
    "counters": {
      "AllocationSetAggregated": 8348,
      "AllocationSetLoaded": 108,
      "AllocationSetSaved": 8240,
      "AllocationSetTotaled": 8348,
      "AssetSetAggregated": 8320,
      "AssetSetLoaded": 108,
      "AssetSetSaved": 8212,
      "AssetSetTotaled": 8320
    }
  }
}
```
{% endswagger-response %}
{% endswagger %}

## Event kinds

All event kinds below will appear in the body of the output by default. You can filter for specific event kinds using the `kind` parameter. For example, to see only `AllocationSetSaved` in the output, your endpoint will look like:

```
http://<your-kubecost-address>/model/etl/log?kind=AllocationSetSaved
```

You can also view all substrings between Allocations or Assets. For example, the following endpoint will retrieve all event kinds beginning with `AssetSet`:

```
http://<your-kubecost-address>/model/etl/log?kind=AssetSet
```

* `AllocationSetSaved` describes a saved AllocationSet
  * size: number of records in the set
  * window: window of the set
* `AllocationSetLoaded` describes a loaded AllocationSet
  * size: number of records in the set
  * window: window of the set
* `AllocationSetAggregated` describes aggregating an AllocationSet
  * size: number of records in the set
  * window: window of the set
* `AllocationSetTotaled` describes totaling an AllocationSet
  * window: window of the set
* `AllocationSetReconciled` describes reconciling an AllocationSet
  * window: window of the set
* `AllocationSetComputeError` describes an error in computation
* `AllocationSetReconcileError` describes an error in reconciliation
* `AssetSetSaved` described a saved AssetSet
  * size: number of records in the set
  * window: window of the set
* `AssetSetLoaded` described a loaded AssetSet
  * size: number of records in the set
  * window: window of the set
* `AssetSetAggregated` described aggregating an AssetSet
  * size: number of records in the set
  * window: window of the set
* `AssetSetTotaled` described totaling an AssetSet
  * window: window of the set
* `AssetSetReconciled` described reconciling an AssetSet
  * window: window of the set
* `AssetSetComputeError` described an error in computation
* `AssetSetReconcileError` described an error in reconciliation

This log will additionally be appended to bug reports.
