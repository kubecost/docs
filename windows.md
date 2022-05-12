Windows Node Support

Windows nodes are partially supported by kubecost as of v1.93.0. Additional support is coming soon!
* Deployment
  * The cluster must have at least 1 linux node for the kubecost cost-model to run on
  * Taint the cost-model deployment's pods to run on this node, eg:
    ```
    spec:
      nodeSelector:
        kubernetes.io/os: linux
      containers:
    ```
  * Taint the network-costs and node-exporter daemonset to run on linux nodes only, if using network-costs and node-exporter, eg:
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

* Metrics
  * When tracked by the kubernetes API, nodes should show up with the correct number of pods and resources.
  * By default, we will be missing utilization data for pods on window nodes; pods will be billed based on request size.
  * Kubecost can be configured to pick up utilization data for windows nodes; cadvisor must run on these nodes and be scraped.
