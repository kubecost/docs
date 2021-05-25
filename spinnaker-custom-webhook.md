## Custom Webhook to Create a Kubecost stage in Spinnaker

Adding the below to Spinnaker will enable a custom stage to query Kubecost for recommendations on a container.
More info on [Spinnaker custom webhooks](https://spinnaker.io/guides/operator/custom-webhook-stages/#creating-a-custom-webhook-stage)

```
webhook:
  preconfigured:
  - label: "Kubecost: Get Sizing"
    type: getRequestSizing
    enabled: true
    description: Custom stage to get request sizing for a running container
    method: POST
    url: "${parameterValues['kubecost_url']}"
    payload: |-
      {
        "container_name": "${parameterValues['container_name']}",
        "controller_type": "${parameterValues['controller_type']}",
        "name": "${parameterValues['name']}",
        "namespace": "${parameterValues['namespace']}",
        "percentile": "${parameterValues['percentile']}",
        "target_cpu_util": "${parameterValues['target_cpu_utilization']}",
        "target_ram_util": "${parameterValues['target_ram_utilization']}",
        "window": "${parameterValues['time_window']}"
      }
      parameters:
      - label: "Kubecost API URL"
        name: kubecost_url
        description: "Fully qualified Url to the requestSizing api"
        type: string
      - label: "Controller Type"
        name: controller_type
        description: "What type of Kubernetes controller [deployment or statefulset]"
        type: string
      - label: "Controller Name"
        name: name
        description: "Name of the controller"
        type: string
      - label: "Container Name"
        name: container_name
        description: "Name of the container within the deployment"
        type: string
      - label: "Namespace"
        name: namespace
        description: "Namespace where controller and container are running"
        type: string
      - label: "Percentile Target"
        name: percentile
        description: "Target percentile for the recommendation"
        type: string
        defaultValue: 0.98
      - label: "Target CPU Utilization"
        name: target_cpu_utilization
        description: "Target CPU utilization for the recommendation"
        type: string
        defaultValue: 0.65
      - label: "Target RAM Utilization"
        name: target_ram_utilization
        description: "Target RAM utilization for the recommendation"
        type: string
        defaultValue: 0.65
      - label: "Time Window"
        name: time_window
        description: "Time window to look back to build recommendation [format: xd]"
        type: string
        defaultValue: "7d"
```