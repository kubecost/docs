# Amazon Managed Service for Prometheus (AMP) Overview

## Overview

There are three methods to use Kubecost with AMP:

* [AWS Agentless AMP](/install-and-configure/advanced-configuration/custom-prom/kubecost-agentless-amp.md)
* [AWS Distro for Open Telemetry](/install-and-configure/advanced-configuration/custom-prom/kubecost-aws-distro-open-telemetry.md)
* [AMP with Kubecost Prometheus (`remote_write`)](/install-and-configure/advanced-configuration/custom-prom/amp-with-remote-write.md)

The below guide provide a high-level overview of using AMP with Kubecost. The links above provide detailed instructions for each method.

{% hint style="info" %}
Using AMP allows multi-cluster Kubecost with EKS-optimized licenses.
{% endhint %}

## Reference resources

* [What is Amazon Managed Service for Prometheus?](https://docs.aws.amazon.com/prometheus/latest/userguide/what-is-Amazon-Managed-Service-Prometheus.html)
* [IAM permissions and policies](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-and-IAM.html)

## Architecture

Kubecost utilizes AWS SigV4 proxy to securely communicate with AMP. It enables password-less authentication using service roles to reduce the risk of exposing credentials.

### Federated architecture

To support the large-scale infrastructure (over 100 clusters), Kubecost leverages a [Federated ETL architecture](/install-and-configure/install/multi-cluster/federated-etl/federated-etl.md). In addition to Amazon Prometheus Workspace, Kubecost stores its data in a streamlined format (ETL) and ships this to a central S3 bucket. Kubecost's ETL data is a computed cache based on Prometheus's metrics, from which users can perform all possible Kubecost queries. By storing the ETL data on an S3 bucket, this integration offers resiliency to your cost allocation data, improves the performance and enables high availability architecture for your Kubecost setup.

## Support

See the [troubleshooting section](aws-amp-integration.md#troubleshooting) of this article if you run into any errors while setting up the integration. For support from AWS, you can submit a support request through your existing [AWS support contract](https://aws.amazon.com/contact-us/).

## Add recording rules (optional)

You can add these recording rules to improve the performance. Recording rules allow you to precompute frequently needed or computationally expensive expressions and save their results as a new set of time series. Querying the precomputed result is often much faster than running the original expression every time it is needed. Follow [these AWS instructions](https://docs.aws.amazon.com/prometheus/latest/userguide/AMP-Ruler.html) to add the following rules:

{% code overflow="wrap" %}

```yaml
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

{% endcode %}

## Troubleshooting

The `RunDiagnostic` logs in the cost-model container will contain the most useful information.

```bash
kubectl logs -n kubecost deployments/kubecost-cost-analyzer cost-model |grep RunDiagnostic
```

Test to see if the Kubecost metrics are available using Grafana or exec into the Kubecost frontend to run a cURL against the AMP endpoint:

Grafana query:

```text
count({__name__=~".+"}) by (job)
```

Port-forward to cost-model:9090:

```bash
kubectl port-forward -n kubecost svc/kubecost-cost-analyzer 9090:9090
```

Direct link[localhost:9090](http://localhost:9090/grafana/explore?schemaVersion=1&panes=%7B%22muO%22%3A%7B%22datasource%22%3A%22PBFA97CFB590B2093%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22count%28%7B__name__%3D%7E%5C%22.%2B%5C%22%7D%29+by+%28job%29%22%2C%22range%22%3Atrue%2C%22instant%22%3Atrue%2C%22datasource%22%3A%7B%22type%22%3A%22prometheus%22%2C%22uid%22%3A%22PBFA97CFB590B2093%22%7D%2C%22editorMode%22%3A%22code%22%2C%22legendFormat%22%3A%22__auto%22%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-1h%22%2C%22to%22%3A%22now%22%7D%7D%7D&orgId=1)

Or exec command:

```bash
kubectl exec -i -t \
  deployments/kubecost-cost-analyzer \
  -c cost-analyzer-frontend -- \
  curl -G "0:9090/model/prometheusQuery" \
  --data-urlencode "query=node_total_hourly_cost"
```

Failure:

```json
{"status":"success","data":{"resultType":"vector","result":[]}}
```

Success:

```json
{
  "status": "success",
  "data": {
    "resultType": "vector",
    "result": [
      {
        "metric": {
          "__name__": "node_total_hourly_cost",
          "arch": "amd64",
          "cluster_id": "eks-integration",
          "instance": "ip-172-31-9-41.us-east-2.compute.internal",
          "instance_type": "m6a.xlarge",
          "job": "kubecost-metrics",
          "node": "ip-172-31-9-41.us-east-2.compute.internal",
          "provider_id": "aws:///us-east-2a/i-0d844bf800d01bde1",
          "region": "us-east-2"
        },
        "value": [
          1709403009,
          "0.1728077431907654"
        ]
      }
    ]
  }
}
```

-----------------------

The below queries must return data for Kubecost to calculate costs correctly.

For the queries below to work, set the environment variables:

```bash
KUBECOST_NAMESPACE=kubecost
KUBECOST_DEPLOYMENT=kubecost-cost-analyzer
CLUSTER_ID=YOUR_CLUSTER_NAME
```

1. Verify connection to AMP and that the metric for `container_memory_working_set_bytes` is available:

If you have set `kubecostModel.promClusterIDLabel`, you will need to change the query (`CLUSTER_ID`) to match the label (typically `cluster` or `alpha_eksctl_io_cluster_name`).

```bash
kubectl exec -i -t -n $KUBECOST_NAMESPACE \
  deployments/$KUBECOST_DEPLOYMENT -c cost-analyzer-frontend \
  -- curl "0:9090/model/prometheusQuery?query=container_memory_working_set_bytes\{CLUSTER_ID=\"$CLUSTER_ID\"\}"
```

The output should contain a JSON entry similar to the following.

The value of `cluster_id` should match the value of `kubecostProductConfigs.clusterName`.

```json
{
  "status": "success",
  "data": {
    "resultType": "vector",
    "result": [
      {
        "metric": {
          "__name__": "container_memory_working_set_bytes",
          "cluster_id": "qa-eks1",
          "alpha_eksctl_io_cluster_name": "qa-eks1",
          "alpha_eksctl_io_nodegroup_name": "qa-eks1-nodegroup",
          "beta_kubernetes_io_arch": "amd64",
          "beta_kubernetes_io_instance_type": "t3.medium",
          "beta_kubernetes_io_os": "linux",
          "eks_amazonaws_com_capacityType": "ON_DEMAND",
          "eks_amazonaws_com_nodegroup": "qa-eks1-nodegroup",
          "id": "/",
          "instance": "ip-10-10-8-66.us-east-2.compute.internal",
          "job": "kubernetes-nodes-cadvisor"
        },
        "value": [
          1697630036,
          "3043811328"
        ]
      }
    ]
  }
}
```

2. Verify Kubecost metrics are available in AMP:

```bash
kubectl exec -i -t -n $KUBECOST_NAMESPACE \
  deployments/$KUBECOST_DEPLOYMENT -c cost-analyzer-frontend \
  -- curl "0:9090/model/prometheusQuery?query=node_total_hourly_cost\{CLUSTER_ID=\"$CLUSTER_ID\"\}" \
 |jq
```

The output should contain a JSON entry similar to:

```json
{
  "status": "success",
  "data": {
    "resultType": "vector",
    "result": [
      {
        "metric": {
          "__name__": "node_total_hourly_cost",
          "cluster_id": "qa-eks1",
          "alpha_eksctl_io_cluster_name": "qa-eks1",
          "arch": "amd64",
          "instance": "ip-192-168-47-226.us-east-2.compute.internal",
          "instance_type": "t3.medium",
          "job": "kubecost"
        },
        "value": [
          1697630306,
          "0.04160104542160034"
        ]
      }
    ]
  }
}
```

If the above queries fail, check the following:

1. Check logs of the `sigv4proxy` container (may be the Kubecost deployment or Prometheus Server deployment depending on your setup):

```bash
kubectl logs deployments/$KUBECOST_DEPLOYMENT -c sigv4proxy --tail -1
```

In a working `sigv4proxy`, there will be very few logs.

Correctly working log output:

```console
time="2023-09-21T17:40:15Z" level=info msg="Stripping headers []" StripHeaders="[]"
time="2023-09-21T17:40:15Z" level=info msg="Listening on :8005" port=":8005"
```

2. Check logs in the `cost-model`` container for Prometheus connection issues:

```bash
kubectl logs deployments/$KUBECOST_DEPLOYMENT -c cost-model --tail -1 |grep -i err
```

Example errors:

```console
ERR CostModel.ComputeAllocation: pod query 1 try 2 failed: avg(kube_pod_container_status_running...
Prometheus communication error: 502 (Bad Gateway) ...
```
