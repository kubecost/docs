V2 Filters
=========

This document outlines the filtering language added to the Allocation API in
v1.96 of Kubecost, superseding the original filtering parameters (e.g.
`filterNamespaces=`). One of the primary goals of the new filter language was
to introduce support for "not equals" (e.g. `namespace != kubecost`) queries
while maintaining extensibility.

> **Note**: V1 filters will continue to be supported in all relevant APIs. APIs will first
> check for the `filter=` parameter. If it is present, V2 filters will be used.
> If it is not present, APIs will attempt to use V1 filters.

## How to use V2 filters

V2 filters exist under the `filter=` parameter in supported APIs (initially,
just the Allocation APIs). Here are some example filters to give a feel for the
language:

- `namespace:"kubecost"+container:"cost-model"`
  Return only results that are in the `kubecost` namespace and are for the
  `cost-model` container.
- `cluster:"cluster-one"+label[app]="cost-analyzer"`
  Return only results in cluster `cluster-one` that are labeled with
  `app=cost-analyzer`.
- `cluster!:"cluster-one"`
  Ignore results from cluster `cluster-one`
- `namespace:"kubecost","kube-system"`
  Return only results from namespaces `kubecost` and `kube-system`.
- `namespace!:"kubecost","kube-system"`
  Return results for all namespaces except `kubecost` and `kube-system`.
  
For example, in an Allocation query:
```
http://localhost:9090/model/allocation?window=1d&accumulate=true&aggregate=namespace&filter=cluster!:%22cluster-one%22
```
  
## V2 filter overview
  
The format is essentially: `<filter field> <filter op> <filter value>`

The supported filter fields in v1.96 are:
- `cluster`
- `node`
- `namespace`
- `controllerName`
- `controllerKind` (e.g. `deployment`, `daemonset`)
- `container`
- `pod`
- `services`
- `label`
- `annotation` (same syntax as label, see examples)

The supported filter ops in v1.96 are:
- `:` (equality, or "contains" if an array type)
- `!:` (inequality, or "not contains" if an array type)

Filter values are strings surrounded by `"`. Multiple values can be separated by commas `,`, representing logical OR.

Each individual filter is separated by a `+`, representing logical AND.

## Formal grammar and implementation

To see the filter language's formal grammar and lexer/parser implementation, check out
OpenCost's [`pkg/util/allocationfilterutil/v2`](https://github.com/opencost/opencost/tree/develop/pkg/util/allocationfilterutil/v2).



