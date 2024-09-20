# Integrating Kubecost with Datadog

Datadog is a monitoring and security platform which teams use for cloud applications or cloud monitoring as a service. It is possible to integrate your installed Kubecost with Datadog to receive real-time cost monitoring and visualization in your Datadog dashboard. This article will show you everything you need to do this.

## Prerequisites

Before you get started, you will need the following:

* Install [kubectl](https://kubernetes.io/docs/tasks/tools/), [Helm](https://helm.sh/docs/intro/install/), and GNU Wget
* Datadog account with API key and account permissions to create dashboards
* Kubernetes cluster with permission to access and deploy new workloads

## Step 1: Install Datadog agent

When installing your Datadog agent, you need to enable the following flags to allow the Datadog agent to collect the metrics from Kubecost’s cost-model container:

* `datadog.prometheusScrape.enabled=true`
* `datadog.prometheusScrape.serviceEndpoints=true`

To do this, start by setting up your Datadog API key as an environment variable. You can get the API key after logging into your Datadog account by selecting your account > _Organization Settings_ > _API Keys_. The value of `DATADOG_API_KEY` below can be found by selecting the line item and copying your API key (do not use the value in the Key ID column).

```sh
export DATADOG_API_KEY="<DATADOG_KEY_ID>"
```

Finally, install the Datadog agent with your API key using the following command:

```sh
helm repo add datadog https://helm.datadoghq.com
helm upgrade -i datadog-agent datadog/datadog \
--set datadog.site='us5.datadoghq.com' \
--set datadog.apiKey=$<DATADOG_KEY_ID> \
--set datadog.prometheusScrape.enabled=‘true’ \
--set datadog.prometheusScrape.serviceEndpoints=‘true’
```

## Step 2: Install Kubecost

Install Kubecost using the following command to allow the Datadog agent to collect the metrics:

{% code overflow="wrap" %}
```sh
helm upgrade --install kubecost --namespace kubecost --create-namespace \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  -f https://raw.githubusercontent.com/kubecost/poc-common-configurations/main/datadog/datadog-values.yaml \
  --set kubecostToken="aGVsbUBrdWJlY29zdC5jb20=xm343yadf98"
```
{% endcode %}

Allow 3-5 minutes to have the Kubecost installation completed, at which point the metrics are pushed into your Datadog account. Run the following command to enable port-forwarding and expose the Kubecost dashboard:

```
kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090
```

You can now access the Kubecost dashboard by navigating to `http://localhost:9090` in your web browser.

## Step 3: Importing Kubecost dashboard

First, verify if your Kubecost metrics are available in your Datadog account by using Datadog's [Metrics Explorer](https://docs.datadoghq.com/metrics/explorer/) interface, looking for metrics starting with `kubecost`.

Once you have verified that Kubecost metrics are pushed into your Datadog account, you can download our example Datadog dashboard `Kubecostdashboard.json` and import it into your Datadog account to visualize the Kubecost cost allocation data. Use the following command:

{% code overflow="wrap" %}
```
wget https://raw.githubusercontent.com/kubecost/poc-common-configurations/main/datadog/Kubecostdashboard.json
```
{% endcode %}

In Datadog, select _Dashboards_ in the left navigation, then select _New Dashboard_ in the top right corner of the Dashboards page. The Create a Dashboard window opens. Create a name for your dashboard and add any relevant teams if applicable. Then, select _New Dashboard_.

On your dashboard, select the gear icon in the top right corner, then select _Import dashboard JSON..._ Add the _Kubecostdashboard.json_ file and the dashboard should automatically import. The example dashboard gives you the overview of your cluster’s monthly cost and the costs at higher levels of granularity such as containers or namespaces. See the screenshot below depicting a successful import.

![Example Kubecost dashboard in Datadog](/.gitbook/assets/datadog-dash.png)

For extra help, read Datadog's [Copy, import, or export dashboard JSON](https://docs.datadoghq.com/dashboards/#copy-import-or-export-dashboard-json) documentation to learn how to import a dashboard JSON.
