# Abandoned Workloads

The abandoned workloads API suggests cluster workloads that have been abandoned based on network traffic levels. It is available at:
```
http://<kubecost-address>/model/savings/abandonedWorkloads
```

## Parameters

| Name | Type | Description |
|------|------|-------------|
| `days` | int | Number of historical days over which network traffic should be measured. |
| `threshold` | int | The threshold of traffic (bytes/second) at which a workload is determined abandoned. |
