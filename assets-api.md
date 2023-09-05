# Assets API

{% swagger method="get" path="/assets" baseUrl="http://<your-kubecost-address>/model" summary="Assets API" %}
{% swagger-description %}
The Assets API retrieves backing cost data broken down by individual assets in your cluster but also provides various aggregations of this data.
{% endswagger-description %}

{% swagger-parameter in="path" name="window" required="true" type="string" %}
Dictates the applicable window for measuring historical asset cost.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="aggregate" type="string" required="false" %}
Used to consolidate cost model data. Supported aggregation types are cluster and type. Passing an empty value for this parameter, or not passing one at all, returns data by an individual asset.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="accumulate" type="boolean" required="false" %}
When set to 

`false`

, this endpoint returns daily time series data vs cumulative data. Default value is 

`false`

.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="disableAdjustments" type="boolean" required="false" %}
When set to 

`true`

, zeros out all adjustments from cloud provider reconciliation, which would otherwise change the 

`totalCost`

. Default value is 

`false`

.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="format" type="string" required="false" %}
When set to 

`csv`

, will download an accumulated version of the asset results in CSV format. By default, results will be in JSON format.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterAccounts" type="string" required="false" %}
Filter results by cloud account. 

_Requires cloud configuration._
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterCategories" type="string" required="false" %}
Filter results by asset category, such as 

`Network`

, 

`Management`

, 

`Compute`

, 

`Storage`

, or 

`Other`

.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterClusters" type="string" required="false" %}
Filter results by cluster ID, which is generated from 

`cluster_id`

 provided during installation.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterLabels" type="string" required="false" %}
Filter results by cloud label or cloud tag. For example, appending 

`&labels=deployment:kubecost-cost-analyzer`

 only returns assets with label 

`deployment=kubecost-cost-analyzer`

. Note that subparameter 

`:`

 symbols are required to denote 

`<labelKey>:<labelValue>`

 pairs.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterNames" type="string" required="false" %}
Filter results by asset name.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterProjects" type="string" required="false" %}
Filter results by cloud project ID. 

_Requires cloud configuration._
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterProviders" type="string" required="false" %}
Filter results by provider. For example, appending 

`&filterProviders=GCP`

 only returns assets belonging to provider 

`GCP`

. 

_Requires cloud configuration._
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterProviderIDs" type="string" required="false" %}
Filter results by provider ID individual to each cloud asset. For examples, go to the Assets page, select Breakdown by Item, and see the Provider ID column. 

_Requires cloud configuration._
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterServices" type="string" required="false" %}
Filter results by service. Examples include 

`Cloud Storage`

, 

`Kubernetes`

, 

`BigQuery`

.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterTypes" type="string" required="false" %}
Filter results by asset type. Examples include 

`Cloud`

, 

`ClusterManagement`

, 

`Node`

, 

`LoadBalancer`

, and 

`Disk`

.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="step" type="string" %}
Duration of each individual data metric across the 

`window`

. Accepts 

`1h`

, 

`1d`

, or 

`1w`

. If left blank, defaults to longest step duration available based on level of granularity of data represented by 

`window`

.
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

### Using `window` parameter:

Acceptable formats for using `window` parameter include:

* "15m", "24h", "7d", "48h", etc.
* "today", "yesterday", "week", "month", "lastweek", "lastmonth"
* "1586822400,1586908800", etc. (start and end unix timestamps)
* "2020-04-01T00:00:00Z,2020-04-03T00:00:00Z", etc. (start and end UTC RFC3339 pairs)

### Using filter parameters:

* Optional filter parameters take the format of `&<filter>=<value>`.
* Some filters require cloud configuration, which can be set at `<your-kubecost-address>/keyinstructions.html`
* Multiple filter selections evaluate as ANDs. Each filter selection accepts comma-separated values that evaluate as ORs.
  * For example, including both `filterClusters=cluster-one` and `filterNames=name1,name2` logically evaluates as `(cluster == cluster-one) && (name == name1 || name == name2)`
* All filters are case-sensitive except for `filterTypes`
* All filters accept wildcard filters denoted by a URL-encoded `*` suffix, except for `filterTypes` and the label key in `filterLabels`
  * For example, `filterProviderIDs=gke%2A` will return all assets with a `gke` string prefix in its Provider ID.
  * For example, `filterLabels=deployment%3Dkube%2A` will return all assets with `deployment` label value containing a `kube` prefix.
* Invalid filters return no assets.

## API examples

Retrieve assets cost data for the past week, aggregated by type, and as cumulative object data:

{% tabs %}
{% tab title="Request" %}
`http://localhost:9090/model/assets?window=1w&aggregate=type&accumulate=true`
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
`http://localhost:9090/model/assets?window=5d&aggregate=type&filterProviders=GCP`
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

## Enable CPU and RAM cost breakdown

As of v1.106, Prometheus queries for CPU and RAM mode breakdown are disabled by default. To receive these metrics, you must manually enable them by setting the Helm flag:

```
.Values.kubecostModel.assetModeBreakdownEnabled = true
```

This will enable fields `ramBreakdown`, `cpuBreakdown`, and `breakdown` in the output of all future Assets queries.
