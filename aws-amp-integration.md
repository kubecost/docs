Amazon Managed Service for Prometheus
==================

[Amazon Managed Service for Prometheus (AMP)](https://docs.aws.amazon.com/prometheus/index.html) is a Prometheus-compatible monitoring service that makes it easy to monitor containerized applications at scale.

Integrating AMP with Kubecost follows a workflow that is similar to integrating Kubecost with any [Custom Prometheus](https://docs.kubecost.com/custom-prom.html).

## 1. Set up a Prometheus with Amazon Managed Service for Prometheus (AMP) and Kubecost

You should first have successfully created an AMP workspace and ingesting Prometheus metrics into it, and have installed Kubecost, separately.

- [AMP Getting Started User Guide](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-getting-started.html)
- [Kubecost Installation Guide](https://docs.kubecost.com/install)

## 2. Set up Kubecost to use your Prometheus configured with Amazon Managed Service for Prometheus (AMP)

First, download the [values file](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) and set [`prometheus.enabled`](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml#L4) to `false`, and [`prometheus.fqdn`](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml#L5) to the URL of your Prometheus service address, starting with `http://`. Note that this address is _not_ your AMP remote write URL but your Prometheus cluster address, e.g. `http://prometheus-server.prometheus.svc.cluster.local`.

Then, navigate to the directory of the file and apply the changes by running the following `helm` command:

```
# replace the namespace and filename if needed
$ helm upgrade --install kubecost kubecost/cost-analyzer --namespace kubecost -f ./values.yaml
```

Verify that Kubecost is using the Prometheus server configured to remote write metrics to AMP rather than Kubecost's default Prometheus installation by forwarding Kubecost to a local port and querying the `/api` endpoint:

```
# replace `kubecost` and `deployment/kubecost-cost-analyzer` if needed
$ kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090

# in another Terminal window
$ curl http://localhost:9090/api/
```

The first line returned by the `curl` command should contain your `fqdn` parameter URL, like so:

```
Using Prometheus at http://prometheus-server.prometheus.svc.cluster.local.
```

Seek help in our [troubleshooting guide](https://docs.kubecost.com/custom-prom.html#troubleshooting-issues) or [reach out to us on Slack](https://join.slack.com/t/kubecost/shared_invite/zt-1dz4a0bb4-InvSsHr9SQsT_D5PBle2rw) if you run into any issues.

## 3. Set up your Prometheus to scrape metrics from Kubecost

First, create a file called `extra_scrape_configs.yaml` with the following contents, replacing `<your_kubecost_namespace>` with your Kubecost namespace:

```
- job_name: kubecost
  honor_labels: true
  scrape_interval: 1m
  scrape_timeout: 10s
  metrics_path: /metrics
  scheme: http
  dns_sd_configs:
    - names:
        - kubecost-cost-analyzer.<your_kubecost_namespace>
      type: "A"
      port: 9003

```

Then, add these recording rules as `serverFiles` to the Prometheus `override_values.yaml` override file. While they are optional, they offer improved performance.

```
serverFiles:
  rules:
    groups:
      - name: CPU
        rules:
          - expr: sum(rate(container_cpu_usage_seconds_total{container_name!=""}[5m]))
            record: cluster:cpu_usage:rate5m
          - expr: rate(container_cpu_usage_seconds_total{container_name!=""}[5m])
            record: cluster:cpu_usage_nosum:rate5m
          - expr: avg(irate(container_cpu_usage_seconds_total{container_name!="POD", container_name!=""}[5m])) by (container_name,pod_name,namespace)
            record: kubecost_container_cpu_usage_irate
          - expr: sum(container_memory_working_set_bytes{container_name!="POD",container_name!=""}) by (container_name,pod_name,namespace)
            record: kubecost_container_memory_working_set_bytes
          - expr: sum(container_memory_working_set_bytes{container_name!="POD",container_name!=""})
            record: kubecost_cluster_memory_working_set_bytes
      - name: Savings
        rules:
          - expr: sum(avg(kube_pod_owner{owner_kind!="DaemonSet"}) by (pod) * sum(container_cpu_allocation) by (pod))
            record: kubecost_savings_cpu_allocation
            labels:
              daemonset: "false"
          - expr: sum(avg(kube_pod_owner{owner_kind="DaemonSet"}) by (pod) * sum(container_cpu_allocation) by (pod)) / sum(kube_node_info)
            record: kubecost_savings_cpu_allocation
            labels:
              daemonset: "true"
          - expr: sum(avg(kube_pod_owner{owner_kind!="DaemonSet"}) by (pod) * sum(container_memory_allocation_bytes) by (pod))
            record: kubecost_savings_memory_allocation_bytes
            labels:
              daemonset: "false"
          - expr: sum(avg(kube_pod_owner{owner_kind="DaemonSet"}) by (pod) * sum(container_memory_allocation_bytes) by (pod)) / sum(kube_node_info)
            record: kubecost_savings_memory_allocation_bytes
            labels:
              daemonset: "true"
```

Lastly, apply the changes:

```
$ helm upgrade --install prometheus-for-amp prometheus-community/prometheus -n prometheus -f ./override_values.yaml \
--set-file extraScrapeConfigs=extra_scrape_configs.yaml
```

To check that the rules were applied successfully, run Kubecost locally and check that `Prometheus Status` on the Settings page indicates `Kubecost recording rules available in Prometheus` and `Kubecost cost-model metrics available in Prometheus`.

```
# replace `kubecost` and `deployment/kubecost-cost-analyzer` if needed
$ kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090
```

Et voilà!

---

To verify that the integration is set up, check that the `Prometheus Status` section on Kubecost Settings page does not contain any errors.

![Prometheus status screenshot](https://user-images.githubusercontent.com/22844059/132998278-fd388e9a-8d61-4b8b-ad1c-0e52f17ca251.png)

Have a look at the [Custom Prometheus integration troubleshooting guide](https://docs.kubecost.com/custom-prom.html#troubleshooting-issues) if you run into any errors while setting up the integration. You're also welcome to [reach out to us on Slack](https://join.slack.com/t/kubecost/shared_invite/zt-1dz4a0bb4-InvSsHr9SQsT_D5PBle2rw) if you require further assistance.

Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/aws-amp-integration.md)


<!--- {"article":"4409859798679","section":"4402829036567","permissiongroup":"1500001277122"} --->
