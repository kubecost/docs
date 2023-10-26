# Service Key rotation

Cloud provider service keys can be used in various aspects of the Kubecost install. Examples include configuring [Cloud Integrations](https://docs.kubecost.com/install-and-configure/install/cloud-integration), [Multiclustering](https://docs.kubecost.com/install-and-configure/install/multi-cluster), and [ETL-backups](https://docs.kubecost.com/install-and-configure/install/etl-backup). While automated IAM authentication via a Kubernetes service account like AWS IRSA is recommended, there are some scenarios where key-based authentication is preferred. When this method is used, rotating the keys at a pre-defined interval is a security best practice. Keep in mind combinations of these features can be used, and therefore, you may need to follow one or more of the following steps.

## Cloud integration keys

There are multiple methods for adding Cloud provider keys to Kubecost when configuring a cloud integration. The preferred and most common is via the multi-cloud cloud-integration.json Kubernetes secret. The second method is to define the appropriate secret in the Kubecost helm [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values.yaml) file. The final method to configure keys is via the Kubecost settings page. Be sure to use the same method that was used during the initial installation of Kubecost when rotating keys.
See the [Cloud Integrations](https://docs.kubecost.com/install-and-configure/install/cloud-integration) page for additional details.

1. Modify the appropriate Kubernetes secret, Helm value, or update the settings page.
2. Restart the Kubecost `cost-analyzer` pod.
3. Verify the new key is working correctly. Any authentication errors should be present early in the `cost-model` container logs from the `cost-analyzer` pod. Additionally, you can check the status of the cloud integration on the "settings > full diagnostics" page in Kubecost.

## Multi-cluster keys

There are two methods for enabling multi-clustering in Kubecost. They are [ETL Federation (preferred)](https://docs.kubecost.com/install-and-configure/install/multi-cluster/federated-etl) and [Thanos](https://docs.kubecost.com/install-and-configure/install/multi-cluster/thanos-setup). Depending on which method you are using, the key rotation process differs.

### Federated-ETL

With Federated ETL objects, storage keys can be provided in two ways. The preferred method is using the secret defined by the Helm value `.Values.kubecostModel.federatedStorageConfigSecret`. The alternate method is to re-use the ETL backup secret defined with the `.Values.kubecostModel.etlBucketConfigSecret` helm value.

1. Update the appropriate Kubernetes secret with the new Key on each cluster.
2. Restart the Kubecost `cost-analyzer` pod.
3. Restart the Kubecost `federator` pod.
4. Verify the new key is working correctly by checking the `cost-model` container logs from the `cost-analyzer` pod for any object storage authentication errors. Additionally, verify there are no object storage errors in the `federator` pod logs.

### Thanos

Thanos federation makes use of the `kubecost-thanos` Kubernetes secret as described [here](https://docs.kubecost.com/install-and-configure/install/multi-cluster/thanos-setup/long-term-storage#step-1-create-object-store.yaml).

1. Update the `kubecost-thanos` Kubernetes secret with the new Key on each cluster.
2. Restart the `prometheus` server pod installed with Kubecost on all clusters (including the Primary) that write data to the Thanos object store. This will ensure the Thanos Sidecar has the new key.
3. On the Primary Kubecost cluster, restart the `thanos-store` pod.
4. Verify the new key is working correctly by checking the `thanos-sidecar` logs in the `prometheus` server pods for authentication errors to ensure they are able to write new block data to the object storage.
5. Verify the new key is working correctly by checking `thanos-store` pod logs on the Primary cluster for authentication errors to ensure it is able to read block data from the object storage.

## ETL-Backup keys

ETL backups rely on the secret defined by the Helm value `.Values.kubecostModel.etlBucketConfigSecret`. More details can be found on the [ETL backup page](https://docs.kubecost.com/install-and-configure/install/etl-backup).

1. Modify the appropriate Kubernetes secret.
2. Restart the Kubecost `cost-analyzer` pod.
3. Verify the backups are still being written to the object storage.
