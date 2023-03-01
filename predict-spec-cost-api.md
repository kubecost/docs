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

Write some Kubernetes specs to a file called `/tmp/testspecs.yaml`:
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

echo "${WL}" > /tmp/testspecs.yaml
```

Call the endpoint with `curl`, passing the file in the request body:
```
curl \
    -XPOST \
    'http://localhost:9090/model/prediction/speccost?clusterID=cluster-one&defaultNamespace=customdefault' \
    -H 'Content-Type: application/yaml' \
    --data-binary "@/tmp/testspecs.yaml" \
    | jq
```

The output:
```json
[
  {
    "namespace": "michaelkc",
    "controllerKind": "deployment",
    "controllerName": "michaelkc-cost-analyzer",
    "costBefore": {
      "totalMonthlyRate": 3.5397661399108418,
      "cpuMonthlyRate": 2.3273929838395513,
      "ramMonthlyRate": 1.2123731560712905,
      "gpuMonthlyRate": 0,
      "monthlyCPUCoreHours": 73,
      "monthlyRAMByteHours": 304653271040,
      "monthlyGPUHours": 0
    },
    "costAfter": {
      "totalMonthlyRate": 2.623504800996625,
      "cpuMonthlyRate": 0.6283961056366789,
      "ramMonthlyRate": 1.9951086953599462,
      "gpuMonthlyRate": 0,
      "monthlyCPUCoreHours": 19.71,
      "monthlyRAMByteHours": 501344315550,
      "monthlyGPUHours": 0
    },
    "costChange": {
      "totalMonthlyRate": -0.9162613389142167,
      "cpuMonthlyRate": -1.6989968782028724,
      "ramMonthlyRate": 0.7827355392886557,
      "gpuMonthlyRate": 0,
      "monthlyCPUCoreHours": -53.29,
      "monthlyRAMByteHours": 196691044510,
      "monthlyGPUHours": 0
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
      "gpuMonthlyRate": 0,
      "monthlyCPUCoreHours": 0,
      "monthlyRAMByteHours": 0,
      "monthlyGPUHours": 0
    },
    "costAfter": {
      "totalMonthlyRate": 0.7896028064135204,
      "cpuMonthlyRate": 0.6982178951518654,
      "ramMonthlyRate": 0.09138491126165506,
      "gpuMonthlyRate": 0,
      "monthlyCPUCoreHours": 21.9,
      "monthlyRAMByteHours": 22963814400,
      "monthlyGPUHours": 0
    },
    "costChange": {
      "totalMonthlyRate": 0.7896028064135204,
      "cpuMonthlyRate": 0.6982178951518654,
      "ramMonthlyRate": 0.09138491126165506,
      "gpuMonthlyRate": 0,
      "monthlyCPUCoreHours": 21.9,
      "monthlyRAMByteHours": 22963814400,
      "monthlyGPUHours": 0
    }
  }
]
```

> Note how `defaultNamespace` impacts the `default-deployment` workload.

We can see from that output that the diff (`costChange`) notices our existing
`kubecost-cost-analyzer` Deployment in the `kubecost` namespace and is producing
an estimated _negative_ cost difference because our request is being reduced.
However, because historical usage is also factored in, we aren't seeing the
expected drastic reduction from a `1m` and `1Mi` request.
