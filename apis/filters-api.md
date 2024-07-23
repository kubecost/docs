# Filter Parameters (v2)

This document outlines the filtering language added to certain Kubecost APIs, superseding Kubecost's original filtering parameters (e.g. `filterNamespaces=`), now referred to as v1 filters. v2 filters introduce support for "not equals" (e.g. `namespace != kubecost`) queries while maintaining extensibility.

{% hint style="info" %}
v1 filters will continue to be supported in all relevant APIs. APIs will first check for the `filter=` parameter. If it is present, v2 filters will be used. If it is not present, APIs will attempt to use v1 filters.
{% endhint %}

## Using filters

v2 filters can be used via the `filter=` parameter in supported APIs. Supported APIs are currently:

* [Allocation API](/apis/monitoring-apis/api-allocation.md)
* [Assets API](/apis/monitoring-apis/assets-api.md)
* [Cloud Cost API](/apis/monitoring-apis/cloud-cost-api.md)
* [External Costs API](/apis/monitoring-apis/external-costs-api.md)
* [Allocation Trends API](/apis/monitoring-apis/allocation-trends-api.md)
* [Cloud Cost Trends API](/apis/monitoring-apis/cloud-cost-trends-api.md)
* [Request Sizing API](/apis/savings-apis/api-request-right-sizing-v2.md)

## Filtering fields

The available fields for filtering depend on the API being queried.

### Allocation APIs, Request Sizing v2 API

The supported filter fields are:

* `cluster`
* `node`
* `namespace`
* `controllerName`
* `controllerKind` (e.g. `deployment`, `daemonset`)
* `container`
* `pod`
* `services`
* `label`
* `annotation` (same syntax as label, see examples)
* `department`
* `environment`
* `owner`
* `product`
* `team`

### Assets API

v2 filter support for `/model/assets`:

* `name`
* `assetType` (e.g. `node`, `disk`, `network`, etc.)
* `category` (e.g. `Compute`, `Management`)
* `cluster`
* `project`
* `provider`
* `providerID`
* `account`
* `service`
* `label`

### Cloud Costs API

v2 filter support for `/model/cloudCost`:

* `accountID`
* `category`
* `invoiceEntityID`
* `provider`
* `providerID`
* `service`
* `label`

## Filter operators

The supported filter operators are:

* `:` Equality
  * For string fields (e.g. namespace): equality
  * For slice/array fields (e.g. services): slice contains at least one value equal (equivalent to `~:`)
  * For map fields (e.g. labels): map contains key (equivalent to `~:`)
* `!:` Inequality, or "not contains" if an array type
* `~:` Contains
  * For string fields: contains
  * For slice fields: slice contains at least one value equal (equivalent to `:`)
  * For map fields: map contains key (equivalent to `:`)
* `!~:` NotContains, inverse of `~:`
* `<~:` ContainsPrefix
  * For string fields: string starts with
  * For slice fields: slice contains at least one value that starts with
  * For map fields: map contains at least one key that starts with
* `!<~:` NotContainsPrefix, inverse of `<~:`
* `~>:` ContainsSuffix
  * For string fields: strings ends with
  * For slice fields: slice contains at least one value that ends with
  * For map fields: map contains at least one key that ends with
* `!~>:` NotContainsSuffix, inverse of `~>:`

Filter values are strings surrounded by `"`. Multiple values can be separated by commas `,`.

Individual filters can be joined by `+` (representing logical AND) or `|` (representing logical OR). To use `+` and `|` in the same filter expression, scope _must_ be denoted via `(` and `)`. See examples.

## Examples

Here are some example filters to see how the filtering language works:

* `namespace:"kubecost"+container:"cost-model"` Return only results that are in the `kubecost` namespace and are for the `cost-model` container.
* `cluster:"cluster-one"+label[app]:"cost-analyzer"` Return only results in cluster `cluster-one` that are labeled with `app=cost-analyzer`.
* `cluster!:"cluster-one"` Ignore results from cluster `cluster-one`
* `namespace:"kubecost","kube-system"` Return only results from namespaces `kubecost` and `kube-system`.
* `namespace!:"kubecost","kube-system"` Return results for all namespaces except `kubecost` and `kube-system`.

For example, in an Allocation query:

{% code overflow="wrap" %}
```
http://localhost:9090/model/allocation?window=1d&accumulate=true&aggregate=namespace&filter=cluster!:%22cluster-one%22
```
{% endcode %}

The format is essentially: `<filter field> <filter op> <filter value>`

```sh
curl -G 'localhost:9090/model/assets' \
    -d 'window=3d' \
    --data-urlencode 'filter=assetType:"disk"'
```

## Formal grammar and implementation

To see the filter language's formal grammar and lexer/parser implementation, check out OpenCost's [`pkg/filter21/ast`](https://github.com/opencost/opencost/tree/develop/core/pkg/filter/ast).
