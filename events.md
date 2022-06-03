# Events

Kubecost emits events when certain things happen. Those events are also recorded in an event log in the interest of diagnosing problems.

## Event kinds

* `AllocationSetSavedEvent` describes a saved AllocationSet
  * size: number of records in the set
  * window: window of the set
* `AllocationSetLoadedEvent` describes a loaded AllocationSet
  * size: number of records in the set
  * window: window of the set
* `AllocationSetAggregatedEvent` describes aggregating an AllocationSet
  * size: number of records in the set
  * window: window of the set
* `AllocationSetTotaledEvent` describes totaling an AllocationSet
  * window: window of the set
* `AllocationSetReconciledEvent` describes reconciling an AllocationSet
  * window: window of the set
* `AllocationSetComputeErrorEvent` describes an error in computation
* `AllocationSetReconcileErrorEvent` describes an error in reconciliation
* `AssetSetSavedEvent` described a saved AssetSet
  * size: number of records in the set
  * window: window of the set
* `AssetSetLoadedEvent` described a loaded AssetSet
  * size: number of records in the set
  * window: window of the set
* `AssetSetAggregatedEvent` described aggregating an AssetSet
  * size: number of records in the set
  * window: window of the set
* `AssetSetTotaledEvent` described totaling an AssetSet
  * window: window of the set
* `AssetSetReconciledEvent` described reconciling an AssetSet
  * window: window of the set
* `AssetSetComputeErrorEvent` described an error in computation
* `AssetSetReconcileErrorEvent` described an error in reconciliation

## Event log

To access the most recent events in the event log, invoke `GET <kubecost>/model/etl/log`, which will provide the following, e.g.:

```
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

This log will additionally be appended to bug reports.
