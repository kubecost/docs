Grafana Cloud Integration for Kubecost
===========================

[Grafana Cloud](https://grafana.com/products/cloud/) is a composable observability platform, integrating metrics, traces and logs with Grafana. Customers can leverage the best open source observability software without the overhead of installing, maintaining, and scaling your observability stack.

This document walks through how to integrate the Grafana Cloud Prometheus metrics service with Kubecost.

## Prerequisites

- You have access to a running Kubernetes cluster
- You have created a Grafana Cloud account
- You have permissions to create Grafana Cloud API keys

## Step 1: Install the Grafana Agent on your cluster

Install the Grafana Agent for Kubernetes on your cluster. Follow the instructions provided in the [Grafana Agent for Kubernetes](https://grafana.com/docs/grafana-cloud/kubernetes/agent-k8s/k8s_agent_metrics/) section of the Grafana Cloud documentation.

## Step 2: Configure Kubecost scraping configuration for the Grafana Agent

Once you’ve set up the Grafana Agent, we’ll need to add some extra configuration to the way Grafana Cloud Prometheus service scrapes metrics, so that Kubecost can offer more accurate cost estimates.

Create a file called `extra_scrape_configs.yaml` with the following contents, replacing the `grafana_prometheus_remoteWrite_url`, `username` and `password` placeholders to match your Grafana Cloud details, which you’ll find by visiting your organization’s **Grafana Cloud Portal** -> **Prometheus** -> **Password/API key**:

```yaml
kind: ConfigMap
metadata:
  name: grafana-agent
apiVersion: v1
data:
  agent.yaml: |
    server:
      http_listen_port: 12345
    metrics:
      wal_directory: /tmp/grafana-agent-wal
      global:
        scrape_interval: 60s
        external_labels:
          cluster: cloud
      configs:
      - name: integrations
        remote_write:
        - url: <grafana_prometheus_remoteWrite_url>
          basic_auth:
            username: # API key name
            password: # API key password
        scrape_configs:
        - bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
          job_name: integrations/kubernetes/cadvisor
          kubernetes_sd_configs:
              - role: node
          metric_relabel_configs:
              - source_labels: [__name__]
@
```

Next, apply the changes in the same namespace as your Grafana Agent deployment:

```sh
$ kubectl apply extra_scrape_configs.yaml -n <namespace>
```

Re-start the Grafana Agent:

```sh
$ kubectl rollout restart deployment/grafana-agent -n <namespace>
```

## Step 3 (optional): Configure Kubecost recording rules for Grafana Cloud using cortextool

To set up recording rules in Grafana Cloud, download the [cortextool CLI utility](https://github.com/grafana/cortex-tools). While they are optional, they offer improved performance.

After installing the tool, go ahead and create a file called `kubecost_rules.yaml`:

```yaml
# kubecost_rules.yaml
namespace: "kubecost"
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

Then, making sure you are in the same directory as your `kubecost_rules.yaml`, load the rules using `cortextool`. Replace address with your Grafana Cloud’s Prometheus query URL.

```sh
cortextool rules load \
--address=<prometheus_url> \
--user=<grafana_cloud_userId> \
--id=<grafana_cloud_org> \
--key=<grafana_cloud_api_key>
```

Print out the rules to verify that they’ve been loaded correctly:

```sh
cortextool rules print \
--address=<prometheus_url> \
--user=<grafana_cloud_userId> \
--id=<grafana_cloud_org> \
--key=<grafana_cloud_api_key>
```

Re-start the Grafana Agent:

```sh
$ kubectl rollout restart deployment/grafana-agent -namespace <namespace>
```

## Step 4: Install Kubecost on the cluster (skip if installed)

If you haven’t yet installed Kubecost, install Kubecost using Helm 3, grabbing your Kubecost Token from our [installation guide](https://kubecost.com/install):

```sh
$ helm repo add kubecost https://kubecost.github.io/cost-analyzer/
$ helm install kubecost kubecost/cost-analyzer --namespace kubecost --set kubecostToken=<token>
```

## Step 5: Configure Kubecost to query metrics from Grafana Cloud

Grab your Grafana Cloud username and API key from Step 1, and create two files in your working directory, called `USERNAME` and `PASSWORD` respectively.

Then, generate a Kubernetes secret called `dbsecret` in the same namespace as Kubecost is installed. The namespace is typically `kubecost`.

```sh
$ kubectl create secret generic dbsecret -namespace kubecost --from-file=USERNAME --from-file=PASSWORD
```

Reload Kubecost, using the secret you’ve just created, and the Prometheus query URL that you can get from your organization’s **Grafana Cloud Console** -> **Prometheus** -> **Query Endpoint**:

```sh
$ helm upgrade kubecost kubecost/cost-analyzer --namespace kubecost --set global.prometheus.fqdn=<grafana_prometheus_query_url> --set global.prometheus.enabled=false --set global.prometheus.queryServiceBasicAuthSecretName=dbsecret
```

That’s it! By now, you should have successfully completed the Kubecost integration with Grafana Cloud.

Optionally, you can also add our [Kubecost Community Dashboard](https://grafana.com/grafana/dashboards/15714) to your Grafana Cloud organization to visualize your cloud costs in Grafana.

Edit this doc on [Github](https://github.com/kubecost/docs/blob/main/grafana-cloud-integration.md)

<!--- {"article":"","section":"4402815636375","permissiongroup":"1500001277122"} --->
