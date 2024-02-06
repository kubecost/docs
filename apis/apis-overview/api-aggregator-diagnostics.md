# Aggregator diagnostic APIs

APIs exposed by Kubecost Aggregator for troubleshooting without inspecting the PV directly.


#### `/model/debug/orchestrator`

Returns current state of the Orchestrator, which governs what state Aggregator is currently in.

#### `/model/diagnostic/coreCount`

Used to determine the peak number of monitored cores in the window.

| Parameter | Default | Description |
| --- | --- | --- |
| `window` | `2d` | The window of data to find the peak cores of |

#### `/model/diagnostic/containersPerDay`

Used to determine the container rows per daily window, including max and min.

#### `/model/diagnostic/cloudCostsPerDay`

Used to determine the Cloud Cost rows per daily window, including max and min.

#### `/model/diagnostic/containerWithoutMatchingNode`

Used to determine if, in each window, there is container data without matching node data (matched on Provider ID).

| Parameter | Default | Description |
| --- | --- | --- |
| `containerTable` | `container_1d` | The table containing container data to consider. Try also `container_1d_reconciled`. |
| `nodeTable` | `node_1d` | The table containing container data to consider. Try also `node_1d_reconciled`. |

#### `/model/diagnostic/containerDuplicateNoId`

Used to determine if, in each window, there is duplicate container data according to (Cluster, Namespace, Controller Kind, Controller Name, Pod Name, Container Name).

| Parameter | Default | Description |
| --- | --- | --- |
| `containerTable` | `container_1d` | The table containing container data to consider. Try also `container_1d_reconciled`. |

#### `/model/diagnostic/containerDuplicateWithId`

Used to determine if, in each window, there is duplicate container data according to (Cluster, Namespace, Controller Kind, Controller Name, Pod Name, Container Name, Id).

| Parameter | Default | Description |
| --- | --- | --- |
| `containerTable` | `container_1d` | The table containing container data to consider. Try also `container_1d_reconciled`. |

#### `/model/diagnostic/nodeDuplicateNoId`

Used to determine if, in each window, there is duplicate node data according to (Cluster, Provider ID).

| Parameter | Default | Description |
| --- | --- | --- |
| `nodeTable` | `node_1d` | The table containing container data to consider. Try also `node_1d_reconciled`. |