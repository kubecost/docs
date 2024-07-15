# NVIDIA GPU Monitoring Configurations

## Monitoring GPU utilization

In order for Kubecost to understand a container's GPU utilization percentage, Kubecost depends on metrics being available from NVIDIA [DCGM Exporter](https://github.com/NVIDIA/dcgm-exporter). Follow the below instructions to install and configure DCGM Exporter on each of your GPU-enabled clusters.

```sh
helm upgrade -i dcgm dcgm-exporter \
  --repo https://nvidia.github.io/dcgm-exporter/helm-charts
  -n dcgm-exporter --create-namespace \
  --set serviceMonitor.enabled=false
```

For more advanced configurations, optionally follow the steps below:

```sh
# 1. Upgrade the NVIDIA Device plugin to its latest release. Additionally enable GPU feature discovery.
helm upgrade -i nvdp nvidia-device-plugin \
  --repo https://nvidia.github.io/k8s-device-plugin \
  -n nvidia-device-plugin --create-namespace \
  --set gfd.enabled=true

# 2. Install the DCGM Exporter with a node affinity rule to only run on GPU nodes.
helm upgrade -i dcgm dcgm-exporter \
  --repo https://nvidia.github.io/dcgm-exporter/helm-charts
  -n dcgm-exporter --create-namespace \
  -f values-dcgm.yaml
```

<details>
<summary>values-dcgm.yaml</summary>

```yaml
# Only runs the DCGM Exporter pod on GPU capable nodes. Otherwise it will
# CrashLoopBackoff on non-GPU nodes.
affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
      - matchExpressions:
        - key: feature.node.kubernetes.io/pci-10de.present
          operator: In
          values:
          - "true"
serviceMonitor:
  enabled: false
```

</details>

To validate your configuration, port-forward into Kubecost's bundled Prometheus server and check whether Prometheus is scraping GPU metrics:

```sh
kubectl port-forward svc/kubecost-prometheus-server 9090:9091 -n kubecost
```
