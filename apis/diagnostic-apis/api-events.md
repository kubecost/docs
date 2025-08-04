# Events API

Kubecost emits events when certain things happen. Those events are also recorded in an event log in the interest of diagnosing problems.

{% swagger method="get" path="/log" baseUrl="http://<your-kubecost-address>/model/etl" summary="Events API" %}
{% swagger-description %}
Accesses the most recent events in the event log
{% endswagger-description %}

{% swagger-parameter in="path" name="window" type="string" %}
Duration of time over which to query. Accepts multiple different formats of time (see this [Using the `window` parameter](/apis/apis-overview.md#using-the-window-parameter) section for more info).
{% endswagger-parameter %}

{% swagger-parameter in="path" name="kind" type="string" %}
Filter query by event kind (see below).
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}

```json
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

```http
http://<your-kubecost-address>/model/etl/log?kind=AllocationSetSaved
```

You can also view all substrings between Allocations or Assets. For example, the following endpoint will retrieve all event kinds beginning with `AssetSet`:

```http
http://<your-kubecost-address>/model/etl/log?kind=AssetSet
```

Allocation outputs should be interpreted as:

* `AllocationSetSaved` describes a saved AllocationSet
* `AllocationSetLoaded` describes a loaded AllocationSet
* `AllocationSetAggregated` describes aggregating an AllocationSet
* `AllocationSetTotaled` describes totaling an AllocationSet
* `AllocationSetReconciled` describes reconciling an AllocationSet
* `AllocationSetComputeError` describes an error in computation
* `AllocationSetReconcileError` describes an error in reconciliation

Assets outputs should be interpreted as:

* `AssetSetSaved` describes a saved AssetSet
* `AssetSetLoaded` describes a loaded AssetSet
* `AssetSetAggregated` describes aggregating an AssetSet
* `AssetSetTotaled` describes totaling an AssetSet
* `AssetSetReconciled` describes reconciling an AssetSet
* `AssetSetComputeError` describes an error in computation
* `AssetSetReconcileError` describes an error in reconciliation

Underneath each event `kind`, you should see `size` and/or `window` returned, which are:

* `size`: number of records in the set
* `window`: window of the set

This log will additionally be appended to bug reports.
