Persistent Volume Right Sizing API
====================================

The Persistent Volume (PV) Right Sizing API displays data of all PVs in all clusters and makes a recommendation of optimal storage size for each PV.

The endpoint is available at

```http
http://<kubecost-address>/model/savings/persistentVolumeSizing
```

## Parameters

| Name | Type | Description |
|------|------|-------------|
| `headroomPct` | int | Percent of additional headroom to add to recommended capacity based on max usage of the PV. Defaults to 10% |

## API examples

```text
// See all PVs; make recommendations with 25% additional headroom 
http://localhost:9090/model/savings/persistentVolumeSizing?headroomPct=25

// See all PVs; make recommendations with 40% additional headroom 
http://localhost:9090/model/savings/persistentVolumeSizing?headroomPct=40
```

## Example API response

```console
recommendations:
    0:
        "volumeName": "pvc-5482dfcc-7a9e-46d7-5be3-503a689e8798",
        "claimName": "kubecost-cost-analyzer",
        "claimNamespace": "default",
        "clusterId": "cluster-one",
        "maxUsageBytes": 5419008,
        "averageUsageBytes": 5328691.199999999,
        "recommendedCapacityBytes": 5960908.800000001,
        "recommendedCostMonthly": 0.0002258249056541314,
        "currentCapacityBytes": 33787076061.866665,
        "currentCostMonthly": 1.28,
        "savingsMonthly": 1.2777417509434588,
        "storageClass": "standard"
    1:
        "volumeName": "pvc-09e21e95-e0e1-4129-775a-4fc6f1f29e45",
        "claimName": "kubecost-prometheus-server",
        "claimNamespace": "default",
        "clusterId": "cluster-one",
        "maxUsageBytes": 206999552,
        "averageUsageBytes": 202643394.05432096,
        "recommendedCapacityBytes": 227699507.20000002,
        "recommendedCostMonthly": 0.008626238289525955,
        "currentCapacityBytes": 33787076061.866665,
        "currentCostMonthly": 1.28,
        "savingsMonthly": 1.1937376171047405,
        "storageClass": "standard"
```
