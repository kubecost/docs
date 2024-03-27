# Aggregator Diagnostic APIs

Below are APIs exposed by Kubecost Aggregator for troubleshooting without inspecting the PV directly.

#### `/model/debug/orchestrator`

Returns current state of the Orchestrator, which governs what state Aggregator is currently in.

#### `/model/diagnostic/tableWindowCount`

Used to determine the number of unique WindowStart/WindowEnd pairs exist in the
table.

| Parameter | Default | Description |
| --- | --- | --- |
| `table` |  | Required. The table containing container data to consider. Try `container_1d`. |

#### `/model/diagnostic/coreCount`

Used to determine the peak number of monitored cores in the window.

| Parameter | Default | Description |
| --- | --- | --- |
| `window` | `2d` | Duration of time over which to query and find peak number of cores. Accepts multiple different formats of time (see this [Using the `window` parameter](/apis/apis-overview.md#using-the-window-parameter) section for more info). |

#### `/model/diagnostic/containersPerDay`

Used to determine the container rows per daily window, including max and min.

#### `/model/diagnostic/nodesPerDay`

Used to determine the node rows per daily window, including max and min.

#### `/model/diagnostic/cloudCostsPerDay`

Used to determine the Cloud Cost rows per daily window, including max and min.

#### `/model/diagnostic/containerLabelStats`

Used to determine data scale of labels on containers. Returns min, avg, and max
label count for all containers.

#### `/model/diagnostic/containerAnnotationStats`

Used to determine data scale of annotations on containers. Returns min, avg, and
max annotation count for all containers.

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
