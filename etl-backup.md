ETL Backup
==========

# Taking backups of your kubecost data.
Your prometheus retention window may small (15 days by default) to reduce the amount of data stored, meaning if Kubecost's ETL becomes lost or corrupted, it cannot be rebuilt from Prometheus for data older than the retention window. For this reason, you may wish to take backups of Kubecost's ETL pipeline.

## Via Script
The simplest way to back up kubecost's ETL is to create a copy locally to then send to the filestorage system of your choice. We provide a [script](https://github.com/kubecost/etl-backup) to do that.


# Restoring from a backup
Untar the results of the etl-backup script into the ETL directory pod.


```kubectl cp -c cost-model <untarred-results-of-script> <kubecost-namespace>/<kubecost-podname>/var/configs/db/etl```


Contact support (team@kubecost.com) if you need additional help

Edit this doc on [Github](https://github.com/kubecost/docs/blob/master/etl-backup.md)

<!--- {"article":"4407601811095","section":"4402815656599","permissiongroup":"1500001277122"} --->