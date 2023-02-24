# Sharing ETL Backups

This document will describe why your Kubecost instance’s data can be useful to share with us, what content is in the data, and how to share it.

**Why.** We test and verify each Kubecost product release against a combination of generated/synthetic Kubernetes cluster data and examples of customer data that has been shared with us. Customers who share snapshots of their data with us help to ensure that product changes handle their specific use-cases and scales. Because the Kubecost product for many customers is run as an on-prem service, with no data sharing back to us, we do not inherently have this data for many of our customers.

**What.** To share data with us requires an ETL backup executed by the customer in their own environment and then sending the resultant data to us. Kubecost's ETL is a computed cache built upon Prometheus metrics and cloud billing data, from which nearly all API requests made by the user and the Kubecost frontend currently rely upon. Therefore, the ETL data will contain metric data and identifying information for that metric (e.g. a container name + pod name + namespace + cluster name) during a time window, but will not contain other information about containers, pods, clusters, cloud resources, etc. You can read more about these [metric details here](./user-metrics.md).

**How.** The full methodology for creating the ETL backup can be found [here](./etl-backup.md). Once these files have been backed up, the content will look as follows before compressing the data:

```txt
├── etl
│   ├── bingen
│   │   ├── allocations
│   │   │   ├── 1d # data chunks of 1 day
│   │   │   │   ├── filename: {start timestamp}-{end timestamp}
│   │   │   ├── 1h # data chunks of 1 hour
│   │   │   │   ├── filename: {start timestamp}-{end timestamp}
│   │   ├── assets
│   │   │   ├── 1d # data chunks of 1 day
│   │   │   │   ├── filename: {start timestamp}-{end timestamp}
│   │   │   ├── 1h # data chunks of 1 hour
│   │   │   │   ├── filename: {start timestamp}-{end timestamp}
```

Once the data is downloaded to local disk from either the automated or manual ETL backup methods, the data must be gzipped. A suggested method for downloading the ETL backup and compressing it quickly is to use [this script](https://github.com/kubecost/etl-backup/blob/main/download-etl.sh). Check out the `tar` syntax in that script if doing this manually without the script. Once you have the compressed ETL backup ready to share, please work with a support partner on sharing the file with us. Our most common approach is to use a Google Drive folder with access limited to you and the support engineer, but we recognize not all companies are open to this and will work with you to determine the most business appropriate method.

If you are interested in reviewing the contents of the data, either before or after sending the ETL backup to us, you can find an example Golang implementation on how to read the [raw ETL data here](https://github.com/kubecost/etl-backup#run-etl-from-backed-up-data).
