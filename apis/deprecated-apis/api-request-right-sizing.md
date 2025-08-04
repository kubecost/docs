# Container Request Right-Sizing Recommendation API (V1)

{% hint style="danger" %}
This API is now deprecated. This page should not be consulted. Please reference [Container Request Right-Sizing Recommendation API (v2)](/apis/savings-apis/api-request-right-sizing-v2.md) for updated information.
{% endhint %}

The container request right-sizing recommendation API provides recommendations for [container resource requests](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/) based on configurable parameters and estimates the savings from implementing those recommendations on a per-container, per-controller level. Of course, if the cluster-level resources stay static then you will likely not enjoy real savings from applying these recommendations until you reduce your cluster resources. Instead, your idle allocation will increase.

The endpoint is available at

```http
http://<kubecost-address>/model/savings/requestSizing
```

## Parameters

| Name                    | Type                     | Description                                                                                                                                                                                                                                                                                                                                                                                                                                                                 |
| ----------------------- | ------------------------ | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `targetCPUUtilization`  | float in the range (0,1] | An amount of headroom to enforce with the new request, based on the calculated (real) usage. If the calculated usage is, for example, 100 mCPU and this parameter is `0.8`, the recommended CPU request will be `100 / 0.8 = 125` mCPU. Inputs that fail to parse (see <https://pkg.go.dev/strconv#ParseFloat>) or are greater than 1 will not error; they will instead default to your savings profile's default value. If you have not changed the profile, this is `0.65`. |
| `targetRAMUtilization`  | float in the range (0,1] | Calculated like CPU.                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| `window`                | string                   | Duration of time over which to calculate usage. Supports hours or days before the current time in the following format: `2h` or `3d`.                                                                                        |
| `filterClusters`        | string                   | Comma-separated list of clusters to match; e.g. `cluster-one,cluster-two` will return results from only those two clusters.                                                                                                                                                                                                                                                                                                                                                 |
| `filterNodes`           | string                   | Comma-separated list of nodes to match; e.g. `node-one,node-two` will return results from only those two nodes.                                                                                                                                                                                                                                                                                                                                                             |
| `filterNamespaces`      | string                   | Comma-separated list of namespaces to match; e.g. `namespace-one,namespace-two` will return results from only those two namespaces.                                                                                                                                                                                                                                                                                                                                         |
| `filterLabels`          | string                   | Comma-separated list of annotations to match; e.g. `app:cost-analyzer, app:prometheus` will return results with either of those two label key-value-pairs.                                                                                                                                                                                                                                                                                                                  |
| `filterServices`        | string                   | Comma-separated list of services to match; e.g. `frontend-one,frontend-two` will return results with either of those two services.                                                                                                                                                                                                                                                                                                                                          |
| `filterControllerKinds` | string                   | Comma-separated list of controller kinds to match; e.g. `deployment,job` will return results with only those two controller kinds.                                                                                                                                                                                                                                                                                                                                          |
| `filterControllers`     | string                   | Comma-separated list of controllers to match; e.g. `deployment-one,statefulset-two` will return results from only those two controllers.                                                                                                                                                                                                                                                                                                                                    |
| `filterPods`            | string                   | Comma-separated list of pods to match; e.g. `pod-one,pod-two` will return results from only those two pods.                                                                                                                                                                                                                                                                                                                                                                 |
| `filterAnnotations`     | string                   | Comma-separated list of annotations to match; e.g. `name:annotation-one,name:annotation-two` will return results with either of those two annotation key-value-pairs.                                                                                                                                                                                                                                                                                                       |
| `filterContainers`      | string                   | Comma-separated list of containers to match; e.g. `container-one,container-two` will return results from only those two containers.                                                                                                                                                                                                                                                                                                                                         |

## Savings Projection Methodology

The request right-sizing recommendation includes an estimate of the savings that can be realized by applying the request right-sizing recommendations. To calculate this estimation, we use each container's lifetime and the overall data window (max observed cluster lifetime within `window`). We assume each container will run on the same node (and therefore have the same resource costs) it ran on historically; calculate the monthly rate for that container with the new, reduced resource requests; and then we scale that monthly rate by `container lifetime in window/data window`. This will underestimate savings for recently-created controllers (e.g. a Deployment created 3 days ago in a 7-day data window will be assumed to run for 3/7 of the next month when calculating monthly savings), but avoids some edge cases that vastly overestimate savings.

### Savings projection examples

#### Two Pods, each with their own controller

We have a 1 hour window with 2 pods that _look_ like they each have their own controller. Each pod has 1 container (with the same name).

All CPU costs are $7/core-hour

Pod 1 ran for 15 minutes \[t=15min, t=30min], allocated 3 cores, and used an avg and max of 1 core.

Pod 2 ran for 20 minutes \[t=45min, t=60min], allocated 3 cores, and used an avg and max of 2 cores.

```console
|   ---      | Pod 1 exists
|         ---| Pod 2 exists
|____________|
  time ->
|            |
0 min        60min
```

Window = \[0min, 60min]

We'll right-size with a target utilization of 100%:

* Pod 1 will be right-sized to an allocation of 1 core.
* Pod 2 will be right-sized to an allocation of 2 cores.

What should the estimated monthly savings of this right-sizing be?

Controller 1 = Pod 1 ran for (15/45) of the known duration of the cluster being alive (we don't know if it was alive from \[t=0, t=15]). That's (45 min / (60 min/hr) / (730 hr/month)) of a month.

Within the query window, the pod could have saved: 2 cores \* (15min / (60 min/hr)) = 0.5 core-hours 0.5 core-hours \* $7/core-hour = $3.50

"If that 45 minute window is representative for 30 days (730 hrs) then we scale the savings by 1 / (45 / 60 / 730)": $3.50 \* 1 / (45 / 60 / 730) = $3406.67

For Pod 2 = Controller 2 we can take the same numbers from Pod 1 = Controller 1 and halve the savings because it has half the CPU core savings.

Savings: $3406.67/mo / 2 = $1703.34/mo

Total savings = $3406.67/mo + $1703.34/mo = $5110.01/mo

#### The above, but the Pods share a controller

We resize the shared container to 2 cores, reducing the savings of pod 1 to be the same as the savings for pod 2, because both pods had the same overall allocation.

Controller 1 = Pod 1 and Pod 2 ran for 45/45 minutes of the known duration of the cluster being alive (we don't know if it was alive from \[t=0, t=15]). That's (45 min / (60 min/hr) / (730 hr/month)) of a month.

Within the query window, Pod 1 could have saved: 1 cores \* (15min / (60 min/hr)) = 0.25 core-hours 0.25 core-hours \* $7/core-hour = $1.75

Pod 2 saves the same amount = $1.75

That's a total savings for the controller of: $1.75 \* 2 = $3.50

"If that 45 minute window is representative for 30 days (730 hrs) then we scale the savings by 1 / (45 / 60 / 730)": Total savings = $3.50 \* 1 / (45 / 60 / 730) = $3406.67/mo

## API Examples

```bash
KUBECOST_ADDRESS=http://localhost:9090

curl -G \
  -d 'targetCPUUtilization=0.8' \
  -d 'targetRAMUtilization=0.8' \
  -d 'window=3d' \
  ${KUBECOST_ADDRESS}/model/savings/requestSizing
```
