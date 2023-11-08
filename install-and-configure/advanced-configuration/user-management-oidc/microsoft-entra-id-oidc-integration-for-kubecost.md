# Microsoft Entra ID OIDC Integration for Kubecost

{% hint style="info" %}
OIDC is only officially supported on Kubecost Enterprise plans.
{% endhint %}

This guide will take you through configuring OIDC for Kubecost using a Microsoft Entra ID (formerly Azure AD) integration for SSO and RBAC.

## Prerequisites

Before following this guide, ensure that:

* Kubecost is already installed
* Kubecost is accessible via a TLS-enabled ingress
* You are established as a [Cloud Application Administrator](https://learn.microsoft.com/en-us/entra/identity/role-based-access-control/permissions-reference#cloud-application-administrator) in Microsoft. This may otherwise prevent you from accessing certain features required in this tutorial.

## Entra ID OIDC configuration

### Step 1: Registering your application in Entra ID

1. In the [Microsoft Entra admin center](https://entra.microsoft.com/#home), select _Azure Active Directory_.
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

### Step 3 (optional): Configuring RBAC

First, you need to configure an admin role for your app. For more information on this step, see [Microsoft's documentation](https://learn.microsoft.com/en-us/entra/identity-platform/howto-add-app-roles-in-apps).

1. Return to the Overview page for the application you created in Step 1.
2. Select _App roles_ > _Create app role_. Provide the following values:
  * Display name: _admin_
  * Allowed member types: _Users/Groups_
  * Value: _admin_
  * Description: _Admins have read/write permissions via the Kubecost frontend_ (or provide a custom description as needed)
  * Do you want to enable this app role?: Select the checkbox
3. Select _Apply_.

Then, you need to attach the role you just created to users and groups.

1. 
