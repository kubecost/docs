# Kubecost Postgres Integration

{% hint style="info" %}
This feature is only supported for Kubecost Enterprise.
{% endhint %}

The Postgres Integration feature enables users to periodically query and export their Kubecost data to a central Postgres database.

## Example use cases

- Customized dashboarding used by FinOps/Analytics teams.
- Single view populated by multiple data sources, to be used by developer/finance/operations teams.
- Customized budgeting and forecasting via an in-house data pipeline.

## Usage

Prerequisites:

- A running Postgres instance that is reachable by Kubecost.
- Credentials for a Postgres user which has `CREATE`, `INSERT`, and `UPDATE` permissions on the database.

### Step 1: Configure Helm values

The below YAML is an example of how to configure the Postgres integration in your Helm values file. Notice that there are four different queries being created (2 allocation queries, 1 asset query, 1 cloudCost query). Each query is configured to run every `12h` and write to their respective tables in the Postgres database.

```yaml
global:
  integrations:
    postgres:
      enabled: true
      runInterval: "12h"  # How frequently to run the integration.
      databaseHost: ""  # REQUIRED. ex: my.postgres.database.azure.com
      databasePort: ""  # REQUIRED. ex: 5432
      databaseName: ""  # REQUIRED. ex: postgres
      databaseUser: ""  # REQUIRED. ex: myusername
      databasePassword: ""  # REQUIRED. ex: mypassword
      databaseSecretName: ""  # OPTIONAL. Specify your own k8s secret containing the above credentials. Must have key "creds.json".

      queryConfigs:
        allocations:
          - databaseTable: "kubecost_allocation_data"
            window: "7d"
            aggregate: "namespace"
            idle: "true"
            shareIdle: "true"
            shareNamespaces: "kubecost,kube-system"
            shareLabels: ""
          - databaseTable: "kubecost_allocation_data_by_cluster"
            window: "10d"
            aggregate: "cluster"
            idle: "true"
            shareIdle: "false"
            shareNamespaces: ""
            shareLabels: ""
        assets:
          - databaseTable: "kubecost_assets_data"
            window: "7d"
            aggregate: "cluster"
        cloudCosts:
          - databaseTable: "kubecost_cloudcosts_data"
            window: "7d"
            aggregate: "service"

# REQUIRED. Aggregator must be enabled and running as a statefulset.
kubecostAggregator:
  deployMethod: "statefulset"
kubecostModel:
  federatedStorageConfigSecret: "federated-store"
prometheus:
  server:
    global:
      external_labels:
        cluster_id: "primary-cluster-1"

# REQUIRED. A Kubecost Enterprise license key.
kubecostProductConfigs:
  productKey:
    enabled: true
    key: "my-enterprise-key-here"
```

Multiple inserts into the database per day will not create duplicate data. All queries to the database are keyed on a unique `name`, `windowStart`, and `windowEnd`. If a key already exists in the database, we update the entry with the new data.

You can also specify a Kubernetes secret containing the database credentials via `databaseSecretName`. Below is an example of what the secret should look like.

<details>
<summary> Example Kubernetes secret </summary>

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: NAME_OF_YOUR_SECRET_HERE
type: Opaque
stringData:
  creds.json: |-
    {
        "host": "",
        "port": "",
        "databaseName": "",
        "user": "",
        "password": ""
    }
```

</details>

### Step 2: Apply and validate your changes

If deploying changes via Helm, you will be able to run a command similar to:

```bash
helm upgrade -i kubecost cost-analyzer \
  --repo https://kubecost.github.io/cost-analyzer/ \
  --namespace kubecost \
  -f values.yaml
```

Once you've applied your changes, validate that the integration is successful by checking the Aggregator pod logs. You should see logs similar to the following:

```bash
kubectl logs statefulset/kubecost-aggregator -n kubecost | grep -i "Integrations"
```

```txt
INF Integrations: Postgres: initializing cronjob
INF Integrations: Postgres: Allocations: successfully queried http://localhost:9004/allocation?aggregate=namespace&idle=true&shareIdle=false&shareLabels=&shareNamespaces=&window=7d and inserted into REDACTED:kubecost_allocation_data
INF Integrations: Postgres: Allocations: successfully queried http://localhost:9004/allocation?aggregate=cluster&idle=true&shareIdle=false&shareLabels=&shareNamespaces=&window=10d and inserted into REDACTED:kubecost_allocation_data2
INF Integrations: Postgres: Assets: successfully queried http://localhost:9004/assets?aggregate=cluster&window=7d and inserted into REDACTED:kubecost_assets_data
INF Integrations: Postgres: CloudCosts: successfully queried http://localhost:9004/cloudCost?aggregate=service&window=7d and inserted into REDACTED:kubecost_cloud_costs
```
