# Container Request Recommendation "Apply" APIs

:warning: This feature is in a pre-release (alpha/beta) state. It has limitations. Please read the documentation carefully. :warning:

The "Apply" API for request recommendations takes Kubecost's calculated
[container request recommendations](./api-request-right-sizing.md) and applies
them to your cluster. This allows you to instantly optimize resource allocation
across your entire cluster, without fiddling with excessive YAML or arcane
`kubectl` commands.

## Requirements

For the Apply APIs to be available, you must have Kubecost's Cluster Controller
[enabled](./controller.md). Cluster Controller contains Kubecost's automation
features, and thus has write permission to certain resources on your cluster. You
don't have to set up the in-cluster secret for a cloud provider service account
if you only want the 1-click request sizing "Apply" APIs, described in this doc,
to be available.

## APIs

Apply has dry-run semantics, meaning it is a two step process:
1. Plan what will happen
2. Execute the plan

### Plan

The Plan API is available at `http://kubecost.example.com/cluster/requestsizer/plan`. It expects a POST request with a body that is identical to a response from the [request right-sizing recommendation API](./api-request-right-sizing.md).

For example, using `curl`:

```sh
# Make to `kubectl port-forward -n kubecost service/kubecost-cost-analyzer 9090`
# or replace 'localhost:9090' with 'kubecost.example.com'

curl -XGET 'http://localhost:9090/model/savings/requestSizing' \
    -d 'window=2d' \
    |
    curl -H "Content-Type: application/json" \
        -XPOST \
        --data-binary @- \
        'http://localhost:9090/cluster/requestsizer/plan'
```

The API response can be inspected to see what Kubecost will attempt to do before
running the apply step. The plan may do less than the recommendation, see
Current Limitations.

```json
{
  "cluster-name": {
    "namespace-name": [
      {
        "Name": "controller-name-X",
        "Kind": "controller-kind-X",
        "ContainerPlans": {
          "container-name-X": {
            "TargetCPURequestMillicores": XX,
            "TargetRAMRequestBytes": XX,
          },
          ...
        }
      },
      ...
    ],
    ...
  },
  ...
}
```

### Apply

The Apply API is available at `http://kubecost.example.com/cluster/requestsizer/plan`. It expects a POST request with a body that is identical to a response from the Plan API.

For example, using `curl`:

```sh
# Make to `kubectl port-forward -n kubecost service/kubecost-cost-analyzer 9090`
# or replace 'localhost:9090' with 'kubecost.example.com'

curl -XGET 'http://localhost:9090/model/savings/requestSizing' \
    -d 'window=2d' \
    |
    curl -H "Content-Type: application/json" \
        -XPOST \
        --data-binary @- \
        'http://localhost:9090/cluster/requestsizer/plan' \
    |
    curl -H "Content-Type: application/json" \
        -XPOST \
        --data-binary @- \
        'http://localhost:9090/cluster/requestsizer/apply'
```

The API response includes the original plan, plus some metadata:

```json
{
  "TimeInitiated": "",
  "TimeFinished": "",
  
  "Errors": ["error message here"],
  "Warnings": ["non-failure warnings here"],
  "FromPlan": <the plan passed as argument>
}
```

## Current Limitations

- The Apply APIs only "size down," i.e. they will never increase a container requests, only lower them. This is currently done out of an abundance of caution while the APIs are being tested. We don't want to size up requests and cause a cluster that was running fine to run out of capacity, even if setting the requests to a higher level would provide better availability guarantees.

- The Apply APIs only support some controller kinds (Deployments, DaemonSets, StatefulSets, ReplicaSets) at the moment. This is planned to increase soon and is subject to change.

- The Apply APIs do not support sizing Pods without a controller. This is also planned to change.

- The Apply APIs do not support clusters other than the "local" cluster (the cluster that the instance of Kubecost you are interacting with via HTTP is running on). If you are interested in this functionality, please let us know.
