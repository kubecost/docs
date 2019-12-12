## Core architecture overview

Below are the major components to the Kubecost helm chart:
  
1. **Kubecost Cost-Analyzer Pod**  
    a. Frontend that runs Nginx -- handles routing to Prometheus/Grafana   
    b. Kubecost server -- backend for API calls  
    c. Cost-model -- provides cost allocation calculations and metrics, reads/writes to Prometheus
2. **Cost-Analyzer Jobs** -- used for product alerts & email updates
3. **Prometheus**  
    a. Prometheus server -- time series data store for cost & health metrics  
    b. Kube-state-metrics -- provides Kubernetes requests and other core metrics  
    c. Prometheus-node-exporter -- provides node-level utilization metrics for right-sizing recommendations  
    d. Pushgateway -- ability to push new metrics to Prometheus  
    e. Alertmanager -- used for custom alerts  
4. **Network costs** -- optional daemonset for collecting network metrics
5. **Grafana** -- supporting dashboards 

Today, the core Kubecost product can be run with just components 1, 3a, 3b, 3c. 

See core components on this diagram:

![Architecture Overview](images/arch.png)

