# Asset Diff API

{% swagger method="get" path="assets/diff" baseUrl="http://{kubecost-addresss}/model/" summary="Asset Diff API" %}
{% swagger-description %}
The Asset Diff API provides a diff of two windows that returns all the added, removed, or cost changed assets from the later window (before parameter) to the earlier window (after parameter). This endpoint does a comparison of two asset sets in the given windows and accumulates the results.
{% endswagger-description %}

{% swagger-parameter in="path" name="before" required="true" type="String" %}
Duration in time of the past. Supports hours or days before the current time in the following format: `2h` or `3d`. `before` **must** be further in the past than `after` (e.g. `after=1d`, `before=1d offset 1d`)
{% endswagger-parameter %}

{% swagger-parameter in="path" name="after" required="true" type="String" %}
Duration in time closest to now. Supports hours or days before the current time in the following format: `2h` or `3d`. `after` **must** be closer to now than `before` (e.g. `before=1d offset 7d`, `after=1d offset 3d`)
{% endswagger-parameter %}

{% swagger-parameter in="path" name="costChangeRatio" type="float64" %}
Changes the ratio of cost changes when displaying 'Changed' types. e.g. `costChangeRatio=0.1` will display all assets that had a cost change of 0.1 (10%) or more. Defaults to 0.05 (5%).
{% endswagger-parameter %}

{% swagger-parameter in="path" name="aggregate" type="String" %}
Used to consolidate cost model data. Passing an empty value for this parameter, or not passing one at all, returns data by an individual asset.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterClusters" type="String" %}
Comma-separated list of clusters to match; e.g. `cluster-one,cluster-two` will return results from only those two clusters.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterNodes" type="String" %}
Comma-separated list of nodes to match; e.g. `node-one,node-two` will return results from only those two nodes.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterNamespaces" type="String" %}
Comma-separated list of namespaces to match; e.g. `namespace-one,namespace-two` will return results from only those two namespaces.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterLabels" type="String" %}
Comma-separated list of annotations to match; e.g. `app:cost-analyzer, app:prometheus` will return results with either of those two label key-value-pairs.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterServices" type="String" %}
Comma-separated list of services to match; e.g. `frontend-one,frontend-two` will return results from only those two services.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterControllerKinds" type="String" %}
Comma-separated list of controller kinds to match; e.g. `deployment,job` will return results with only those two controller kinds.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterControllers" type="String" %}
Comma-separated list of controllers to match; e.g. `deployment-one,statefulset-two` will return results from only those two controllers.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterPods" type="String" %}
Comma-separated list of pods to match; e.g. `pod-one,pod-two` will return results from only those two pods.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterAnnotations" type="String" %}
Comma-separated list of annotations to match; e.g. `name:annotation-one,name:annotation-two` will return results with either of those two annotation key-value-pairs.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="filterContainers" type="String" %}
Comma-separated list of containers to match; e.g. `container-one,container-two` will return results from only those containers.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}

```json
{
    ...
    "__undefined__/__undefined__/__undefined__/Storage/__undefined__/Disk/Kubernetes/gke-nick-dev-default-pool-d26dab9e-55qb/gke-nick-dev-default-pool-d26dab9e-55qb":
        {
            Entity: // this is a typical asset
                {
                    type: "Disk",
                    properties: {"category":"Storage","service":"Kubernetes","name":"...","providerID":"..."},
                    labels: {},
                    window: {"start":"2022-07-18T22:00:00Z","end":"2022-07-19T22:00:00Z"},
                    start: "2022-07-18T15:00:00-07:00",
                    end: "2022-07-19T14:43:00-07:00",
                    minutes: 1423.000000,
                    byteHours: 0.00,
                    bytes: 0.00,
                    breakdown: {"idle":0.00,"other":0,"system":0.00,"user":0},
                    adjustment: 0.00,
                    totalCost: 0.00
                },
            Kind: "added" // the type of change ("added", "removed", or "changed")
        }
    ...
}
```

{% endswagger-response %}
{% endswagger %}

## API Examples

Compare yesterday's assets to today's assets:

`http://localhost:9090/model/assets/diff?before=yesterday&after=today`

Compare assets from 5 days ago to assets from the last day:

`http://localhost:9090/model/assets/diff?before=1d offset 5d&after=1d`

Compare assets from last month to assets from this month:

`http://localhost:9090/model/assets/diff?before=lastmonth&after=month`

Compare assets on 07/01/2022 to assets on 07/06/2022:

`http://localhost:9090/model/assets/diff?before=2022-07-01T00:00:00Z,2022-07-02T00:00:00Z&after=2022-07-06T00:00:00Z,2022-07-07T00:00:00Z`

Compare yesterday's assets to today's assets, displaying all assets that have a total cost change of 10% or more:

`http://localhost:9090/model/assets/diff?before=yesterday&after=today&costChangeRatio=0.1`
