Below are the major components to the Kubecost helm chart:

1. **Grafana**
2. **Cost-Analyzer Pod**  
    a. Frontend that runs Nginx -- handles routing to Prometheus/Grafana   
    b. Kubecost server -- backend   
    c. Cost-model -- provides cost allocation calculations and metrics
3. **Cost-Analyzer Jobs** -- used for product alerts & email updates
4. **Prometheus**  
    a. Prometheus server -- time series data store for cost & health metrics  
    b. Kube-state-metrics -- provides Kubernetes requests and other core metrics  
    c. Pushgateway -- ability to push new metrics to Prometheus  
    d. Alertmanager -- used for custom alerts  
    e. Prometheus-node-exporter -- provides node-level utilization metrics  
5. **Network costs** -- optional daemonset for collecting network metrics

Today, the core Kubecost product can be run with just components 2, 4a, 4b, 4e. 
