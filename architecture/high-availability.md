# High Availability

## Prerequisites

## Configuration

Update your *values.yaml* file with the following configuration:

```
kubecostFrontend:
  deployMethod: haMode
kubecostModel:
  federatedStorageConfigSecret: federated-store
kubecostProductConfigs:
  clusterName: [PRIMARY_CLUSTER]
prometheus:
  server:
    global:
      external_labels:
        cluster_id: [PRIMARY_CLUSTER_ID]
```