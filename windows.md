Windows Node Support
======

Kubecost can run on clusters with mixed Linux and Windows nodes. The Kubecost pods must run on a Linux node.


## Deployment

When using a Helm install, this can be done simply with:

```sh
helm install kubecost \
--repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
--namespace kubecost --create-namespace \
-f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/cost-analyzer/values-windows-node-affinity.yaml
```

## Detail

The cluster must have at least 1 linux node for the Kubecost pods to run on:

  * Use a nodeSelector for all Kubecost deployments:

    ```
    spec:
      nodeSelector:
        kubernetes.io/os: linux
      containers:
    ```
  * For daemonsets, set the affinity to only allow scheduling on Windows nodes:
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

See the list of all deployments and daemonsets here: <https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values-windows-node-affinity.yaml>

## Metrics

  * Collecting data about windows nodes is supported by Kubecost as of v1.93.0.
  * Accurate node and pod data exist by default, since they come from the kubernetes API
  * Kubecost requires caadvisor for pod utilization data to determine costs at the container level.
  * Currently, for pods on Windows nodes- pods will be billed based on request size.
  * See https://github.com/google/cadvisor/issues/2170 for additional details.

<!--- {"article":"6152374933655","section":"1500002777682","permissiongroup":"1500001277122"} --->
