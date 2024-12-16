# Windows Node Support

Kubecost can run on clusters with mixed Linux and Windows nodes. The Kubecost pods must run on a Linux node.

## Deployment

When using a Helm install, this can be done simply with:

{% code overflow="wrap" %}
```
helm install kubecost \
--repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
--namespace kubecost --create-namespace \
-f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-windows-node-affinity.yaml
```
{% endcode %}

## Detail

The cluster must have at least one Linux node for the Kubecost pods to run on:

Use a nodeSelector for all Kubecost deployments:

    ```
    spec:
      nodeSelector:
        kubernetes.io/os: linux
      containers:
    ```
For DaemonSets, set the affinity to only allow scheduling on Windows nodes:

    ```
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/os
                operator: In
                values:
                - linux
    ```

See the list of all deployments and DaemonSets in this [*values-windows-node-affinity.yaml*](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values-windows-node-affinity.yaml) file:

```
nodeSelector:
  kubernetes.io/os: linux

networkCosts:
  nodeSelector:
    kubernetes.io/os: linux

prometheus:
  server:
    nodeSelector:
      kubernetes.io/os: linux
  nodeExporter:
    enabled: true
    affinity:
      nodeAffinity:
        requiredDuringSchedulingIgnoredDuringExecution:
          nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/os
                operator: In
                values:
                - linux
grafana:
  nodeSelector:
    kubernetes.io/os: linux
```

## Metrics

* Collecting data about Windows nodes is supported by Kubecost
* Accurate node and pod data exists by default, since they come from the Kubernetes API.
* Kubecost requires cAdvisor for pod utilization data to determine costs at the container level.
* Currently, for pods on Windows nodes: pods will be billed based on request size.
