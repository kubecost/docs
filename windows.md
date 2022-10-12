Windows Node Support
======

# Deployment
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
Today, we cannot deploy Kubecost or data collection daemonsets to windows nodes.

# Metrics
Collecting data about windows nodes is supported by Kubecost as of v1.93.0.
  * Accurate node and pod data exist by default, since they come from the kubernetes API
  * By default, we will be missing utilization data for pods on window nodes; pods will be billed based on request size. Kubecost can be configured to pick up utilization data for windows nodes; cadvisor must run on these nodes and be scraped. That scrape will happen by default, however cadvisor running on the node is not necessarily guaranteed, see https://github.com/google/cadvisor/issues/2170

<!--- {"article":"6152374933655","section":"1500002777682","permissiongroup":"1500001277122"} --->