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
When set to `false`, this endpoint returns daily time series data vs cumulative data. Default value is `false`.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="disableAdjustments" type="boolean" required="false" %}
When set to `true`, zeros out all adjustments from cloud provider reconciliation, which would otherwise change the totalCost. Default value is `false`.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="format" type="string" required="false" %}
When set to `csv`, will download an accumulated version of the asset results in CSV format. By default, results will be in JSON format.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterAccounts" type="string" required="false" %}
Filter results by cloud account. _Requires cloud configuration._
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterCategories" type="string" required="false" %}
Filter results by asset category, such as `Network`, `Management`, `Compute`, `Storage`, or `Other`.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterClusters" type="string" required="false" %}
Filter results by cluster ID, which is generated from `cluster_id` provided during installation.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterLabels" type="string" required="false" %}
Filter results by cloud label or cloud tag. For example, appending `&labels=deployment:kubecost-cost-analyzer` only returns assets with label `deployment=kubecost-cost-analyzer`. Note that subparameter `:` symbols are required to denote `<labelKey>:<labelValue>` pairs.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterNames" type="string" required="false" %}
Filter results by asset name.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterProjects" type="string" required="false" %}
Filter results by cloud project ID. _Requires cloud configuration._
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterProviders" type="string" required="false" %}
Filter results by provider. For example, appending `&filterProviders=GCP` only returns assets belonging to provider `GCP`. _Requires cloud configuration._
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterProviderIDs" type="string" required="false" %}
Filter results by provider ID individual to each cloud asset. For examples, go to the Assets page, select Breakdown by Item, and see the Provider ID column. _Requires cloud configuration._
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterServices" type="string" required="false" %}
Filter results by service. Examples include `Cloud Storage`, `Kubernetes`, `BigQuery`.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterTypes" type="string" required="false" %}
Filter results by asset type. Examples include `Cloud`, `ClusterManagement`, `Node`, `LoadBalancer`, and `Disk`.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
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

Retrieve assets cost data for the past seven days, aggregated by type, and as cumulative object data:

{% tabs %}
{% tab title="Request" %}
`http://localhost:9090/model/assets?window=7d&aggregate=type&accumulate=true`
{% endtab %}

{% tab title="Response" %}
```json
{
    "code": 200,
    "data": [
        { 
            "Cloud": {
  // Note that cloud will move to https://docs.kubecost.com/apis/apis-overview/cloud-cost-api
                "type": "Cloud",
                "properties": {
                    "provider": "GCP",
                    "account": "01AC9F-74CF1D-5565A2"
                },
                "labels": {},
                "window": {
                    "start": "2023-01-03T00:00:00Z",
                    "end": "2023-01-10T00:00:00Z"
                },
                "start": "2023-01-03T00:00:00Z",
                "end": "2023-01-09T05:00:00Z",
                "minutes": 8940.000000,
                "adjustment": 0.000000,
                "credit": -37.799792,
                "totalCost": 2494.201159
            },
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
                    "firebase": "enabled",
                    "namespace": "kubecost",
                    "test_gcp_label": "test_gcp_value"
                },
                "window": {
                    "start": "2023-01-03T00:00:00Z",
                    "end": "2023-01-10T00:00:00Z"
                },
                "start": "2023-01-03T00:00:00Z",
                "end": "2023-01-10T00:00:00Z",
                "minutes": 10080.000000,
                "totalCost": 16.296993
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
                    "firebase": "enabled",
                    "namespace": "kubecost",
                    "test_gcp_label": "test_gcp_value"
                },
                "window": {
                    "start": "2023-01-03T00:00:00Z",
                    "end": "2023-01-10T00:00:00Z"
                },
                "start": "2023-01-03T00:00:00Z",
                "end": "2023-01-09T19:06:00Z",
                "minutes": 9786.000000,
                "byteHours": 48176821506867.203125,
                "bytes": 295382106112.000000,
                "byteHoursUsed": 701875686596.947632,
                "byteUsageMax": null,
                "breakdown": {
                    "idle": 0.9379000878645455,
                    "other": 0,
                    "system": 0.0620999121354546,
                    "user": 0
                },
                "adjustment": 0.000000,
                "totalCost": 2.494985,
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
                    "cluster": "cluster-one"
                },
                "labels": {
                    "firebase": "enabled",
                    "namespace": "kubecost",
                    "test_gcp_label": "test_gcp_value"
                },
                "window": {
                    "start": "2023-01-03T00:00:00Z",
                    "end": "2023-01-10T00:00:00Z"
                },
                "start": "2023-01-03T00:00:00Z",
                "end": "2023-01-09T19:06:00Z",
                "minutes": 9786.000000,
                "adjustment": 0.000000,
                "totalCost": 8.155000
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
                    "firebase": "enabled",
                    "instance": "10.95.11.109:9003",
                    "job": "kubecost",
                    "label_app": "integration",
                    "label_beta_kubernetes_io_arch": "amd64",
                    "label_beta_kubernetes_io_os": "linux",
                    "label_cloud_google_com_gke_boot_disk": "pd-standard",
                    "label_cloud_google_com_gke_container_runtime": "docker",
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
                    "start": "2023-01-03T00:00:00Z",
                    "end": "2023-01-10T00:00:00Z"
                },
                "start": "2023-01-03T00:00:00Z",
                "end": "2023-01-09T19:06:00Z",
                "minutes": 9786.000000,
                "nodeType": "",
                "cpuCores": 6.000000,
                "ramBytes": 23881949184.000000,
                "cpuCoreHours": 978.600000,
                "ramByteHours": 3895145911910.399902,
                "GPUHours": 0.000000,
                "cpuBreakdown": {
                    "idle": 0.8786219902310968,
                    "other": 0.0013172388726963124,
                    "system": 0.016174278350509344,
                    "user": 0.1038864925456978
                },
                "ramBreakdown": {
                    "idle": 0.9551354180444207,
                    "other": 0,
                    "system": 0.011233367196352187,
                    "user": 0.03363121475922688
                },
                "preemptible": 0.000000,
                "discount": 0.198803,
                "cpuCost": 30.939847,
                "gpuCost": 0.000000,
                "gpuCount": 0.000000,
                "ramCost": 15.355342,
                "adjustment": 0.000000,
                "totalCost": 37.091556
            }
        }
    ]
}
```
{% endtab %}
{% endtabs %}

Retrieve all AWS S3 assets cost data for the past seven days.

{% tabs %}
{% tab title="Request" %}
`http://localhost:9090/model/assets?window=7d&filterServices=AmazonS3"`
{% endtab %}

{% tab title="Response" %}
```json
{
  "code": 200,
  "data": [
    {
       "AWS/< REDACTED >/__undefined__/Storage/__undefined__/Cloud/AmazonS3/cloud-bench-1/__undefined__": {
        "type": "Cloud",
        "properties": {
          "category": "Storage",
          "provider": "AWS",
          "account": "< REDACTED >",
          "service": "AmazonS3",
          "providerID": "cloud-bench-1"
        },
        "labels": {
          "kubernetes_label_app": "product-test",
          "test_tag": "test_value_mod_2"
        },
        "window": {
          "start": "2023-02-01T00:00:00Z",
          "end": "2023-02-02T00:00:00Z"
        },
        "start": "2023-02-01T00:00:00Z",
        "end": "2023-02-02T00:00:00Z",
        "minutes": 1440,
        "adjustment": 0,
        "credit": 0,
        "totalCost": 9.1e-05
      },
      "AWS/< REDACTED >/__undefined__/Storage/__undefined__/Cloud/AmazonS3/cloud-bench-scale/__undefined__": {
        "type": "Cloud",
        "properties": {
          "category": "Storage",
          "provider": "AWS",
          "account": "< REDACTED >",
          "service": "AmazonS3",
          "providerID": "cloud-bench-scale"
        },
        "labels": {
          "kubernetes_label_app": "product-test",
          "test_tag": "test_value_mod_2"
        },
        "window": {
          "start": "2023-02-01T00:00:00Z",
          "end": "2023-02-02T00:00:00Z"
        },
        "start": "2023-02-01T00:00:00Z",
        "end": "2023-02-02T00:00:00Z",
        "minutes": 1440,
        "adjustment": 0,
        "credit": 0,
        "totalCost": 0.013967
      },
      "AWS/< REDACTED >/__undefined__/Storage/__undefined__/Cloud/AmazonS3/csv-cur-hourly-new/__undefined__": {
        "type": "Cloud",
        "properties": {
          "category": "Storage",
          "provider": "AWS",
          "account": "< REDACTED >",
          "service": "AmazonS3",
          "providerID": "csv-cur-hourly-new"
        },
        "labels": {
          "kubernetes_label_app": "product-test",
          "test_tag": "test_value_mod_2"
        },
        "window": {
          "start": "2023-02-01T00:00:00Z",
          "end": "2023-02-02T00:00:00Z"
        },
        "start": "2023-02-01T00:00:00Z",
        "end": "2023-02-02T00:00:00Z",
        "minutes": 1440,
        "adjustment": 0,
        "credit": 0,
        "totalCost": 0.000535
      },
   ...
```
{% endtab %}
{% endtabs %}
