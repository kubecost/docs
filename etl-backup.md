# Taking backups of your kubecost data.
Your prometheus retention window may be just 15 days to reduce storage volume, meaning if Kubecost's ETL becomes lost or corrupted, it cannot be rebuilt from Prometheus. For this reason, you may wish to take backups of Kubecost's (much smaller) ETL pipeline.

## Via Script
The simplest way to back up kubecost's ETL is to create a copy locally to then send to the filestorage system of your choice. We provide a [script](https://github.com/kubecost/etl-backup) to do that.


# Restoring from a backup
Contact support (team@kubecost.com) if you need to restore from a backup.
