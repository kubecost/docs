# NVIDIA GPU Monitoring Configurations

## Monitoring GPU utilization

Kubecost supports monitoring of NVIDIA GPU utilization starting with the Volta architecture (2017). In order for Kubecost to understand GPU utilization, Kubecost depends on metrics being available from NVIDIA [DCGM Exporter](https://github.com/NVIDIA/dcgm-exporter). Kubecost will search for GPU metrics by default, but since DCGM Exporter is the provider of those metrics it is a required component when GPU monitoring is used with Kubecost and must be installed if it is not already. In many cases, DCGM Exporter may already be installed in your cluster, for example if you currently monitor NVIDIA GPUs with other software. See the [Pre-Installed DCGM Exporter](#pre-installed-dcgm-exporter) section for important considerations. But if not, follow the instructions in the [Install DCGM Exporter](#install-dcgm-exporter) section to install and configure DCGM Exporter on each of your GPU-enabled clusters.

{% hint style="note" %}
Managed DCGM offerings such as Google Cloud's managed DCGM are currently not supported. DCGM Exporter must be self-installed and managed in target clusters.
{% endhint %}

## Pre-Installed DCGM Exporter

In cases where you have already installed DCGM Exporter in your cluster, Kubecost can leverage this installation as the source of its GPU metrics. However, in order for Kubecost's bundled Prometheus to find this installation the following requirements must be met.

- DCGM Exporter has been installed with a matching Kubernetes [Service](https://kubernetes.io/docs/concepts/services-networking/service/). Installations consisting of only the DaemonSet are not supported. Helm-based installations of either the [DCGM Exporter](https://github.com/NVIDIA/dcgm-exporter) or the [GPU operator](https://github.com/NVIDIA/gpu-operator) charts include a Service by default.
- The Service must have active [Endpoints](https://kubernetes.io/docs/concepts/services-networking/service/#endpoints) which list the available DCGM Exporter pods.
- The Service and Endpoints must have at least one of a few possible labels assigned in order for Prometheus to locate them. The currently-supported label keys are shown below. Assigning a compatible label solely to pods or the parent DaemonSet is not supported.
  - `app`
  - `app.kubernetes.io/component`
  - `app.kubernetes.io/name`
- The value of one of these labels must contain the string `dcgm-exporter`.


**In order for Kubecost to provide gpuUsageAverage, gpuRequestAverage and gpuCostIdle, the DCGM exporter must be running locally on the cluster with GPU nodes.**


## Install DCGM Exporter

DCGM Exporter is an implementation of NVIDIA [Data Center GPU Manager (DCGM)](https://developer.nvidia.com/dcgm) for Kubernetes which exports metrics in [Prometheus](https://prometheus.io/) format. DCGM Exporter allows for running the DCGM software under Kubernetes on nodes which contain NVIDIA devices and takes care of the task of making DCGM metrics available to external tools such as Kubecost.

DCGM Exporter runs as a DaemonSet and its pods are intended to run only on nodes with one or more NVIDIA GPUs. Because Kubernetes clusters commonly have a mixture of nodes with GPUs and those without GPUs, you use label(s) to affine the DCGM Exporter pods to only those nodes containing NVIDIA GPUs. If DCGM Exporter pods run on nodes without NVIDIA GPUs, they enter a `CrashLoopBackoff` state. The label(s) you use may vary by Kubernetes cloud provider, platform, or more. There are multiple approaches to selecting the appropriate label(s) used to attract the DCGM Exporter pods to applicable nodes.

1. Use a pre-provided label by your cloud provider (if applicable, varies by cloud provider).
2. Use a custom label you define on your GPU nodes. For example, by defining a custom label at the node pool level in your cloud provider.
3. Use a label assigned automatically by Kubernetes Node Feature Discovery (NFD).

The first two options require no additional cluster components be installed while the third requires the [Kubernetes Node Feature Discovery (NFD)](https://kubernetes-sigs.github.io/node-feature-discovery/stable/get-started/index.html) component. Kubecost recommends using an existing label assigned to your GPU nodes (provided by the cloud provider or yourself), if possible, as this is a simpler installation path.

In addition to the label requirement, there may be additional values required for a successful installation of DCGM Exporter which may vary by cloud provider and worker node operating system. This guide includes the following installation instructions.

- [General Quickstart](#general-quickstart): Start here if not on GKE.
- [GKE](#gke): For GKE users only.
- [Node Feature Discovery](#node-feature-discovery): For any Kubernetes environment where preexisting GPU node labels are not an option.

{% hint style="info" %}
DCGM Exporter may also be deployed via the NVIDIA [GPU operator](https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/index.html), however the operator is a more complex component with specialized requirements and, as such, is outside the current scope of this documentation.
{% endhint %}

These instructions have been verified on version 3.3.8-3.6.0 of DCGM Exporter but prior versions of v3 should work as well.

### General Quickstart

DCGM Exporter can be installed on most Kubernetes clusters with only a few values provided that a preexisting label can be used to identify GPU-only nodes. This label may be provided by a cloud vendor or yourself. Follow these steps to get started with DCGM Exporter.

In the below values, you provide your own label key and value in place of `mylabel` and `myvalue`. This label combination should be unique to NVIDIA GPU nodes.

<details>
<summary>values-dcgm.yaml</summary>

```yaml
serviceMonitor:
  enabled: false

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: mylabel
          operator: In
          values:
          - "myvalue"
```

</details>

Install DCGM Exporter using the values defined.

```sh
helm upgrade -i dcgm dcgm-exporter \
  --repo https://nvidia.github.io/dcgm-exporter/helm-charts \
  -n dcgm-exporter --create-namespace \
  -f values-dcgm.yaml
```

Ensure the DCGM Exporter pods are in a running state and only on the nodes with NVIDIA GPUs.

```sh
kubectl -n dcgm-exporter get pods
```

Finally, perform a validation step to ensure that metrics are working as expected. See the [Validation](#validation) section for details.

### GKE

{% hint style="note" %}
Managed DCGM offerings such as Google Cloud's [managed DCGM](https://cloud.google.com/kubernetes-engine/docs/how-to/dcgm-metrics) are currently not supported. DCGM Exporter must be self-installed and managed in target clusters.
{% endhint %}

To install DCGM Exporter on a GKE cluster where the worker nodes use the default [Container Optimized OS (COS)](https://cloud.google.com/container-optimized-os/docs), use the following values. The GKE-provided label `cloud.google.com/gke-accelerator` is used to attract DCGM Exporter pods to nodes with NVIDIA GPUs.

{% hint style="info" %}
These values have been verified on GKE 1.27 and DCGM Exporter 3.3.8-3.6.0. Ensure you check and follow the current values structure of the target version of [DCGM Exporter](https://github.com/NVIDIA/dcgm-exporter) to be installed if different.
{% endhint %}

<details>
<summary>values-dcgm.yaml</summary>

```yaml
serviceMonitor:
  enabled: false

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: cloud.google.com/gke-accelerator
              operator: Exists

tolerations:
  - operator: Exists

securityContext:
  privileged: true

extraHostVolumes:
  - name: vulkan-icd-mount
    hostPath: /home/kubernetes/bin/nvidia/vulkan/icd.d
  - name: nvidia-install-dir-host
    hostPath: /home/kubernetes/bin/nvidia

extraVolumeMounts:
  - name: nvidia-install-dir-host
    mountPath: /usr/local/nvidia
    readOnly: true
  - name: vulkan-icd-mount
    mountPath: /etc/vulkan/icd.d
    readOnly: true

extraEnv:
- name: DCGM_EXPORTER_KUBERNETES_GPU_ID_TYPE
  value: device-name
```

</details>

Install DCGM Exporter from the available Helm chart while supplying the values defined above.

```sh
helm upgrade -i dcgm dcgm-exporter \
  --repo https://nvidia.github.io/dcgm-exporter/helm-charts \
  -n dcgm-exporter --create-namespace \
  -f values-dcgm.yaml
```

Ensure the DCGM Exporter pods are in a running state and only on the nodes with NVIDIA GPUs.

```sh
kubectl -n dcgm-exporter get pods
```

If necessary, create a ResourceQuota allowing DCGM Exporter pods to be scheduled.

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: dcgm-exporter-quota
  namespace: dcgm-exporter
spec:
  hard:
    pods: 100
  scopeSelector:
    matchExpressions:
    - operator: In
      scopeName: PriorityClass
      values:
        - system-node-critical
        - system-cluster-critical
```

For additional information on installing DCGM Exporter in Google Cloud, see [here](https://cloud.google.com/stackdriver/docs/managed-prometheus/exporters/nvidia-dcgm).

Finally, perform a validation step to ensure that metrics are working as expected. See the [Validation](#validation) section for details.

### Node Feature Discovery

These instructions are useful for installing DCGM Exporter on any Kubernetes cluster regardless of whether run by a cloud provider or self-managed, on-premises. They leverage the [Kubernetes Node Feature Discovery (NFD)](https://kubernetes-sigs.github.io/node-feature-discovery/stable/get-started/index.html) component which involves installation of an additional infrastructure component. Following these steps are recommended when you are not on GKE or do not have a preexisting label which identifies NVIDIA GPU nodes.

{% hint style="info" %}
When following these instructions on a cloud provider, there may be additional values or steps required depending on the component installed.
{% endhint %}

[Node Feature Discovery (NFD)](https://github.com/kubernetes-sigs/node-feature-discovery) is a Kubernetes utility which automatically discovers information and capabilities about your worker nodes and saves this information in the form of labels applied to the node. For example, NFD will discover the CPU details, OS, and the PCI cards installed in a worker node on which the NFD pod is run. These labels can be useful in a number of scenarios beyond installation of DCGM Exporter. An example of some of the labels are shown below.

```yaml
<snip>
feature.node.kubernetes.io/cpu-cpuid.ADX: "true"
feature.node.kubernetes.io/cpu-cpuid.AESNI: "true"
feature.node.kubernetes.io/cpu-cpuid.AVX: "true"
feature.node.kubernetes.io/cpu-cpuid.AVX2: "true"
<snip>
```

When run on a node with an NVIDIA GPU, NFD will apply the label `feature.node.kubernetes.io/pci-10de.present="true"`. This label can then be used to attract DCGM Exporter pods to NVIDIA GPU nodes automatically.

{% hint style="info" %}
10DE is the vendor ID assigned to the NVIDIA corporation.
{% endhint %}

NFD may be installed either standalone or as a component of the [NVIDIA device plugin for Kubernetes](https://github.com/NVIDIA/k8s-device-plugin). When installing NFD via the device plugin, you enable the GPU Feature Discovery (GFD) component at the same time. GFD uses the labels written by NFD to locate NVIDIA GPU nodes and write NVIDIA-specific information about the discovered GPUs to the node.

{% hint style="warning" %}
Cloud providers often install the device plugin on GPU nodes automatically. Therefore, in order to deploy GFD and NFD you may be required to upgrade or uninstall/reinstall the device plugin, which is a more advanced procedure. See instructions from your cloud provider first and refer to the [NVIDIA device plugin for Kubernetes](https://github.com/NVIDIA/k8s-device-plugin) repository for further details.
{% endhint %}

To install NFD as a standalone component, follow the deployment guide [here](https://kubernetes-sigs.github.io/node-feature-discovery/stable/deployment/). A quick start command is also shown below. In some cases, you may have taints applied to GPU nodes which must be tolerated by the NFD DaemonSet. It is recommended to use the Helm installation guide to define tolerations if so.

```sh
# This command uses Kustomize to deploy Kubernetes resources from a specific version.
# Refer to the NFD releases to choose the latest, or most applicable, version.
kubectl apply -k https://github.com/kubernetes-sigs/node-feature-discovery/deployment/overlays/default?ref=v0.16.3
```

Once NFD is installed, ensure one pod is running on your node(s) with NVIDIA GPUs.

```sh
kubectl -n node-feature-discovery get pods
```

After a few moments, check the labels of one such node to ensure the `feature.node.kubernetes.io/pci-10de.present="true"` label has been applied.

```sh
kubectl get no <my_node_name> -o yaml | yq .metadata.labels
```

An abridged output of the labels written to an EKS node is shown below.

```yaml
<snip>
feature.node.kubernetes.io/kernel-version.full: 5.10.219-208.866.amzn2.x86_64
feature.node.kubernetes.io/kernel-version.major: "5"
feature.node.kubernetes.io/kernel-version.minor: "10"
feature.node.kubernetes.io/kernel-version.revision: "219"
feature.node.kubernetes.io/pci-10de.present: "true"
feature.node.kubernetes.io/pci-1d0f.present: "true"
feature.node.kubernetes.io/storage-nonrotationaldisk: "true"
<snip>
```

With NFD having successfully discovered NVIDIA PCI devices and assigned the `feature.node.kubernetes.io/pci-10de.present="true"` label, install DCGM Exporter using this label to attract pods to GPU nodes. When following this process on GKE, additional values may be required to successfully run DCGM Exporter. See the [GKE section](#gke) for more details.

<details>
<summary>values-dcgm.yaml</summary>

```yaml
serviceMonitor:
  enabled: false

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: feature.node.kubernetes.io/pci-10de.present
          operator: In
          values:
          - "true"
```

</details>

Install DCGM Exporter using the values defined.

```sh
helm upgrade -i dcgm dcgm-exporter \
  --repo https://nvidia.github.io/dcgm-exporter/helm-charts \
  -n dcgm-exporter --create-namespace \
  -f values-dcgm.yaml
```

Ensure the DCGM Exporter pods are in a running state and only on the nodes with NVIDIA GPUs.

```sh
kubectl -n dcgm-exporter get pods
```

Finally, perform a validation step to ensure that metrics are working as expected. See the [Validation](#validation) section for details.

## Customizing Metrics

DCGM Exporter presents a number of useful metrics by default. However, there are many [more metrics available from DCGM](https://docs.nvidia.com/datacenter/dcgm/latest/dcgm-api/dcgm-api-field-ids.html) which are not enabled by default. Kubecost may collect additional metrics about NVIDIA GPUs if they are emitted by DCGM Exporter. Configuring DCGM Exporter to emit additional metrics requires modification of the DCGM Exporter installation. Follow the procedure below to configure DCGM Exporter to emit additional metrics. Please be aware that emission of additional DCGM Exporter metrics, although they will be collected automatically by Kubecost's bundled Prometheus instance, does not imply that Kubecost will make use of them. This procedure should only be followed at the explicit advice of Kubecost support.

{% hint style="info" %}
This procedure assumes you have installed DCGM Exporter according to one of the processes outlined in the [Install DCGM Exporter](#install-dcgm-exporter) section. It also assumes that DCGM Exporter with a minimum version of 3.3.8-3.6.0 has been installed via Helm, which has direct support for specifying custom metrics in the Helm values.
{% endhint %}

### Supply Custom Metrics in Helm Values

Find the Helm values file used to deploy DCGM Exporter and add the `customMetrics` key along with the full set of metrics you wish DCGM Exporter to emit. The values you supply must be the complete and final list of metrics to emit and is not additive. An example of this is shown below in which DCGM Exporter will be requested to emit only two total metrics.

```yaml
customMetrics: |-
  # My custom metrics list
  DCGM_FI_PROF_SM_ACTIVE,          gauge, The ratio of cycles an SM has at least 1 warp assigned.
  DCGM_FI_PROF_SM_OCCUPANCY,       gauge, The ratio of number of warps resident on an SM.
```

Perform an upgrade of the Helm release using your modified values so the custom metrics are applied in the form of a ConfigMap mounted by the DCGM Exporter DaemonSet.

```sh
helm upgrade dcgm dcgm-exporter \
  --repo https://nvidia.github.io/dcgm-exporter/helm-charts \
  -n dcgm-exporter \
  -f values-dcgm.yaml
```

After upgrading, when DCGM Exporter pods return to service they should now be emitting the list of custom metrics provided in the new values.

For more information on DCM Exporter and its available Helm values and settings, see the official GitHub repository [here](https://github.com/NVIDIA/dcgm-exporter).

## Validation

To validate your DCGM Exporter configuration, port-forward into the DCGM Exporter service and ensure first that metrics are being exposed.

```sh
kubectl -n dcgm-exporter port-forward svc/dcgm-dcgm-exporter 9400:9400
```

Use `cURL` to perform a `GET` request against the service and verify that multiple metrics and their values are shown.

```sh
curl localhost:9400/metrics
```

An output similar to below should be shown.

```
# HELP DCGM_FI_DEV_SM_CLOCK SM clock frequency (in MHz).
# TYPE DCGM_FI_DEV_SM_CLOCK gauge
DCGM_FI_DEV_SM_CLOCK{gpu="0",UUID="GPU-93ef0036-98de-4946-648a-eca7040afbeb",device="nvidia0",modelName="Tesla T4",Hostname="myhost1.compute.internal"} 300
<snip>
```

If Kubecost has already been installed, next check the bundled Prometheus instance to ensure that the metrics from DCGM Exporter have been collected and are visible. This command exposes the Prometheus web interface on local port `8080`

```sh
kubectl -n kubecost port-forward svc/kubecost-prometheus-server 8080:80
```

Open the Prometheus web interface in your browser by navigating to `http://localhost:8080`. In the search box, begin typing the prefix for a metric, for example `DCGM_FI_DEV_POWER_USAGE`. Click Execute to view the returned query and verify that there is data present. An example is shown below.

![Prometheus query showing DCGM Exporter metric](/images/gpu-prometheus-query.png)
