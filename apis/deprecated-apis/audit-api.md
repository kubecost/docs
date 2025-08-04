# Audit API

{% hint style="danger" %}
As of v1.106 of Kubecost, the Audit API is deprecated. This page should not be consulted.
{% endhint %}

The Audit API applies a series of tests to the various cached data sources of Kubecost to check the validity of the data sources and the processes that act upon them. Each of the Audits tests represents an invariance that should remain true despite any changes that occur to the system as a whole. Each Audit is stored in an AuditSet, which besides audits contains a window for the timeframe that the Audits it contains cover. The Audits themselves each have a timestamp for their last run, a status, a description and other audit-specific structures which contain the results of the run.

{% swagger method="get" path="/audit" baseUrl="https://<your-kubecost-address>/model/etl" summary="Audit API" %}
{% swagger-description %}
Returns AuditSets for given window saved in the AuditStore
{% endswagger-description %}

{% swagger-parameter in="path" name="window" type="string" %}
Duration of time over which to query. Accepts all standard Kubecost window formats (See our docs on using [the `window` parameter](/apis/apis-overview.md#using-the-window-parameter)). Excluding this argument returns all audits in range.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}

```json
{
    "code": 200,
    "data": [
        {
            "allocationReconciliation": null,
            "allocationAgg": null,
            "allocationTotal": null,
            "assetTotal": null,
            "assetReconciliation": null,
            "clusterEquality": null,
            "window": {
                "start": "2022-10-21T00:00:00Z",
                "end": "2022-10-22T00:00:00Z"
            }
        },
        {
            "allocationReconciliation": {
                "Status": "Passed",
                "Description": "",
                "LastRun": "2023-01-17T21:16:30.918572742Z",
                "Resources": {},
                "MissingValues": null
            },
            "allocationAgg": {
                "Status": "Passed",
                "Description": "",
                "LastRun": "2023-01-17T21:13:44.013515987Z",
                "Results": {
                    "controller": {}
                },
                "MissingValues": null
            },
            "allocationTotal": {
                "Status": "Passed",
                "Description": "",
                "LastRun": "2023-01-17T21:13:44.014414659Z",
                "TotalByNode": {},
                "TotalByCluster": {},
                "MissingValues": null
            },
            "assetTotal": {
                "Status": "Passed",
                "Description": "",
                "LastRun": "2023-01-17T21:13:44.01496613Z",
                "TotalByNode": {},
                "TotalByCluster": {},
                "MissingValues": null
            },
            "assetReconciliation": {
                "Status": "Passed",
                "Description": "",
                "LastRun": "2023-01-17T21:13:44.015162953Z",
                "Results": {},
                "MissingValues": null
            },
            "clusterEquality": {
                "Status": "Failed",
                "Description": "",
                "LastRun": "2023-01-17T21:13:44.012261384Z",
                "Clusters": {
                    "cluster-one": {
                        "Expected": 9.423476639423004,
                        "Actual": 9.63847636882186
                    }
                },
                "MissingValues": null
            },
            "window": {
                "start": "2023-01-14T00:00:00Z",
                "end": "2023-01-15T00:00:00Z"
            }
        }
}
```

{% endswagger-response %}
{% endswagger %}

{% swagger method="post" path="/audit" baseUrl="https://<your-kubecost-address>/model/etl" summary="Audit API" %}
{% swagger-description %}
Runs audits defined by parameters
{% endswagger-description %}

{% swagger-parameter in="path" name="window" type="string" %}
Duration of time over which to query. Accepts all standard Kubecost window formats (See our docs on using [the `window` parameter](/apis/apis-overview.md#using-the-window-parameter)). Excluding this argument returns all audits in range.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="commit" type="boolean" %}
Must equal `true` if no value is provided for `window`, otherwise request will not confirm.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="type" type="string" %}
Must be a valid audit type (See the Audit types section below). Excluding this argument runs all audit types for the given window
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}

```json
{
    "code": 200,
    "data": "Running audit over window: [2023-01-16T20:23:08+0000, 2023-01-19T20:23:08+0000) for all audit types"
}
```

{% endswagger-response %}
{% endswagger %}

## Audit types

Audit types are optional parameters to filter your requests to audit select parts of your workload or perform additional actions. The endpoint for using an audit type will look like:

```http
https://<your-kubecost-address>/model/etl/audit?commit=true&type=<auditType>
```

| Audit type                      | Description                                                                                                                                                                           |
| ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `AuditAllocationReconciliation` | Tests that CPU, GPU and RAM cost totals by node from the Allocation store after reconciliation are equal to the values costs of each node in the Asset Store.                         |
| `AuditAllocationTotalStore`     | Detects divergence in the totaling of Allocation store and Total store by querying the Allocation store and comparing the totaled results against the contents of the total store     |
| `AuditAllocationTotalStore`     | Detects divergence in the aggregation of Allocation store and Agg store by querying the Allocation store and comparing the aggregated results against the contents of the total store |
| `AuditAllocationTotalStore`     | Tests that Assets have the same total cost as their corresponding CloudUsages                                                                                                         |
| `AuditAssetTotalStore`          | Detects divergence in the totaling of Asset store and Total store by querying the Asset store and comparing the totaled results against the contents of the total store               |
| `AuditClusterEquality`          | Tests that the aggregate by cluster of the asset store is equal to the aggregate by cluster of the reconciliation allocation store after idle and tenancy costs have been applied     |

### Return types

#### Base return types

The base return types are used by each Audit result to express any discrepancies that have been detected.

**Audit Missing Value**

Audit Missing Value denotes a value that was present in one data source and not another. The presence of this base result will generally result in a Warning status in the Audit that contains it. It contains a `Description` of the missing value and the `key` which acts as a way of identifying the missing value.

**Audit Float Result**

Audit Float Result represents a difference in float values between two data sources. The presence of this base result generally indicates a Failed status on the Audit. It contains an `Actual` value derived from the data source being audited and `Expected` value which is generated by the Audit itself.

#### Audit Results

Each Audit result contains the following values.

* `status`: gives the end result of the Audit as `Passed`, `Warning` or `Failure`
* `lastRun`: a timestamp of when the Audit was run
* `description`: a string describing the result of the audit. Generally used for failures in preliminary checks.
* `missingValues`: a `[]*AuditMissingValue` containing any values that were found to be missing during the audit

**Allocation Reconciliation Audit**

Allocation Reconciliation Audit records the differences of between compute resources (CPU, RAM, GPU) costs between allocations by nodes and node assets. It contains the additional fields:

* `resources`: A `map[string]map[string]*AuditFloatResult` records difference in resource values between asset and allocations. Keyed on node name and resource name

**Total Audit**

Total Audit records the differences between a total store and the totaled results of the store. It contains the additional fields:

* `totalByNode`: A `map[string]*AuditFloatResult` which records differences of calculated total by node. Keyed on node name
* `totalByCluster`: A `map[string]*AuditFloatResult` which records differences of calculated total by cluster. Keyed on cluster id

**Agg Audit**

Agg Audit contains the results of an Audit on an AggStore which checks if the aggregate of the store it draws from matches it.

* `results`: A `map[string]map[string]*AuditFloatResult` which records differences of calculated agg. Keyed on aggregation prop and allocation or asset key

**Asset Reconciliation Audit**

Asset Reconciliation Audit records differences in assets and the Cloud items that it is able to successfully match.

* `results`: A `map[string]map[string]*AuditFloatResult` which records differences in cloud assets and matched assets. Keyed on providerId and category

**Equality Audit**

Equality Audit records the difference in cost between Allocations and Assets aggregated by cluster and Keyed on cluster

* `clusters`: A `map[string]*AuditFloatResult` which records differences in allocations by cluster and assets by cluster. Keyed by cluster id
