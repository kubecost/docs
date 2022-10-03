# Kubecost core architecture overview

Below are the major components deployed with the [Kubecost helm chart](http://docs.kubecost.com/install), excluding certain Enterprise components such as durable storage:

1. **Kubecost Cost-Analyzer Pod**  
    a. Frontend -- runs Nginx and handles routing to Kubecost backend + Prometheus/Grafana  
    b. Cost-model -- provides cost allocation calculations and metrics, both reads and writes to Prometheus  
2. **Prometheus**  
    a. Prometheus server -- time-series data store for cost & health metrics  
    b. Kube-state-metrics -- provides Kubernetes API metrics, e.g. resource requests  
    c. Node-exporter -- provides node-level utilization metrics for right-sizing recommendations and cluster utilization  [Optional]  
    d. Pushgateway -- provides the ability for users to push new metrics to Prometheus [Optional]  
    e. Alertmanager -- used for custom alerts  [Optional] 
3. **Network costs** -- optional DaemonSet for collecting network metrics [learn more](https://github.com/kubecost/docs/blob/master/network-allocation.md)
4. **Grafana** -- provides supporting dashboards for Kubecost product 

Today, the core Kubecost product can be run with just components 1, 3a, and 3b.

See an overview of core components in this diagram:

![Architecture Overview](images/arch.png)


# Enterprise architecture overview

The most common implementation of durable storage in the Kubecost application is with [Thanos](https://thanos.io/). Below is a high-level reference for the required components. More information on each Thanos component can be found [here](https://thanos.io/tip/components/).

![Thanos Overview](images/thanos-architecture.png)
