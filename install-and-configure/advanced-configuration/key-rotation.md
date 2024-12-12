# Service Key Rotation

Cloud provider service keys can be used in various aspects of the Kubecost installation. This includes [integrating your cloud provider billing data with Kubecost](/install-and-configure/install/cloud-integration/README.md), [setting up multi-cluster environments](/install-and-configure/install/multi-cluster/multi-cluster.md), and [backing up data](/install-and-configure/install/multi-cluster/federated-etl/federated-etl-backups-alerting.md). While automated IAM authentication via a Kubernetes service account like AWS IRSA is recommended, there are some scenarios where key-based authentication is preferred. When this method is used, rotating the keys at a pre-defined interval is a security best practice. Combinations of these features can be used, and therefore you may need to follow one or more of the below steps.

## Cloud billing integration keys

1. Update the Kubernetes secret containing the `cloud-integration.json` with the newly rotated key. See [Cloud Integrations](/install-and-configure/install/cloud-integration/README.md) for more configuration details.
2. Restart the `cloud-cost` pod if it exists, otherwise restart the `cost-analyzer` pod.
3. Verify the new key is working correctly. Any authentication errors should be present early in the container logs. Additionally, you can check the status of the cloud integration in the Kubecost UI via _Settings_ > _View Full Diagnostics_.

## Multi-cluster keys

There are two methods for enabling multi-clustering in Kubecost:

1. [ETL Federation](/install-and-configure/install/multi-cluster/federated-etl/federated-etl.md)
2. [Thanos](/install-and-configure/install/multi-cluster/thanos-setup/thanos-setup.md)

Depending on which method you are using, the key rotation process differs.

### Federated-ETL

With Federated ETL objects, storage keys can be provided in two ways. The preferred method is using the secret defined by the Helm value `.Values.kubecostModel.federatedStorageConfigSecret`.

1. Update the appropriate Kubernetes secret with the new key on each cluster.
2. Restart the Kubecost `cost-analyzer` pod.
3. If it exists, restart the `aggregator` pod.
4. Verify the new key is working correctly by checking the container logs for any object storage authentication errors.

### Thanos

Thanos federation makes use of the `kubecost-thanos` Kubernetes secret as described [here](/install-and-configure/install/multi-cluster/thanos-setup/configuring-thanos.md#step-1-create-object-storeyaml).

1. Update the `kubecost-thanos` Kubernetes secret with the new key on each cluster.
2. Restart the `prometheus` server pod installed with Kubecost on all clusters (including the primary cluster) that write data to the Thanos object store. This will ensure the Thanos sidecar has the new key.
3. On the primary Kubecost cluster, restart the `thanos-store` pod.
4. Verify the new key is working correctly by checking the `thanos-sidecar` logs in the `prometheus` server pods for authentication errors to ensure they are able to write new block data to the object storage.
5. Verify the new key is working correctly by checking `thanos-store` pod logs on the primary cluster for authentication errors to ensure it is able to read block data from the object storage.