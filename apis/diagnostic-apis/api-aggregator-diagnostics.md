# Aggregator Diagnostic APIs

Below are APIs exposed by Kubecost Aggregator for troubleshooting without inspecting the PV directly.

## Debug endpoints

#### `/model/debug/orchestrator`

This endpoint provides a live report of metrics of the write database. This endpoint can return valuable information including duration of current ingestion, and  hours required to complete ingestion.

Output for this endpoint looks like:

```

```

#### `model/debug/ingestionSummary`

This endpoint provides a summary of all ingestion records organized by cluster/cloud integration, modelType (ex: Allocations, Assets), and windowResolution (1d or 1h). Uses data exclusively from the write database. No supported parameters.

#### `model/debug/ingestionRecords`

This endpoint returns all of the individual ingestion records stored in the write database.

| Parameter | Default | Description |
| --- | --- | --- |
| `cluster` |  |  |
| `modelType` |  | Filter by model type |
| `onlyShowErrors` |  |  |
| `status` |  | Filter by status |
| `window` |  | Window of time for which you wish to query records. Accepts all standard formatting for [Kubecost `window` parameters](/apis/apis-overview.md#using-the-window-parameter-to-query-data-rnage) |
| `lastModifiedWindow` |  |  |
| `ingestionWindow` |  |  |
| `resolution` |  | Resolution of data points. Supports `daily` and `hourly`, or `nh` and `nd` where `n` is an integer (ex: `resolution=3d`) |
| `filename` |  | Query by specific filename |
| `filesize` |  | 100 - filter by file size in byters (supports < and >) |

#### `model/debug/derivationRecords`

This endpoint returns all of the individual derivation records stored in the write database. There is one record for every `filename`, `window`, and `resolution`. If the status is completed, there will be start and end times for the derivation.

| Parameter | Default | Description |
| --- | --- | --- |
| `checksum` |  | Filter by checksum |
| `filename` |  | Query by specific filename |
| `onlyShowErrors` |  | Filter by records where error has been detected |
| `status` |  | Filter by status |
| `window` |  | Window of time for which you wish to query records. Accepts all standard formatting for [Kubecost `window` parameters](/apis/apis-overview.md#using-the-window-parameter-to-query-data-rnage) |
| `derivationWindow` |  |  |
| `resolution` |  | Resolution of data points. Supports `daily` and `hourly`, or `nh` and `nd` where `n` is an integer (ex: `resolution=3d`) |
| `filename` |  | Query by specific filename |
| `filesize` |  | 100 - filter by file size in byters (supports < and >) |

#### `model/debug/databaseDirectory`

Lists files of the directory the database is in. Tool for troubleshooting with Kubecost support.

## Diagnostic endpoints

#### `/model/diagnostic/tableWindowCount`

Used to determine the number of unique WindowStart/WindowEnd pairs exist in the table.

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
