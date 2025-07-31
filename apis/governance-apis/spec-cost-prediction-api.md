# Spec Cost Prediction API

{% swagger method="post" path="/model/prediction/speccost" baseUrl="http://<your-kubecost-address>" summary="Predict API" %}
{% swagger-description %}
The Predict API takes Kubernetes API objects ("workloads") as input and produces a cost impact prediction for them, including a diff if a matching existing workload can be found in the cluster.
{% endswagger-description %}

{% swagger-parameter in="query" name="clusterID" type="string" required="true" %}
The Kubecost cluster ID of the cluster in which the workloads will be deployed. Currently, this must be the same as the cluster ID of the Kubecost installation which is serving the `/speccost` endpoint. Support for multi-cluster is planned.
{% endswagger-parameter %}

{% swagger-parameter in="query" required="true" name="defaultNamespace" type="string" %}
The namespace in which namespace-scoped objects will be "deployed" to if no namespace is set in the standard metadata field of the object.
{% endswagger-parameter %}

{% swagger-parameter in="query" name="window" type="string" %}
Duration of time over which to query. Accepts multiple different formats of time (see this [Using the `window` parameter](/apis/apis-overview.md#using-the-window-parameter) section for more info). Default value is `2d`.
{% endswagger-parameter %}

{% swagger-parameter in="query" name="noUsage" type="boolean" %}
Set to `true` to ignore historical usage data (if it exists) when making the prediction. This is equivalent to making a prediction using only requests.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
```json
{
    "code": 200,
    "data": [
    {
      "namespace": "kubecost",
      "controllerKind": "deployment",
      "controllerName": "kubecost-cost-analyzer",
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
    }
  ]
}
```
{% endswagger-response %}
{% endswagger %}

The API requires that workloads be passed in the request body in YAML or JSON format. If using YAML, multiple workloads can be passed via separation with the standard `---` syntax. If using JSON, multiple workloads can be passed via the standard "list" format used by Kubernetes (e.g. `kubectl get deployment -A -o json`).

Currently supported workload types:

* Deployments
* StatefulSets
* Pods

### Example

Write some Kubernetes specs to a file called `/tmp/testspecs.yaml`:

```bash
read -r -d '' WL << EndOfMessage
apiVersion: apps/v1
kind: Deployment
metadata:
  name: kubecost-cost-analyzer
  namespace: kubecost
  labels:
    app: kubecost-cost-analyzer
spec:
  replicas: 3
  selector:
    matchLabels:
      app: kubecost-cost-analyzer
  template:
    metadata:
      labels:
        app: kubecost-cost-analyzer
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

Call the endpoint with cURL, passing the file in the request body:

{% tabs %}
{% tab title="Request" %}
<pre data-overflow="wrap"><code><strong>curl
</strong>-XPOST
'http://localhost:9090/model/prediction/speccost?clusterID=cluster-one&#x26;defaultNamespace=customdefault'
-H 'Content-Type: application/yaml'
--data-binary "@/tmp/testspecs.yaml"
| jq
</code></pre>
{% endtab %}

{% tab title="Response" %}
```json
[
  {
    "namespace": "kubecost",
    "controllerKind": "deployment",
    "controllerName": "kubecost-cost-analyzer",
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
{% endtab %}
{% endtabs %}

The output will be broken down into three primary categories:

* `costBefore`: Represents the current monthly cost. This will be `0` if the deployment is not currently running.
* `costAfter`: The monthly cost after the change is applied.
* `costChange`: The difference between the values of `costBefore` and `costAfter`. If the value of `costBefore` was `0`, then `costChange` should be equal to `costAfter`.

Observe how `defaultNamespace` impacts the `default-deployment` workload.

From that output, `costChange`notices the existing `kubecost-cost-analyzer` deployment in the `kubecost` namespace and is producing an estimated _negative_ cost difference because the request is being reduced. However, because historical usage is also factored in, there is no drastic cost reduction that might be initially expected from a `1m` CPU and `1Mi` memory request.

For how to use the predictions API in a use case preventing cost overruns before they occur, see the guide [here](/using-kubecost/proactive-cost-controls.md).

## Use cases

For an example use case on how to use predictions to achieve proactive cost control, see [here](/using-kubecost/proactive-cost-controls.md).
