# High Availability

Kubecost 2.2 introduces a new flag `haMode` for the frontend service.

This is the first step in enabling high availability for Kubecost. Future versions will expand the HA configuration to include the backend services.

> This flag changes the service name that the ingress needs to target.

With the Frontend HA Mode, the frontend will now be a dedicated deployment with two replicas. This allows for the ability to do rolling upgrades of the frontend pods during upgrades and configuration changes.

The primary benefit to this design is that the Kubecost UI is always available and diagnostics are available even if the backend services are not healthy.

## Prerequisites

HA Mode is only officially supported in Kubecost Enterprise.

## Configuration

Update your *values.yaml* file with the following minimum configuration:

```yaml
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
