# Installing Kubecost on GKE Autopilot Clusters

## Installing Kubecost for GKE Autopilot via Helm

Installing Kubecost on a GKE Autopilot cluster is similar to other cloud providers with Helm v3.1+, with a few changes. Autopilot requires the use of [Google Managed Prometheus](/install-and-configure/advanced-configuration/custom-prom/gcp-gmp-integration.md) service, which generates additional costs within your Google Cloud account.

`helm install kubecost/cost-analyzer -n kubecost -f values.yaml`

Your _values.yaml_ files must contain the below parameters. Resources are specified for each section of the Kubecost deployment, and Pod Security Policies are disabled.

```yaml
kubecostProductConfigs:
  clusterName: "<clusterName>" # used for display in Kubecost UI

kubecostModel:
  promClusterIDLabel: cluster # warning: usage and efficiency will show as zero without this setting enabled
  resources:
    requests:
      cpu: 500m
      memory: 512Mi

kubecostFrontend:
  resources:
    requests:
      cpu: 250m
      memory: 55Mi

global:
  gmp:
    enabled: true # If true, kubecost will be configured to use GMP Prometheus image and query from Google Cloud Managed Service for Prometheus.
    gmpProxy:
      projectId: <GCP Project ID>

serviceAccount:
  annotations:
    iam.gke.io/gcp-service-account: <GCP Service Account with Metrics Writer/Reader Permissions> 

prometheus:
  server:
    image:
      repository: gke.gcr.io/prometheus-engine/prometheus
      tag: v2.41.0-gmp.4-gke.1
    global:
      external_labels:
        cluster_id: <GKE Autopilot Cluster Name>  # cluster_id should be unique for all clusters and the same value as .kubecostProductConfigs.clusterName
  podSecurityPolicy:
    enabled: false
  configmapReload:
    prometheus:
      resources:
        requests:
          cpu: 250m
          memory: 256Mi
  nodeExporter:
    enabled: false
  serviceAccounts:
    nodeExporter:
      create: false
    server:
      annotations: 
        iam.gke.io/gcp-service-account: <GCP Service Account with Metrics Writer/Reader Permissions>

networkCosts:
  enabled: false

podSecurityPolicy:
  enabled: false​

grafana:
  rbac:
    pspEnabled: false
  resources:
    requests:
      cpu: 250m
      memory: 128Mi
  sidecar:
    resources:
      requests:
        cpu: 250m
        memory: 384Mi

```

## Turning on Kubelet/cAdvisor scraping via Google Managed Collector

Open the OperatorConfig on your Autopilot Cluster resource for editing:

```bash
kubectl -n gmp-public edit operatorconfig config
```

Add the following collection section to the resource:

```yaml
apiVersion: monitoring.googleapis.com/v1
kind: OperatorConfig
metadata:
  namespace: gmp-public
  name: config
collection:
  kubeletScraping:
    interval: 30s
```

Save the file and close the editor. After a short time, the Kubelet metric endpoints will be scraped and the metrics become available for querying in Managed Service for Prometheus.
