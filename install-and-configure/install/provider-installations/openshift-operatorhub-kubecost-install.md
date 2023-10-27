# Deploy Kubecost from Red Hat Openshift’s OperatorHub

## Overview

The OperatorHub is available via the Red Hat OpenShift Container Platform web console and is the interface that cluster administrators use to discover and install Operators. With one click, an Operator can be pulled from their off-cluster source, installed and subscribed on the cluster, and made ready for engineering teams to self-service manage the product across deployment environments using the Operator Lifecycle Manager (OLM). Kubecost is now available on the [Embedded OperatorHub in OpenShift and OKD](https://github.com/redhat-openshift-ecosystem/community-operators-prod/tree/main/operators)

This document provides instructions for deploying Kubecost into Red Hat Openshift 4.9.x or higher using Red Hat Openshift platform (OCP) web console. Kubecost's operator on the [Embedded OperatorHub in OpenShift and OKD](https://github.com/redhat-openshift-ecosystem/community-operators-prod/tree/main/operators) is an alternative to [Kubecost Free version](/architecture/opencost-product-comparison.md). Kubecost's operator uses an Operator pattern to deploy and manage the Kubecost deployment on the Red Hat Openshift platform.

![Standard deployment](/images/ocp-standard.png)

## Prerequisites

* You need to have an existing OCP cluster version 4.9.x or higher.
* You have appropriate access to that OpenShift cluster to create a new project and deploy new workloads.

## Discover Kubecost operator

1. Log in to your OCP cluster web console.
2. Select Operators > OperatorHub > Enter Kubecost in the search box.
3. Create a namespace named Kubecost:

```bash
kubectl create namespace kubecost
```

Example screenshot:

![Discovery](/images/ocp-operator-discovery.png)

## Deploy Kubecost

### **Step 1:** Install Kubecost operator

On the OperatorHub page, find Kubecost, then click install. You will be on the Operator Installation page, which shows all related information. Select your desired version and settings, then click `Install`

![Installation step 1a](/images/ocp-operator-installation-step-1.png)

The installation takes 1-2 minutes to be completed. A dialog will appear as in the following example screenshot:

![Installation step 1b](/images/ocp-operator-installation-step-1b.png)

You can click on `View Operators` to review the details as in the following screenshot:

![Installation step 1c](/images/ocp-operator-installation-step-1c.png)

Kubecost operator is now installed successfully. Next, you can start to install Kubecost using the custom resources definition (CRD)

### Step 2: Create a CRD to deploy Kubecost

* You can customize the CRD definition similarly to the custom values file when deploying with Helm chart.
* After creating a CRD file, apply it to deploy Kubecost:

```bash
kubectl apply -f example-crd.yaml -n kubecost
```

* Example CRD to deploy Kubecost on OCP cluster

<details>

<summary>Click to see code</summary>

```yaml
apiVersion: charts.kubecost.com/v1alpha1
kind: CostAnalyzer
metadata:
  name: cost-analyzer-ocp-sample
spec:
  affinity: {}
  # Security Context settings for Redhat OpenShift cluster:
  kubecostProductConfigs:
    clusterName: YOUR_CLUSTER_NAME
    # cloudIntegrationSecret: cloud-integration
  kubecostDeployment:
    podSecurityContext:
    # Note: Un-comment these securityContext configs for OCP cluster 4.11+
      # seccompProfile:
      #   type: RuntimeDefault
      runAsNonRoot: true
  kubecostModel:
    etlCloudAsset: true # set to true to enable kubecost to include out-of-cluster cloud resources  (uses more memory)
    containerStatsEnabled: true
    containerSecurityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
  # Note: Un-comment these securityContext configs for OCP cluster 4.11+
      # seccompProfile:
      #   type: RuntimeDefault
      capabilities:
        drop:
          - ALL
  kubecostFrontend:
    containerSecurityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      runAsNonRoot: true
  # Note: Un-comment these securityContext configs for OCP cluster 4.11+
      # seccompProfile:
      #   type: RuntimeDefault
      capabilities:
        drop:
          - ALL
  kubecostNetworkCosts:
    securityContext: {}
    containerSecurityContext: {}

  prometheus:
    nodeExporter:
      enabled: false
    kubeStateMetrics:
      enabled: false
    kube-state-metrics:
      disabled: true
    podSecurityPolicy:
      enabled: false
    server:
      global:
        external_labels:
          cluster_id: YOUR_CLUSTER_NAME 
      containerSecurityContext:
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
  # Note: Un-comment these securityContext configs for OCP cluster 4.11+
          # seccompProfile:
          #   type: RuntimeDefault
          capabilities:
            drop:
                - ALL
    sidecarContainers:
      containerSecurityContext:
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
  # Note: Un-comment these securityContext configs for OCP cluster 4.11+
          # seccompProfile:
          #   type: RuntimeDefault
          capabilities:
            drop:
              - ALL
    configmapReload:
      containerSecurityContext:
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
  # Note: Un-comment these securityContext configs for OCP cluster 4.11+
          # seccompProfile:
          #   type: RuntimeDefault
          capabilities:
            drop:
              - ALL
  grafana:
    rbac:
      pspEnabled: false
    grafana:
      containerSecurityContext:
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
  # Note: Un-comment these securityContext configs for OCP cluster 4.11+
          # seccompProfile:
          #   type: RuntimeDefault
          capabilities:
            drop:
              - ALL
    initContainers:
      containerSecurityContext:
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
  # Note: Un-comment these securityContext configs for OCP cluster 4.11+
          # seccompProfile:
          #   type: RuntimeDefault
          capabilities:
            drop:
              - ALL
    sidecar:
      containerSecurityContext:
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
  # Note: Un-comment these securityContext configs for OCP cluster 4.11+
          # seccompProfile:
          #   type: RuntimeDefault
          capabilities:
            drop:
              - ALL
  thanos:
    thanosstore:
      containerSecurityContext:
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
  # Note: Un-comment these securityContext configs for OCP cluster 4.11+
          # seccompProfile:
          #   type: RuntimeDefault
          capabilities:
            drop:
              - ALL
    thanosqueryfrontend:
      containerSecurityContext:
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
  # Note: Un-comment these securityContext configs for OCP cluster 4.11+
          # seccompProfile:
          #   type: RuntimeDefault
          capabilities:
            drop:
              - ALL
    thanosquery:
      containerSecurityContext:
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
  # Note: Un-comment these securityContext configs for OCP cluster 4.11+
          # seccompProfile:
          #   type: RuntimeDefault
          capabilities:
            drop:
              - ALL
    thanoscompact:
      containerSecurityContext:
        securityContext:
          allowPrivilegeEscalation: false
          readOnlyRootFilesystem: true
          runAsNonRoot: true
  # Note: Un-comment these securityContext configs for OCP cluster 4.11+
          # seccompProfile:
          #   type: RuntimeDefault
          capabilities:
            drop:
              - ALL
  # Disable Pod Security Policy (PSP)
  # Kubecost PSP
  podSecurityPolicy:
      enabled: false
  # Network Costs PSP
  networkCosts:
    enabled: false # if enabling network costs, also set the given cloud provider to true
    config:
      services:
        amazon-web-services: false
        google-cloud-services: false
        azure-cloud-services: false
    podSecurityPolicy:
      enabled: false
  # optional
  global:
    grafana:
      enabled: false
      proxy: false
```

</details>

Kubecost operator will automatically detect the CRD resources and deploy Kubecost to the Kubecost namespace.

To expose Kubecost and access Kubecost dashboard, you can create a route to the service `kubecost-cost-analyzer` on port `9090` of the `kubecost` project. You can learn more about how to do it on your OpenShift portal in this [LINK](https://docs.openshift.com/container-platform/3.11/dev\_guide/routes.html)

Kubecost will be collecting data; please wait 5-15 minutes for the UI to reflect the resources in the local cluster.

## Clean up

You can uninstall Kubecost from your cluster with the following command.

```bash
kubectl delete-f example-crd.yaml -n kubecost
```

You can uninstall Kubecost operator by following [these instructions](https://access.redhat.com/documentation/en-us/openshift\_container\_platform/4.2/html/operators/olm-deleting-operators-from-a-cluster).
