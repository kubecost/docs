The Cost Allocation page allows you to quickly see spend across all Kubernetes concepts. This article describes how you can control the data displayed in this view. 

![Cost allocation view](cost-allocation.png)

### 1. Cost metrics 
View either cumulative costs measured over the selected time window, or run rate (e.g. hourly, daily, monthly) based on the average resources allocated.  

### 2. Aggregation 
Aggregate cost by namespace, deployment, service and other native Kubernetes concepts. You can also view cost by other meaningful aggregations like Team, Department, or Product. These aggregations are based on Kubernetes labels or annotations, which can be configured in Settings. Resources without a label/annotation will be shown as Not Assigned.  

### 3. Time window
The designated time window for measuring costs. 

### 4. Filter
Filter resouces by namespace to more closely investigate a rise in spend or key cost drivers at different aggregations, e.g. Deployments or Pods. 

### 5. Allocate Idle Cost
Allocating idle costs will proportionately assign total cluster costs to indvidial resources.

### 6. Chart selection
Toggle to the bar chart view to see aggregated costs over the selected window, or the time series view to see cost changes over time.

### 7. Additional options
View other options to export cost data to CSV or view help documentation.
