# Microsoft Entra ID OIDC Integration for Kubecost

{% hint style="info" %}
OIDC is only officially supported on Kubecost Enterprise plans. At this time OIDC does not support RBAC.
{% endhint %}

This guide will take you through configuring OIDC for Kubecost using a Microsoft Entra ID (formerly Azure AD) integration for SSO.

## Prerequisites

Before following this guide, ensure that:

* Kubecost is already installed
* Kubecost is accessible via a TLS-enabled ingress
* You are established as a [Cloud Application Administrator](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference#cloud-application-administrator) in Microsoft. This may otherwise prevent you from accessing certain features required in this tutorial.

## Entra ID OIDC configuration

### Step 1: Registering your application in Entra ID

1. In the [Microsoft Entra admin center](https://entra.microsoft.com/#home), select _Microsoft Entra ID (Azure AD)_.
2. In the left navigation, select _Applications_ > _App registrations_. Then, on the App registrations page, select _New registration_.
3. Select an appropriate name, and provide supported account types for your app.
4. To configure `Redirect URI`, select _Web_ from the dropdown, then provide the URI as _https://{your-kubecost-address}/model/oidc/authorize_.
5. Select _Register_ at the bottom of the page to finalize your changes.

### Step 2: Configuring _values.yaml_

1. After creating your application, you should be taken directly to the app's Overview page. If not, return to the App registrations page, then select the application you just created.
2. On the Overview page for your application, obtain the Application (client) ID and the Directory (tenant) ID. These will be needed in a later step.
3. Next to 'Client credentials', select _Add a certificate or secret_. The 'Certificates & secrets' page opens.
4. Select _New client secret_. Provide a description and expiration time, then select _Add_.
5. Obtain the value created with your secret.
6. Add the three saved values, as well as any other values required relating to your Kubecost/Microsoft account details, into the following _values.yaml_ template:

```
# values.yaml
oidc:
  enabled: true
  useIDToken: true
  clientID: "{APPLICATION_CLIENT_ID}"
  clientSecret: "{CLIENT_CREDENTIALS} > {SECRET_VALUE}"
  secretName: "kubecost-oidc-secret"
  authURL: "https://login.microsoftonline.com/{YOUR_TENANT_ID}/oauth2/v2.0/authorize?client_id={YOUR_CLIENT_ID}&response_type=code&scope=openid&nonce=123456"
  loginRedirectURL: "https://{YOUR_KUBECOST_DOMAIN}/model/oidc/authorize"
  discoveryURL: "https://login.microsoftonline.com/{YOUR_TENANT_ID}/v2.0/.well-known/openid-configuration"
```

{% hint style="info" %}
If you are using one Entra ID app to authenticate multiple Kubecost endpoints, you must to pass an additional `redirect_uri` parameter in your `authURL`, which will include the URI you configured in Step 1.4. Otherwise, Entra ID may redirect to an incorrect endpoint. You can read more about this in Microsoft Entra ID's [troubleshooting docs](https://learn.microsoft.com/en-us/troubleshoot/azure/active-directory/reply-url-redirected-to-localhost). View the example below to see how you should format your URI:
{% endhint %}

```
  authURL: "https://login.microsoftonline.com/{YOUR_TENANT_ID}/oauth2/v2.0/authorize?client_id={YOUR_CLIENT_ID}&response_type=code&scope=openid&nonce=123456&redirect_uri=https%3A%2F%2F{YOUR_KUBECOST_DOMAIN}/model/oidc/authorize"
```

## Troubleshooting

### Option 1: Inspect all network requests made by browser

Use your browser's [devtools](https://developer.chrome.com/docs/devtools/network/) to observe network requests made between you, your Identity Provider, and  Kubecost. Pay close attention to cookies and headers.

### Option 2: Review logs, and decode your JWT tokens

Run the following command:

```
kubectl logs deploy/kubecost-cost-analyzer
```

Search for `oidc` in your logs to follow events. Pay attention to any WRN related to OIDC. Search for Token Response, and try decoding both the `access_token` and `id_token` to ensure they are well formed. [Learn more about JSON web tokens](https://jwt.io/).

### Option 3: Enable debug logs for more granularity on what is failing

You can find more details on these flags in Kubecost's [cost-analyzer-helm-chart repo README](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.103/README.md?plain=1#L63-L75).
```
kubecostModel:
  extraEnv:
    - name: LOG_LEVEL
      value: debug
```
