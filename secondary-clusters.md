Kubecost Secondary Clusters
===========================

Teams that run Kubecost Enterprise with a unified multi-cluster view may choose to run Kubecost in “agent-mode” on non-Master clusters. This means that the Kubecost deployment on these clusters can be operated in a mode where they are only collecting metrics and sending to centralized durable storage. 

It’s worth noting that Kubecost and it’s accompanying Prometheus always collect a reduced set of metrics that allow for lower resource consumption than a standard Prometheus deployment. The following configuration options further reduce resource consumption when not using the Kubecost frontend:

Disable product caching with the following parameters:

```
kubecostModel.warmCache=false kubecostModel.warmSavingsCache=false
kubecostModel.etl=false
```

Note: disabling these has UI performance implications

Disable grafana by setting

```
global.grafana.enabled=false && global.grafana.proxy=false
```

When using durable storage…

Set prometheus.server.retention to < 7d, can go down to under 1d if not viewing UI on this cluster

Potentially reduce prometheus.server.persistentVolume.size depending on scale, or outright disable persistent storage

Disable thanos.query and thanos.store components (more info)

Reduce Prometheus query concurrency with  `prometheus.server.extraArgs.query.max-concurrency=1` if using Kubecost bundled Prometheus or directly in our product if using an external Prometheus/Thanos/Cortex ([values flag](https://github.com/kubecost/cost-analyzer-helm-chart/blob/19908983ed7c8d4ff1d3e62d98537a39ab61bbab/cost-analyzer/values.yaml#L99))


For reference, here’s a sample list of helm set command line arguments when running Kubecost in agent mode:

```
--set kubecostModel.warmCache=false 
--set kubecostModel.warmSavingsCache=false
--set kubecostModel.etl=false
--set prometheus.server.retention=”2d”
--set prometheus.alertmanager.enabled=false
```

There are potentially other configuration options based on the specifics of different deployment requirements. Reach out to team@kubecost.com if you have any questions!

Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/secondary-clusters.md)


<!--- {"article":"4423256582551","section":"4402829033367","permissiongroup":"1500001277122"} --->
