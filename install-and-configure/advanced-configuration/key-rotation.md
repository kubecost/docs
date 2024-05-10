# Service Key Rotation

Cloud provider service keys can be used in various aspects of the Kubecost installation. This includes configuring [integrating your cloud provider billing data with Kubecost](/install-and-configure/install/cloud-integration/README.md), [setting up multi-cluster environments](/install-and-configure/install/multi-cluster/multi-cluster.md), and [backing up data](/install-and-configure/install/multi-cluster/federated-etl/federated-etl-backups-alerting.md). While automated IAM authentication via a Kubernetes service account like AWS IRSA is recommended, there are some scenarios where key-based authentication is preferred. When this method is used, rotating the keys at a pre-defined interval is a security best practice. Combinations of these features can be used, and therefore you may need to follow one or more of the below steps.

## Adding cloud provider keys

There are multiple methods for adding cloud provider keys to Kubecost when configuring a cloud integration. This article will cover all three procedures. Be sure to use the same method that was used during the initial installation of Kubecost when rotating keys.
See the [Cloud Integrations](/install-and-configure/install/cloud-integration/README.md) doc for additional details.

1. The preferred and most common is via the multi-cloud _cloud-integration.json_ Kubernetes secret.
2. The second method is to define the appropriate secret in Kubecost's [_values.yaml_](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values.yaml).
3. The final method to configure keys is via the Kubecost Settings page. 

The primary sequence for setting up your key is:

1. Modify the appropriate Kubernetes secret, Helm value, or update via the Settings page.
2. Restart the Kubecost `cost-analyzer` pod.
3. Verify the new key is working correctly. Any authentication errors should be present early in the `cost-model` container logs from the `cost-analyzer` pod. Additionally, you can check the status of the cloud integration in the Kubecost UI via _Settings_ > _View Full Diagnostics_.

## Adding multi-cluster keys

There are two methods for enabling multi-clustering in Kubecost:

1. [ETL Federation](/install-and-configure/install/multi-cluster/federated-etl/federated-etl.md)
2. [Thanos](/install-and-configure/install/multi-cluster/thanos-setup/thanos-setup.md)

Depending on which method you are using, the key rotation process differs.

### Federated-ETL

With Federated ETL objects, storage keys can be provided in two ways. The preferred method is using the secret defined by the Helm value `.Values.kubecostModel.federatedStorageConfigSecret`.

1. Update the appropriate Kubernetes secret with the new key on each cluster.
2. Restart the Kubecost `cost-analyzer` pod.
3. Restart the Kubecost `federator` pod.
4. Verify the new key is working correctly by checking the `cost-model` container logs from the `cost-analyzer` pod for any object storage authentication errors. Additionally, verify there are no object storage errors in the `federator` pod logs.

### Thanos

Thanos federation makes use of the `kubecost-thanos` Kubernetes secret as described [here](/install-and-configure/install/multi-cluster/thanos-setup/configuring-thanos.md#step-1-create-object-storeyaml).

1. Update the `kubecost-thanos` Kubernetes secret with the new key on each cluster.
2. Restart the `prometheus` server pod installed with Kubecost on all clusters (including the primary cluster) that write data to the Thanos object store. This will ensure the Thanos sidecar has the new key.
3. On the primary Kubecost cluster, restart the `thanos-store` pod.
4. Verify the new key is working correctly by checking the `thanos-sidecar` logs in the `prometheus` server pods for authentication errors to ensure they are able to write new block data to the object storage.
5. Verify the new key is working correctly by checking `thanos-store` pod logs on the primary cluster for authentication errors to ensure it is able to read block data from the object storage.