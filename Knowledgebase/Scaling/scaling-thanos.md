Scaling Thanos
==============

Thanos may over-utilize resources in under some circumstances causing eviction or pod rescheduling when using default deployment parameters. Increasing the resources available to Thanos as well as modifying the query configuration can help prevent this. 

 

Decrease [thanos-query](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values-thanos.yaml#L83) maxConcurrent parameter to 2:

```
maxConcurrent: 2
```

Increase the [thanos-query](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values-thanos.yaml#L81) timeout parameter to 10 minutes:

```
query: 
  enabled: true
  timeout: 10m
```

Increase the limits and requests for [thanos-query](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values-thanos.yaml#L86).

```
resources:
  limits:
    cpu: 2000m
    memory: 16Gi
  requests:
    cpu: 1000m
    memory: 16Gi
```

Increase the limits and requests for [thanos-store](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values-thanos.yaml#L76): 

```
resources:
  limits:
    cpu: 2000m
    memory: 32Gi
  requests:
    cpu: 2000m
    memory: 32Gi
```
