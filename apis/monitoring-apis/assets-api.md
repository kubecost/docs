# Assets API

{% swagger method="get" path="/assets" baseUrl="http://<your-kubecost-address>/model" summary="Assets API" %}
{% swagger-description %}
The Assets API retrieves backing cost data broken down by individual assets in your cluster but also provides various aggregations of this data.
{% endswagger-description %}

{% swagger-parameter in="path" name="window" type="string" required="true" %}
Duration of time over which to query. Accepts multiple different formats of time (see this [Using the `window` parameter](/apis/apis-overview.md#using-the-window-parameter) section for more info).
{% endswagger-parameter %}

{% swagger-parameter in="path" name="aggregate" type="string" required="false" %}
Used to consolidate cost model data. Supported values are `account`, `cluster`, `project`, `providerid`, `provider`, and `type`. Passing an empty value for this parameter or none at all returns data by an individual asset. Supports multi-aggregation (aggregation of multiple categories) in a comma separated list, such as `aggregate=account,project`.

{% endswagger-parameter %}

{% swagger-parameter in="path" name="accumulate" type="boolean" required="false" %}
When set to `false`, this endpoint returns daily time series data vs cumulative data. Default value is `false`.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="disableAdjustments" type="boolean" required="false" %}
When set to `true`, zeros out all adjustments from cloud provider reconciliation, which would otherwise change the `totalCost`. Default value is `false`.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="format" type="string" required="false" %}
When set to `csv`, will download an accumulated version of the asset results in CSV format. By default, results will be in JSON format.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="offset" type="int" required="false" %}
Refers to the number of line items you are offsetting. Pairs with `limit`. See the section on [Using `offset` and `limit` parameters to parse payload results](/apis/apis-overview.md#using-offset-and-limit-parameters-to-parse-payload-results) for more info.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="limit" type="int" required="false" %}
Refers to the number of line items per page. Pair with the `offset` parameter to filter your payload to specific pages of line items. You should also set `accumulate=true` to obtain a single list of line items, otherwise you will receive a group of line items per interval of time being sampled.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filter" type="string" required="false" %}
Filter your results by any category which you can aggregate by, can support multiple filterable items in the same category in a comma-separated list. For example, to filter results by projects A and B, use `filter=project:projectA,projectB`. See our [Filter Parameters](/apis/filters-api.md) doc for a complete explanation of how to use filters and what categories are supported.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
{% code overflow="wrap" %}
```javascript
  {
    cluster: "..."  // parent cluster for asset
    cpuCores: 1  // number of CPUs, given this is a node asset type
    cpuCost: 0.00 // cumulative cost of CPU measured over time window
    discount: 0.0 // discount applied to asset cost
    end: "2020-08-21T00:00:00+0000" // end of measured time window
    gpuCost: 0
    key: "..."
    name: "..."
    nodeType: "..."
    preemptible: 0
    providerID: "..."
    ramBytes: 0
    ramCost: 0.00
    start: "2020-08-20T00:00:00+0000"
    adjustment: 0.00 // amount added to totalCost during reconciliation with cloud provider data
    totalCost: 0.00 // total asset cost after applied discount
    type: "node" // e.g. node, disk, cluster management fee, etc
}
```
{% endcode %}
{% endswagger-response %}
{% endswagger %}

## API examples

Retrieve assets cost data for the past week, aggregated by type, and as cumulative object data:

{% tabs %}
{% tab title="Request" %}
```
http://localhost:9090/model/assets?window=1w&aggregate=type&accumulate=true
```
{% endtab %}

{% tab title="Response" %}
{% code overflow="wrap" %}
```json
{
    "code": 200,
    "data": [
        {
            "ClusterManagement": {
                "type": "ClusterManagement",
                "properties": {
                    "category": "Management",
                    "provider": "GCP",
                    "project": "guestbook-227502",
                    "service": "Kubernetes",
                    "cluster": "cluster-one"
                },
                "labels": {
                    "cost-center": "engineering",
                    "firebase": "enabled",
                    "namespace": "kubecost",
                    "test_gcp_label": "test_gcp_value"
                },
                "window": {
                    "start": "2023-07-18T00:00:00Z",
                    "end": "2023-07-25T00:00:00Z"
                },
                "start": "2023-07-18T00:00:00Z",
                "end": "2023-07-25T00:00:00Z",
                "minutes": 10080.000000,
                "totalCost": 16.105322
            },
            "Disk": {
                "type": "Disk",
                "properties": {
                    "category": "Storage",
                    "provider": "GCP",
                    "project": "guestbook-227502",
                    "service": "Kubernetes",
                    "cluster": "cluster-one"
                },
                "labels": {
                    "cost-center": "engineering",
                    "firebase": "enabled",
                    "namespace": "kubecost",
                    "test_gcp_label": "test_gcp_value"
                },
                "window": {
                    "start": "2023-07-18T00:00:00Z",
                    "end": "2023-07-25T00:00:00Z"
                },
                "start": "2023-07-18T00:00:00Z",
                "end": "2023-07-24T17:10:00Z",
                "minutes": 9670.000000,
                "byteHours": 80541516519424.000000,
                "bytes": 499740536831.999939,
                "byteHoursUsed": 1260838260792.807129,
                "byteUsageMax": null,
                "breakdown": {
                    "idle": 0.9800269272561808,
                    "other": 0,
                    "system": 0.019973072743819435,
                    "user": 0
                },
                "adjustment": -6.533317,
                "totalCost": 3.630275,
                "storageClass": "",
                "volumeName": "",
                "claimName": "",
                "claimNamespace": ""
            },
            "LoadBalancer": {
                "type": "LoadBalancer",
                "properties": {
                    "category": "Network",
                    "provider": "GCP",
                    "project": "guestbook-227502",
                    "service": "Kubernetes",
                    "cluster": "cluster-one",
                    "name": "ingress-nginx/ingress-nginx-controller",
                    "providerID": "35.202.154.180"
                },
                "labels": {
                    "cost-center": "engineering",
                    "firebase": "enabled",
                    "namespace": "kubecost",
                    "test_gcp_label": "test_gcp_value"
                },
                "window": {
                    "start": "2023-07-18T00:00:00Z",
                    "end": "2023-07-25T00:00:00Z"
                },
                "start": "2023-07-18T00:00:00Z",
                "end": "2023-07-24T17:10:00Z",
                "minutes": 9670.000000,
                "adjustment": 0.000000,
                "totalCost": 4.366667
            },
            "Network": {
                "type": "Network",
                "properties": {
                    "category": "Network",
                    "provider": "GCP",
                    "project": "guestbook-227502",
                    "service": "Kubernetes",
                    "cluster": "cluster-one"
                },
                "labels": {
                    "cost-center": "engineering",
                    "firebase": "enabled",
                    "goog-k8s-cluster-location": "us-central1-a",
                    "goog-k8s-cluster-name": "kc-integration-test",
                    "namespace": "kubecost",
                    "test_gcp_label": "test_gcp_value"
                },
                "window": {
                    "start": "2023-07-18T00:00:00Z",
                    "end": "2023-07-25T00:00:00Z"
                },
                "start": "2023-07-18T00:00:00Z",
                "end": "2023-07-23T00:00:00Z",
                "minutes": 7200.000000,
                "adjustment": -0.000000,
                "totalCost": 2.290521
            },
            "Node": {
                "type": "Node",
                "properties": {
                    "category": "Compute",
                    "provider": "GCP",
                    "project": "guestbook-227502",
                    "service": "Kubernetes",
                    "cluster": "cluster-one"
                },
                "labels": {
                    "cost-center": "engineering",
                    "firebase": "enabled",
                    "instance": "10.95.11.109:9003",
                    "job": "kubecost",
                    "label_app": "integration",
                    "label_beta_kubernetes_io_arch": "amd64",
                    "label_beta_kubernetes_io_os": "linux",
                    "label_cloud_google_com_gke_boot_disk": "pd-standard",
                    "label_cloud_google_com_gke_container_runtime": "docker",
                    "label_cloud_google_com_gke_cpu_scaling_level": "2",
                    "label_cloud_google_com_gke_logging_variant": "DEFAULT",
                    "label_cloud_google_com_gke_max_pods_per_node": "110",
                    "label_cloud_google_com_gke_os_distribution": "cos",
                    "label_department": "engineering",
                    "label_env": "test",
                    "label_failure_domain_beta_kubernetes_io_region": "us-central1",
                    "label_failure_domain_beta_kubernetes_io_zone": "us-central1-a",
                    "label_kubernetes_io_arch": "amd64",
                    "label_kubernetes_io_os": "linux",
                    "label_owner": "kubecost",
                    "label_product": "integration",
                    "label_team": "kubecost",
                    "label_topology_kubernetes_io_region": "us-central1",
                    "label_topology_kubernetes_io_zone": "us-central1-a",
                    "namespace": "kubecost",
                    "test_gcp_label": "test_gcp_value"
                },
                "window": {
                    "start": "2023-07-18T00:00:00Z",
                    "end": "2023-07-25T00:00:00Z"
                },
                "start": "2023-07-18T00:00:00Z",
                "end": "2023-07-24T17:10:00Z",
                "minutes": 9670.000000,
                "nodeType": "",
                "cpuCores": 6.000000,
                "ramBytes": 23876288511.999996,
                "cpuCoreHours": 967.000000,
                "ramByteHours": 3848061831850.666504,
                "GPUHours": 0.000000,
                "cpuBreakdown": {
                    "idle": 0.7816140688705785,
                    "other": 0.01327077839354095,
                    "system": 0.023247472082326824,
                    "user": 0.18186768065355347
                },
                "ramBreakdown": {
                    "idle": 0.9608696355583681,
                    "other": 0,
                    "system": 0.0044846381137333665,
                    "user": 0.034645726327898
                },
                "preemptible": 0.000000,
                "discount": 0.222016,
                "cpuCost": 59016.618816,
                "gpuCost": 0.000000,
                "gpuCount": 0.000000,
                "ramCost": 29194.865070,
                "adjustment": -68597.241975,
                "totalCost": 29.862398
            }
        }
    ]
}
```
{% endcode %}
{% endtab %}
{% endtabs %}

Retrieve all GCP costs, aggregated by asset type, in the past five days:

{% tabs %}
{% tab title="Request" %}
```
http://localhost:9090/model/assets?window=5d&aggregate=type&filterProviders=GCP
```
{% endtab %}

{% tab title="Response" %}
{% code overflow="wrap" %}
````json
{
    "code": 200,
    "data": [
        {
            "ClusterManagement": {
                "type": "ClusterManagement",
                "properties": {
                    "category": "Management",
                    "provider": "GCP",
                    "project": "guestbook-227502",
                    "service": "Kubernetes",
                    "cluster": "cluster-one"
                },
                "labels": {
                    "cost-center": "engineering",
                    "firebase": "enabled",
                    "namespace": "kubecost",
                    "test_gcp_label": "test_gcp_value"
                },
                "window": {
                    "start": "2023-07-20T00:00:00Z",
                    "end": "2023-07-21T00:00:00Z"
                },
                "start": "2023-07-20T00:00:00Z",
                "end": "2023-07-21T00:00:00Z",
                "minutes": 1440.000000,
                "totalCost": 2.400048
            },
            "Disk": {
                "type": "Disk",
                "properties": {
                    "category": "Storage",
                    "provider": "GCP",
                    "project": "guestbook-227502",
                    "service": "Kubernetes",
                    "cluster": "cluster-one"
                },
                "labels": {
                    "cost-center": "engineering",
                    "firebase": "enabled",
                    "namespace": "kubecost",
                    "test_gcp_label": "test_gcp_value"
                },
                "window": {
                    "start": "2023-07-20T00:00:00Z",
                    "end": "2023-07-21T00:00:00Z"
                },
                "start": "2023-07-20T00:00:00Z",
                "end": "2023-07-21T00:00:00Z",
                "minutes": 1440.000000,
                "byteHours": 11993772883968.000000,
                "bytes": 499740536832.000000,
                "byteHoursUsed": 186052795011.657166,
                "byteUsageMax": null,
                "breakdown": {
                    "idle": 0.9535106760775518,
                    "other": 0,
                    "system": 0.04648932392244791,
                    "user": 0
                },
                "adjustment": -0.125657,
                "totalCost": 0.508401,
                "storageClass": "",
                "volumeName": "",
                "claimName": "",
                "claimNamespace": ""
            },
            "LoadBalancer": {
                "type": "LoadBalancer",
                "properties": {
                    "category": "Network",
                    "provider": "GCP",
                    "project": "guestbook-227502",
                    "service": "Kubernetes",
                    "cluster": "cluster-one",
                    "name": "ingress-nginx/ingress-nginx-controller",
                    "providerID": "35.202.154.180"
                },
                "labels": {
                    "cost-center": "engineering",
                    "firebase": "enabled",
                    "namespace": "kubecost",
                    "test_gcp_label": "test_gcp_value"
                },
                "window": {
                    "start": "2023-07-20T00:00:00Z",
                    "end": "2023-07-21T00:00:00Z"
                },
                "start": "2023-07-20T00:00:00Z",
                "end": "2023-07-21T00:00:00Z",
                "minutes": 1440.000000,
                "adjustment": 0.000000,
                "totalCost": 0.650000
            },
            "Network": {
                "type": "Network",
                "properties": {
                    "category": "Network",
                    "provider": "GCP",
                    "project": "guestbook-227502",
                    "service": "Kubernetes",
                    "cluster": "cluster-one"
                },
                "labels": {
                    "cost-center": "engineering",
                    "firebase": "enabled",
                    "goog-k8s-cluster-location": "us-central1-a",
                    "goog-k8s-cluster-name": "kc-integration-test",
                    "namespace": "kubecost",
                    "test_gcp_label": "test_gcp_value"
                },
                "window": {
                    "start": "2023-07-20T00:00:00Z",
                    "end": "2023-07-21T00:00:00Z"
                },
                "start": "2023-07-20T00:00:00Z",
                "end": "2023-07-21T00:00:00Z",
                "minutes": 1440.000000,
                "adjustment": 0.000000,
                "totalCost": 0.462713
            },
            "Node": {
                "type": "Node",
                "properties": {
                    "category": "Compute",
                    "provider": "GCP",
                    "project": "guestbook-227502",
                    "service": "Kubernetes",
                    "cluster": "cluster-one"
                },
                "labels": {
                    "cost-center": "engineering",
                    "firebase": "enabled",
                    "goog-k8s-cluster-location": "us-central1-a",
                    "goog-k8s-cluster-name": "kc-integration-test",
                    "instance": "10.95.11.109:9003",
                    "job": "kubecost",
                    "label_app": "integration",
                    "label_beta_kubernetes_io_arch": "amd64",
                    "label_beta_kubernetes_io_os": "linux",
                    "label_cloud_google_com_gke_boot_disk": "pd-standard",
                    "label_cloud_google_com_gke_container_runtime": "docker",
                    "label_cloud_google_com_gke_cpu_scaling_level": "2",
                    "label_cloud_google_com_gke_logging_variant": "DEFAULT",
                    "label_cloud_google_com_gke_max_pods_per_node": "110",
                    "label_cloud_google_com_gke_os_distribution": "cos",
                    "label_department": "engineering",
                    "label_env": "test",
                    "label_failure_domain_beta_kubernetes_io_region": "us-central1",
                    "label_failure_domain_beta_kubernetes_io_zone": "us-central1-a",
                    "label_kubernetes_io_arch": "amd64",
                    "label_kubernetes_io_os": "linux",
                    "label_owner": "kubecost",
                    "label_product": "integration",
                    "label_team": "kubecost",
                    "label_topology_kubernetes_io_region": "us-central1",
                    "label_topology_kubernetes_io_zone": "us-central1-a",
                    "namespace": "kubecost",
                    "test_gcp_label": "test_gcp_value"
                },
                "window": {
                    "start": "2023-07-20T00:00:00Z",
                    "end": "2023-07-21T00:00:00Z"
                },
                "start": "2023-07-20T00:00:00Z",
                "end": "2023-07-21T00:00:00Z",
                "minutes": 1440.000000,
                "nodeType": "",
                "cpuCores": 6.000000,
                "ramBytes": 23876288512.000000,
                "cpuCoreHours": 144.000000,
                "ramByteHours": 573030924288.000000,
                "GPUHours": 0.000000,
                "cpuBreakdown": {
                    "idle": 0.7837941958332726,
                    "other": 0.01326423545472175,
                    "system": 0.022647815368734222,
                    "user": 0.18029375334327175
                },
                "ramBreakdown": {
                    "idle": 0.9616066744853431,
                    "other": 0,
                    "system": 0.0045971975313483845,
                    "user": 0.033796127983308416
                },
                "preemptible": 0.000000,
                "discount": 0.198807,
                "cpuCost": 4.552767,
                "gpuCost": 0.000000,
                "gpuCount": 0.000000,
                "ramCost": 2.258987,
                "adjustment": -1.113280,
                "totalCost": 4.344250
            }
        },
```              
````
{% endcode %}
{% endtab %}
{% endtabs %}

## Querying with `/topline` endpoint to view cost totals across query

`/topline` is an optional API endpoint which can be added to your Assets query via `.../model/assets/topline?window=...` to provide a condensed overview of your total cost metrics including all line items sampled. You will receive a single list which sums the values per all items queried (`totalCost`), where `numResults` displays the total number of items sampled.

```json
    "code": 200,
    "data": {
        "totalCost": ,
        "adjustment": ,
        "numResults": 
    }
}
```

## Enable CPU and RAM cost breakdown

Prometheus queries for CPU and RAM mode breakdown are disabled by default. To receive these metrics, you must manually enable them.

```yaml
kubecostModel:
  assetModeBreakdownEnabled: true
```

This will enable fields `ramBreakdown`, `cpuBreakdown`, and `breakdown` in the output of all future Assets queries.
