# Filter Parameters (v2)

This document outlines the filtering language added to the Allocation API in v1.96 of Kubecost, superseding the original filtering parameters (e.g. `filterNamespaces=x&filterClusters=y`). One of the primary goals of the new filter language was to introduce support for "not equals" (e.g. `namespace != kubecost`) queries while maintaining extensibility.

In v1.105 of Kubecost, v2 filters received a backwards-compatible upgrade to
v2.1, adding support for label/annotation aliases (e.g. Product, Owner, etc.)
and "wildcards" (`*` in v1 filters, replaced with specific prefix/suffix
operators).

> **Note**: V1 filters will continue to be supported in all relevant APIs. APIs will first check for the `filter=` parameter. If it is present, V2 filters will be used. If it is not present, APIs will attempt to use V1 filters.

## Filters overview

The supported filter fields in v1.96 of Kubecost are:
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

Added in v1.105 of Kubecost:
* `department`
* `environment`
* `owner`
* `product`
* `team`

The supported filter ops in v1.96 of Kubecost are:
* `:` Equality
  * For string fields (e.g. namespace): equality
  * For slice/array fields (e.g. services): slice contains at least one value equal (equivalent to `~:`)
  * For map fields (e.g. labels): map contains key (equivalent to `~:`)
* `!:` Inequality, or "not contains" if an array type

Added in v1.105 of Kubecost:
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

Individual filters can be joined by `+` (representing logical AND) or `|`
(represenging logical OR). To use `+` and `|` in the same filter expression,
scope _must_ be denoted via `(` and `)`. See examples.

## Using filters

V2 filters can be used via the `filter=` parameter in supported APIs. Supported
APIs are currently:

* [Allocation API](allocation.md)
* [Request Sizing APIs](api-request-right-sizing-v2.md) 

### Examples

Here are some example filters to see how the filtering language works:
* `namespace:"kubecost" + container:"cost-model"` Return only results that are in the `kubecost` namespace and are for containers named `cost-model`.
* `label[app]:"cost-analyzer"` Return only results that are [labeled](https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/) with `app=cost-analyzer`
* `cluster:"cluster-one","cluster-two"` Return only results from clusters `cluster-one` and `cluster-two`.
* `label~:app` Return results which have the `app` label, regardless of the value associated with that label.
* `label[app]:"cost-analyzer" | label[app]<~:"kube"` Return results for which the `app` label is set to `cost-analyzer` or have an `app` label set to a value which starts with `kube`.
* `namespace!:"kube-system","infra" + owner:"team1","team2"` Return results which have an "owner" property equal to `team1` or `team2`, ignoring results in the `kube-system` and `infra` namespaces.
* `namespace:"kube-system" | label[app]:"infra-team" | (cluster:"infra-cluster" + product!:"kubecost")` (note that `|` and `+` must appear in different `()` scopes) Return results that match at least one of the following conditions:
  * in the `kube-system` namespace
  * labeled with `app=infra-team`
  * in the `infra-cluster` cluster but aren't in the `kubecost` "product"

#### Example API query

Pure HTTP string:
```
http://localhost:9090/model/allocation?window=1d&accumulate=true&aggregate=namespace&filter=cluster!:%22cluster-one%22
```

With `curl`:
```sh
curl -G 'localhost:9090/model/allocation' \
    -d 'window=1d' \
    --data-urlencode 'filter=cluster:"cluster-one" + label[app]:"cost-analyzer"'
```

## Formal grammar and implementation

To see the v2 filter language's grammar and lexer/parser implementation, check out OpenCost's [pkg/filter21/ast](https://github.com/opencost/opencost/tree/develop/pkg/filter21/ast). 

