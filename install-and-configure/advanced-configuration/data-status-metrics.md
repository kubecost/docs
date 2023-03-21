# Kubecost Data Status Metrics

## Overview

Prometheus data status metrics are emitted to help monitor the status of Kubecost data pipelines, including:

1. `kubecost_allocation_data_status`, which presents the active allocation data's time series status
2. `kubecost_asset_data_status`, which presents the time series status of the active asset data

These metrics provide data status through to proactively alert and analyze the allocation and asset data at a point in time.

## Metric details

### Allocation metrics

The metrics below depict the status of active allocation data at a point in time. The resolution is either daily or hourly, which aligns one-to-one with the data status of allocation daily and hourly store. Each hourly and daily stores have four types of status

1. **Empty**: Depicts the total number of empty allocationSet in each store hourly or daily at a point in time.
2. **Error**: Depicts the total number of errors in the allocationSet in each store hourly or daily at a point in time.
3. **Success**: Depicts the total number of successful allocationSet in each store hourly or daily at a point in time.
4. **Warning**: Depicts the total number of warnings in all allocationSet in each store hourly or daily at a point in time.

<figure><img src="https://lh5.googleusercontent.com/sU3f2ci544mZcN1m7UyuoZIUiT4SlQV8NSGbOfjSzY7BFWpADJ78AHsonNfiKTsynMCi_VZxJ9sh9Oab2D6e11NwWe-SZA1ThyvqhM_XnHv0B2qAiUYJsvCXl3y6nT7WsFnHV1ctMBU746R8Rn77FQQ" alt=""><figcaption><p>Prometheus metrics <code>kubecost_allocation_data_status</code> after port-forwarding</p></figcaption></figure>

### Asset metrics

The metrics below depict the status of active asset data at a point in time. The resolution is either daily or hourly, which aligns one-to-one with the data status of asset daily and hourly store. Each hourly and daily stores have four types of status

1. **Empty**: Depicts the total number of empty assetSet in each store hourly or daily at a point in time.
2. **Error**: Depicts the total number of errors in the assetSet in each store hourly or daily at a point in time.
3. **Success**: Depicts the total number of successful assetSet in each store hourly or daily at a point in time.
4. **Warning**: Depicts the total number of warnings in all assetSet in each store hourly or daily at a point in time.

<figure><img src="https://lh4.googleusercontent.com/RJSOAkHm4_thoEKObDJ1Y1RwYqIYnA7c8me1ChdJ_rj27XklsVGBu9lMt_JaUdrvrRFnSj8uS951R7GEH-H_NPdK9qL8ttJbwUcZJvQG7FzXBOUC0O3oS3Y1lx-MQJZzaYy_NtefmX7fj1MIGmbLvDA" alt=""><figcaption><p>Prometheus metrics <code>kubecost_asset_data_status</code> after port-forwarding</p></figcaption></figure>

## Usage details

* `kubecost_asset_data_status` is written to Prometheus during the assetSet and assetLoad events.
* `kubecost_allocation_data_status` is written to Prometheus during the allocationSet and allocationLoad events.
* During the cleanup operation, the corresponding entries of each allocation and asset are deleted to avoid the metrics having those particular entries having parity with respective allocation and asset stores.
