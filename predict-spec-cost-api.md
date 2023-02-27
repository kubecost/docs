# Spec Cost Prediction API

The `/model/prediction/speccost` API takes Kubernetes API Objects ("workloads")
as input and produces a cost impact prediction for them, including a diff if a
matching existing workload can be found in the cluster.

Currently supported workload types:
- Deployments
- StatefulSets
- Pods

## Calling the API

The endpoint accepts HTTP POST requests. It accepts the following query parameters:

| Parameter | Type | Description |
|-----------|------|-------------|
| `clusterID` | string (required) | The Kubecost cluster ID of the cluster in which the workloads will be deployed. Currently, this must be the same as the cluster ID of the Kubecost installation which is serving the `/speccost` endpoint. Support for multi-cluster is planned. |
| `defaultNamespace` | string (required) | The namespace in which namespace-scoped objects will be "deployed" to if no namespace is set in the standard metadata field of the object. |
| `window` | string (default `2d`) | The Kubecost data window used for determining resource costs fed into the cost prediction. |
| `noUsage` | bool (default `false`) | Set to `true` to ignore historical usage data (if it exists) when making the prediction. This is equivalent to making a prediction using only requests. |

The API requires that workloads be passed in the request body in YAML format and
that the `Content-Type` header be set to `application/yaml`. Multiple workloads
can be passed via separation with the standard `---` syntax.

### Example

```
read -r -d '' WL << EndOfMessage
apiVersion: apps/v1
kind: Deployment
metadata:
  name: michaelkc-cost-analyzer
  namespace: michaelkc
  labels:
    app: michaelkc-cost-analyzer
spec:
  replicas: 3
  selector:
    matchLabels:
      app: michaelkc-cost-analyzer
  template:
    metadata:
      labels:
        app: michaelkc-cost-analyzer
    spec:
      containers:
      - name: cost-model
        image: nginx:1.14.2
        resources:
          requests:
            cpu: "1m"
            memory: "1Mi"
      - name: cost-analyzer-frontend
        image: nginx:1.14.2
        resources:
          requests:
            cpu: "1m"
            memory: "1Mi"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: default-deployment
  labels:
    app: default-deployment
spec:
  replicas: 3
  selector:
    matchLabels:
      app: default-deployment
  template:
    metadata:
      labels:
        app: default-deployment
    spec:
      containers:
      - name: container-1
        image: nginx:1.14.2
        resources:
          requests:
            cpu: "10m"
            memory: "10Mi"
EndOfMessage

echo "${WL}" | \
    curl \
    -XPOST \
    'http://localhost:9090/model/prediction/speccost?clusterID=cluster-localrun-default&defaultNamespace=customdefault' \
    -H 'Content-Type: application/yaml' \
    --data-binary "@-" \
    | jq
    
[
  {
    "namespace": "michaelkc",
    "controllerKind": "deployment",
    "controllerName": "michaelkc-cost-analyzer",
    "costBefore": {
      "totalMonthlyRate": 0,
      "cpuMonthlyRate": 0,
      "ramMonthlyRate": 0,
      "gpuMonthlyRate": 0
    },
    "costAfter": {
      "totalMonthlyRate": 0.15658546875000004,
      "cpuMonthlyRate": 0.13848000000000005,
      "ramMonthlyRate": 0.018105468749999992,
      "gpuMonthlyRate": 0
    },
    "costChange": {
      "totalMonthlyRate": 0.15658546875000004,
      "cpuMonthlyRate": 0.13848000000000005,
      "ramMonthlyRate": 0.018105468749999992,
      "gpuMonthlyRate": 0
    }
  },
  {
    "namespace": "customdefault",
    "controllerKind": "deployment",
    "controllerName": "default-deployment",
    "costBefore": {
      "totalMonthlyRate": 0,
      "cpuMonthlyRate": 0,
      "ramMonthlyRate": 0,
      "gpuMonthlyRate": 0
    },
    "costAfter": {
      "totalMonthlyRate": 0.7829273437500001,
      "cpuMonthlyRate": 0.6924000000000001,
      "ramMonthlyRate": 0.09052734374999996,
      "gpuMonthlyRate": 0
    },
    "costChange": {
      "totalMonthlyRate": 0.7829273437500001,
      "cpuMonthlyRate": 0.6924000000000001,
      "ramMonthlyRate": 0.09052734374999996,
      "gpuMonthlyRate": 0
    }
  }
]
```

Note how `defaultNamespace` impacts the `default-deployment` workload.
