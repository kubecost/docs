# Kubecost Turbonomic Integration

{% hint style="info" %}
This integration is currently in beta. Please read the documentation carefully.
{% endhint %}

The Turbonomic Integration feature enables users to obtain supplemental cost information on actions recommended by Turbonomic. This integration is required for the [Turbonomic Savings APIs](../apis/savings-apis/turbonomic-savings-apis.md).  

## Usage

Prerequisites:

- A running Turbonomic client 

Kubecost will require network access to your Turbonomic installation via an OAuth 2.0 Client. We require the following settings on the OAuth client:
- Role: `ADVISOR`
- ClientAuthenticationMethods: `client_secret_post`

Please see the [IBM Turbonomic documentation](https://www.ibm.com/docs/en/tarm/8.14.3?topic=cookbook-authenticating-oauth-20-clients-api#cookbook_administration_oauth_authentication__title__4) on more instructions on how to create an OAuth 2.0 client. 

### Step 1: Configure Helm values 

The below YAML is an example of how to configure the Turbonomic integration in your Helm values file. 

```yaml
global:
  integrations:
    turbonomic:
      enabled: true
      clientId: ""          # REQUIRED. OAuth 2.0 client ID
      clientSecret: ""      # REQUIRED. OAuth 2.0 client secret
      role: "ADVISOR"       # REQUIRED. OAuth 2.0 client role
      host: ""              # REQUIRED. URL to the Turbonomic API (e.g. "https://turbonomic.example.com")
      insecureClient: false # Whether to verify certificate or not. Default false.
```

### Step 2: Apply and validate your changes

If deploying changes via Helm, you will be able to run a command similar to:

```sh
helm upgrade -i kubecost cost-analyzer \
  --repo https://kubecost.github.io/cost-analyzer/ \
  --namespace kubecost \
  -f values.yaml
```

Once you've applied your changes, validate that the integration is successful by checking the Aggregator pod logs. You should see logs similar to the following:

```sh
kubectl logs statefulset/kubecost-aggregator -n kubecost | grep -i "Turbonomic"
```

```txt
DBG Turbonomic: Ingestor: completed run with 32 turbonomic actions ingested
```