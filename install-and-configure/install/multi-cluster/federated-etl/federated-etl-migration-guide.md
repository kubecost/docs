# Migration Guide from Federated ETL to Kubecost v2.0+ (Aggregator)

This tutorial is intended to help our users migrate from an existing federated ETL setup to Kubecost v2.0+'s Aggregator. There are a few requirements in order to successfully migrate to Kubecost v2.0+. This new version of Kubecost includes a new backend Aggregator which handles the ETL data built from source metrics more efficiently. Kubecost v2.0+ provides new features, optimizes UI performance, and enhances the user experience. This tutorial is meant to be performed before the user upgrades from an older version of Kubecost to v2.0+.

![Aggregator Architecture](/images/diagrams/aggregator-diagrams.png)

Important notes for the migration process:

* Verify that you are currently using the Federated ETL data federation method and you are not using Thanos data federation (Thanos users should consult a separate [Migration Guide from Thanos](/install-and-configure/install/multi-cluster/federated-etl/thanos-migration-guide.md)).
* Once Aggregator is enabled, all queries hit the Aggregator container and not cost-model via the reverse proxy.
* For larger environments, there are additional configurations that can be made to handle the size. Please reach out to to your Kubecost representative for guidance.

## Upgrading from Federated ETL

{% hint style="warning" %}
This guide involves upgrading both the primary Kubecost cluster and all secondary Kubecost clusters.  While it is not necessary to upgrade the secondary clusters to Kubecost 2.0+ immediately, we recommend it.
{% endhint %}

### Step 1: Create a cloud integration secret

{% hint style="warning" %}
Prior to Kubecost v2.0+, there were two acceptable methods integrating your multi-cloud accounts to Kubecost:

1. Populating cloud integration values directly in your values.yaml.
2. Using cloud integration secrets.

With Kubecost v2.0+, Kubecost now only supports using the cloud integration secret method documented in our [Multi-Cloud Integrations](/install-and-configure/install/cloud-integration/multi-cloud.md) doc. If you are not using this method currently, please follow instructions below to create the correct cloud integration secret and apply it to your *values.yaml* via Helm.
{% endhint %}

After successfully creating your cloud integration secret, run the following command. Make sure the name of your file containing your secret is *cloud-integration.json*.

```
kubectl create secret generic cloud-integration -n kubecost --from-file=cloud-integration.json
```

Next, apply the cloud integration secret to your *values.yaml*, replacing `CLOUD_INTEGRATION_SECRET` with the value of the secret:

```
kubecostProductConfigs:
    cloudIntegrationSecret: CLOUD_INTEGRATION_SECRET
```

Finally, make sure to remove cloud integration values from your *values.yaml* if you had previously configured them. See the tabs below for any cloud service providers you've previously configured and delete any of the listed values:

<details>

<summary>AWS</summary>

```
athenaProjectID: "530337586277" # The AWS AccountID where the Athena CUR is. Generally your management account
athenaBucketName: "s3://aws-athena-query-results-530337586277-us-east-1"
athenaRegion: us-east-1
athenaDatabase: athenacurcfn_athena_test1
athenaTable: "athena_test1"
athenaWorkgroup: "primary" # The default workgroup in AWS is 'primary'
masterPayerARN: ""
projectID: "123456789"  # Also known as AccountID on AWS -- the current account/project that this instance of Kubecost is deployed on.
```

</details>

<details>

<summary>GCP</summary>

```
projectID: "123456789"
gcpSecretName: gcp-secret # Name of a secret representing the GCP service key
gcpSecretKeyName: compute-viewer-kubecost-key.json # Name of the secret's key containing the gcp service key
bigQueryBillingDataDataset: billing_data.gcp_billing_export_v1_01AC9F_74CF1D_5565A2
```

</details>

<details>

<summary>Azure</summary>

```
azureBillingRegion: US # Represents 2-letter region code, e.g. West Europe = NL, Canada = CA. ref: https://en.wikipedia.org/wiki/List_of_ISO_3166_country_codes
azureSubscriptionID: 0bd50fdf-c923-4e1e-850c-196dd3dcc5d3
azureClientID: f2ef6f7d-71fb-47c8-b766-8d63a19db017
azureTenantID: 72faf3ff-7a3f-4597-b0d9-7b0b201bb23a
azureClientPassword: fake key # Only use if your values.yaml are stored encrypted. Otherwise provide an existing secret via serviceKeySecretName
```

</details>

### Step 2: Update the primary cluster


Delete the following values from your primary cluster Helm values:

```
federatedETL:
  useExistingS3Config: false
  primaryCluster: true
  federator:
    enabled: true
    # primaryClusterID: CLUSTER_NAME # Add after initial setup. This will break the combined folder setup if included at deployment.
kubecostModel:
  cloudCost:
    enabled: true # Set to true to enable CloudCost view that gives you visibility of your Cloud provider resources cost
  etlCloudAsset: false # Set etlCloudAsset to false when cloudCost.enabled=true
```

Add the following values to your primary cluster Helm values:

```
kubecostAggregator:
  replicas: 1
  deployMethod: statefulset
```
See this [example .yaml](https://github.com/kubecost/poc-common-configurations/blob/main/etl-federation-aggregator/primary-aggregator.yaml#L1-L14) for what your primary cluster configuration should look like.


Upgrade Kubecost on the primary cluster via Helm:

```
helm upgrade --install "kubecost" --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer --namespace kubecost -f values.yaml
```

Once the Helm upgrade is complete, Aggregator will start processing data. This process can take as long as 24 hours depending on the size of the ETL dataset being processed. As the data is processed, it will generate in the Kubecost UI.

### Step 3: Update secondary clusters

Delete the following values from your secondary cluster Helm values:

```
federatedETL:
  useExistingS3Config: false
  primaryCluster: false
kubecostModel:
  warmCache: false
  warmSavingsCache: false
```

Add the following values to your secondary cluster Helm values:

```
federatedETL:
  agentOnly: true
```

See this [example .yaml](https://github.com/kubecost/poc-common-configurations/blob/main/etl-federation-aggregator/secondary-federated.yaml#L8-L15) for what your secondary cluster configuration should look like.

Finally, upgrade Kubecost on the secondary cluster(s) via Helm:

```
helm upgrade --install "kubecost" --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer --namespace kubecost -f values.yaml
```
