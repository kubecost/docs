# User Management (SSO/OIDC)

{% hint style="info" %}
OIDC is only officially supported on Kubecost Enterprise plans.
{% endhint %}

## Overview of features

The OIDC integration in Kubecost is fulfilled via the `.Values.oidc` configuration parameters in the Helm chart.

```yaml
# EXAMPLE CONFIGURATION
# View setup guides below, for full list of Helm configuration values
oidc:
  enabled: true
  useIDToken: false # Set to 'true' for IdP's that use an 'id_token' cookie
  clientID: ""
  clientSecret: ""
  secretName: "kubecost-oidc-secret"
  authURL: "https://my.auth.server/authorize"
  loginRedirectURL: "http://my.kubecost.url/oidc/authorize"
  discoveryURL: "https://my.auth.server/.well-known/openid-configuration"
  skipOnlineTokenValidation: false # Set to 'true' to skip online token validation and attempt to locally validate JWT claims
  rbac:
    enabled: false
    groups:
      - name: admin
        enabled: false
        claimName: "roles"
        claimValues:
          - "admin"
          - "superusers"
      - name: readonly
        enabled: false
        claimName:  "roles"
        claimValues:
          - "readonly"
```

{% hint style="info" %}
`authURL` may require additional request parameters depending on the provider. Some commonly required parameters are `client_id=***` and `response_type=code`. Please check the provider documentation for more information.
{% endhint %}

## Setup guides

* [Microsoft Entra ID (formerly Azure AD) guide](/install-and-configure/advanced-configuration/user-management-oidc/microsoft-entra-id-oidc-integration-for-kubecost.md)
* [Configure Keycloak Identity Provider for Kubecost](/install-and-configure/advanced-configuration/user-management-oidc/user-management-oidc-keycloak.md)
* [Gluu Server with OIDC Configuration Guide](/install-and-configure/advanced-configuration/user-management-oidc/gluu-server-with-oidc-configuration-guide.md)

## Supported identity providers

Please refer to the following references to find out more about how to configure the Helm parameters to suit each OIDC identity provider integration.

* [Auth0 docs](https://auth0.com/docs/get-started/authentication-and-authorization-flow/add-login-auth-code-flow)
* [Azure docs](https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-protocols-oidc#send-the-sign-in-request)
* [Gluu docs](https://gluu.org/docs/gluu-server/4.0/admin-guide/openid-connect/)
* [Keycloak](user-management-oidc-keycloak.md)
* [Google OAuth 2.0 docs](https://developers.google.com/identity/openid-connect/openid-connect#authenticatingtheuser)
* [Okta docs](https://developer.okta.com/docs/reference/api/oidc/#request-parameters)

{% hint style="info" %}
Auth0 does not support Introspection; therefore we can only validate the access token by calling /userinfo within our current remote token validation flow. This will cause the Kubecost UI to not function under an Auth0 integration, as it makes a large number of continuous calls to load the various components on the page and the Auth0 /userinfo endpoint is rate limited. Independent calls against Kubecost endpoints (eg. via cURL or Postman) should still be supported.
{% endhint %}

## Token validation

Once the Kubecost application has been successfully integrated with OIDC, we will expect requests to Kubecost endpoints to contain the JWT access token, either:

* As a cookie named `token`,
* As a cookie named `id_token` (Set `.Values.oidc.useIDToken = true`),
* Or as part of the Authorization header `Bearer token`

The token is then validated remotely in one of two ways:

1. POST request to Introspect URL configured by identity provider
2. If no Introspect URL configured, GET request to /userinfo configured by identity provider

If `skipOnlineTokenValidation` is set to true, Kubecost will skip accessing the OIDC introspection endpoint for online token validation and will instead attempt to locally validate the JWT claims.

{% hint style="danger" %}
Setting `skipOnlineTokenValidation` to `true` will prevent tokens from being manually revoked.
{% endhint %}

### Hosted domain

{% hint style="info" %}
This parameter is only supported if using the Google OAuth 2.0 identity provider
{% endhint %}

If the `hostedDomain` parameter is configured in the Helm chart, the application will deny access to users for which the identified domain is not equal to the specified domain. The domain is read from the `hd` claim in the ID token commonly returned alongside the access token.

If the domain is configured alongside the access token, then requests should contain the JWT ID token, either:

* As a cookie named `id_token`
* As part of an `Identification` header

The JWT ID token must contain a field (claim) named `hd` with the desired domain value. We verify that the token has been properly signed (using provider certificates) and has not expired before processing the claim.

To remove a previously set Helm value, you will need to set the value to an empty string: `.Values.oidc.hostedDomain = ""`. To validate that the config has been removed, you can check the `/var/configs/oidc/oidc.json` inside the cost-model container.

## Read-only mode

Kubecost's OIDC supports read-only mode. This leverages OIDC for authentication, then assigns all authenticated users as read-only users. This overrides any existing RBAC configurations.

```yaml
oidc:
  enabled: true
readonly: true
```

## Troubleshooting

### Option 1: Inspect all network requests made by browser

Use [your browser's devtools](https://developer.chrome.com/docs/devtools/network/) to observe network requests made between you, your Identity Provider, and your Kubecost. Pay close attention to cookies, and headers.

### Option 2: Review logs, and decode your JWT tokens

If `kubecostAggregator.enabled` is `true` or unspecified in `values.yaml`:
```sh
kubectl logs statefulsets/kubecost-aggregator
kubectl logs deploy/kubecost-cost-analyzer
```

If `kubecostAggregator.enabled` is `false` in `values.yaml`:
```sh
kubectl logs services/kubecost-aggregator
kubectl logs deploy/kubecost-cost-analyzer
```

* Search for `oidc` in your logs to follow events
* Pay attention to any `WRN` related to OIDC
* Search for `Token Response`, and try decoding both the `access_token` and `id_token` to ensure they are well formed (https://jwt.io/)

### Option 3: Enable debug logs for more granularity on what is failing

Code reference for the below example can be found [here](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.103/README.md?plain=1#L63-L75).

```yaml
kubecostModel:
  extraEnv:
    - name: LOG_LEVEL
      value: debug
kubecostAggregator:
  extraEnv:
    - name: LOG_LEVEL
      value: debug
```

For further assistance, reach out to support@kubecost.com and provide both logs and a [HAR file](https://support.google.com/admanager/answer/10358597?hl=en).
