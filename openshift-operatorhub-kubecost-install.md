Deploy Kubecost from Red Hat Openshift’s OperatorHub.
==================

## Overview:

The OperatorHub is available via the Red Hat OpenShift Container Platform web console and is the interface that cluster administrators use to discover and install Operators. With one click, an Operator can be pulled from their off-cluster source, installed and subscribed on the cluster, and made ready for engineering teams to self-service manage the product across deployment environments using the Operator Lifecycle Manager (OLM). Kubecost is now available on the [Embedded OperatorHub in OpenShift and OKD](https://github.com/redhat-openshift-ecosystem/community-operators-prod/tree/main/operators)

This document provides instructions for deploying Kubecost into Red Hat Openshift 4.9.x or higher using Red Hat Openshift platform (OCP) web console. Kubecost's operator on the [Embedded OperatorHub in OpenShift and OKD](https://github.com/redhat-openshift-ecosystem/community-operators-prod/tree/main/operators) is an alternative to [Kubecost Free version](https://guide.kubecost.com/hc/en-us/articles/8292513994903-OpenCost-Product-Comparison). Kubecost's operator uses an Operator pattern to deploy and manage the Kubecost deployment on the Red Hat Openshift platform.

![Standard deployment](https://raw.githubusercontent.com/kubecost/docs/main/images/ocp-standard.png)

## Prerequisites:

- You need to have an existing OCP cluster version 4.9.x or higher.
- You have appropriate access to that OpenShift cluster to create a new project and deploy new workloads.

## Discover Kubecost operator:

1. Log in to your OCP cluster web console.
2. Select Operators > OperatorHub > Enter Kubecost in the search box.
3. Create a namespace named Kubecost:

```bash
kubectl create namespace kubecost
```

Example screenshot:

![Discovery](https://raw.githubusercontent.com/kubecost/docs/main/images/ocp-operator-discovery.png)

## Deploy Kubecost:

### **Step 1:** Install Kubecost operator

On the OperatorHub page, find Kubecost, then click install. You will be on the Operator Installation page, which shows all related information. Select your desired version and settings, then click `Install`

![Installation step 1a](https://raw.githubusercontent.com/kubecost/docs/main/images/ocp-operator-installation-step-1.png)

The installation takes 1-2 minutes to be completed. A dialog will appear as in the following example screenshot:

![Installation step 1b](https://raw.githubusercontent.com/kubecost/docs/main/images/ocp-operator-installation-step-1b.png)

You can click on `View Operators` to review the details as in the following screenshot:

![Installation step 1b](https://raw.githubusercontent.com/kubecost/docs/main/images/ocp-operator-installation-step-1c.png)

Kubecost operator is now installed successfully. Next, you can start to install Kubecost using the custom resources definition (CRD)

### Step 2: Create a CRD to deploy Kubecost:

- You can customize the CRD definition similarly to the custom values file when deploying with Helm chart.
- After creating a CRD file, apply it to deploy Kubecost:

```bash
kubectl apply -f example-crd.yaml -n kubecost
```
  
- Example CRD to deploy Kubecost on OCP cluster

<details>
  <summary>Click to see code</summary>

```yaml
apiVersion: charts.kubecost.com/v1alpha1
kind: CostAnalyzer
metadata:
  name: kubecost
spec:
  # Default values copied from <project_dir>/helm-charts/cost-analyzer/values.yaml
  openshiftDeployment: true
  affinity: {}
  awsstore:
    createServiceAccount: false
    useAwsStore: false
  clusterController:
    enabled: false
    image: gcr.io/kubecost1/cluster-controller:v0.1.0
    imagePullPolicy: Always
  extraVolumeMounts: []
  extraVolumes: []
  kubecostProductConfigs:
    clusterName: your-ocp-cluser
  prometheus:
    nodeExporter:
      enabled: false
    serviceAccounts:
      nodeExporter:
        create: false
    kube-state-metrics:
      disabled: true
    server:
      global:
        external_labels:
          cluster_id: your-ocp-cluser
  global:
    additionalLabels: {}
    assetReports:
      enabled: false
      reports:
      - accumulate: false
        aggregateBy: type
        filters:
        - property: cluster
          value: your-ocp-cluser
        title: Example Asset Report 0
        window: today
    grafana:
      domainName: cost-analyzer-grafana.default.svc
      enabled: false
      proxy: false
      scheme: http
    notifications:
      alertmanager:
        enabled: false
        fqdn: http://cost-analyzer-prometheus-server.default.svc
    podAnnotations: {}
    prometheus:
      enabled: true
      fqdn: http://cost-analyzer-prometheus-server.default.svc
    savedReports:
      enabled: false
      reports:
      - accumulate: false
        aggregateBy: namespace
        filters:
        - property: cluster
          value: cluster-one,cluster*
        - property: namespace
          value: kubecost
        idle: separate
        title: Example Saved Report 0
        window: today
      - accumulate: false
        aggregateBy: controllerKind
        filters:
        - property: label
          value: app:cost*,environment:kube*
 ```

</details>
Kubecost operator will automatically detect the CRD resources and deploy Kubecost to the Kubecost namespace. 

To expose Kubecost and access Kubecost dashboard, you can create a route to the service `kubecost-cost-analyzer` on port `9090` of the `kubecost` project. You can learn more about how to do it on your OpenShift portal in this [LINK](https://docs.openshift.com/container-platform/3.11/dev_guide/routes.html#:~:text=to%20the%20router.-,Creating%20Routes,Applications%20section%20of%20the%20navigation.&text=The%20new%20route%20inherits%20the,using%20the%20%2D%2Dname%20option.)

Kubecost will be collecting data; please wait 5-15 minutes for the UI to reflect the resources in the local cluster.

## Clean up

You can uninstall Kubecost from your cluster with the following command.

```bash
kubectl delete-f example-crd.yaml -n kubecost
```

You can uninstall Kubecost operator by following [these instructions](https://access.redhat.com/documentation/en-us/openshift_container_platform/4.2/html/operators/olm-deleting-operators-from-a-cluster). 

## Support

For advanced setup or if you have any questions, you can contact us on [Slack](https://join.slack.com/t/kubecost/shared_invite/enQtNTA2MjQ1NDUyODE5LWFjYzIzNWE4MDkzMmUyZGU4NjkwMzMyMjIyM2E0NGNmYjExZjBiNjk1YzY5ZDI0ZTNhZDg4NjlkMGRkYzFlZTU) or email us at [support@kubecost.com](support@kubecost.com).

<!--- {"article":"","section":"4402815636375","permissiongroup":"1500001277122"} --->
