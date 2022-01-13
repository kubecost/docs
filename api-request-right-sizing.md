Container Request Right-Sizing API
==================================

The container request right-sizing API provides recommendations for
[container resource requests](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
based on configurable parameters and estimates the savings from implementing those recommendations
on a per-container, per-controller level. Of course, if the cluster-level resources stay static then
you will likely not enjoy real savings from applying these recommendations until you reduce
your cluster resources. Instead, your idle allocation will increase.

The endpoint is available at
```
http://<kubecost-address>/model/savings/requestSizing
```

## Parameters


| Name | Type | Description |
|------|------|-------------|
| `targetCPUUtilization` | float in the range (0,1] | An amount of headroom to enforce with the new request, based on the calculated (real) usage. If the calculated usage is, for example, 100 mCPU and this parameter is `0.8`, the recommended CPU request will be `100 / 0.8 = 125` mCPU. Inputs that fail to parse (see https://pkg.go.dev/strconv#ParseFloat) or are greater than 1 will not error; they will instead default to your savings profile's default value. If you have not changed the profile, this is  `0.65`.|
| `targetRAMUtilization` | float in the range (0,1] | Calculated like CPU. |
| `window` | string | Duration of time over which to calculate usage. Supports hours or days before the current time in the following format: `2h` or `3d`. See the [Allocation API documentation](https://github.com/kubecost/docs/blob/master/allocation.md#querying) for more a more detailed explanation of valid inputs to `window`. |
| `filterClusters` | string | Comma-separated list of clusters to match; e.g. `cluster-one,cluster-two` will return results from only those two clusters. |
| `filterNodes` | string | Comma-separated list of nodes to match; e.g. `node-one,node-two` will return results from only those two nodes. |
| `filterNamespaces` | string | Comma-separated list of namespaces to match; e.g. `namespace-one,namespace-two` will return results from only those two namespaces. |
| `filterLabels` | string | Comma-separated list of annotations to match; e.g. `app:cost-analyzer, app:prometheus` will return results with either of those two label key-value-pairs. |
| `filterServices` | string | Comma-separated list of services to match; e.g. `frontend-one,frontend-two` will return results with either of those two services. |
| `filterControllerKinds` | string | Comma-separated list of controller kinds to match; e.g. `deployment,job` will return results with only those two controller kinds. |
| `filterControllers` | string | Comma-separated list of controllers to match; e.g. `deployment-one,statefulset-two` will return results from only those two controllers. |
| `filterPods` | string | Comma-separated list of pods to match; e.g. `pod-one,pod-two` will return results from only those two pods. |
| `filterAnnotations` | string | Comma-separated list of annotations to match; e.g. `name:annotation-one,name:annotation-two` will return results with either of those two annotation key-value-pairs. |
| `filterContainers` | string | Comma-separated list of containers to match; e.g. `container-one,container-two` will return results from only those two containers. |


## Savings Projection Methodology

The request right-sizing recommendation includes an estimate of the savings that can be realized
by applying the request right-sizing recommendations. To calculate this estimation, we use each
container's and its parent controller's (Deployment, CronJob, etc.) lifetime in `window`. We assume
each container will run on the same node (and therefore have the same resource costs) it ran on
historically; calculate the monthly rate for that container with the new, reduced resource requests;
and then we scale that monthly rate by `container lifetime in window/controller lifetime in window`.
Using the controller's lifetime helps to avoid underestimating savings for recently-created controllers.
If the container doesn't have a controller (e.g. it is in a raw Pod) then the `window` duration is
substituted for the controller lifetime.

This logic for estimation assumes that the proportion of time that each container ran
historically will be the same proportion of time it will run in the future projected month. We think
this is an effective and easy-to-understand methodology.

Here are a few limited examples to illustrate the principle. Assume `window=7d` for all queries.

1. A Deployment created 1 day ago whose Pods have not churned (restarted, etc.)

   Each of Deployment's container's lifetime will be the same as the controller's lifetime, so
   the calculated monthly rate won't need to be scaled down. In other words, the projected
   savings assumes each container under the Deployment will run for a whole month.

2. A CronJob created 5 days ago which runs a single-container Pod for 1 hour, once a day

   Assuming the CronJob has run 5 times, 5 containers have run (one for each
   Pod created by the CronJob). Each container's raw monthly cost is scaled by `1 / 24 / 5`.

3. A 3-replica Deployment of a single-container Pod created a month ago whose container image
   was updated 2 days ago

   The 3 containers that were running pre-image update will have their projected monthly cost
   scaled by `5 / 7` and the 3 containers that were running post-image update will have their
   projected monthly cost scaled by `2 / 7`.

## Examples

```
KUBECOST_ADDRESS=http://localhost:9090

curl -G \
  -d 'targetCPUUtilization=0.8' \
  -d 'targetRAMUtilization=0.8' \
  -d 'window=3d' \
  ${KUBECOST_ADDRESS}/model/savings/requestSizing
```

Edit this doc on [Github](https://github.com/kubecost/docs/blob/main/api-request-right-sizing.md)

<!--- {"article":"4407595919895","section":"4402829033367","permissiongroup":"1500001277122"} --->