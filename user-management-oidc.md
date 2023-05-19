# User Management (SSO/OIDC/RBAC)

{% hint style="info" %}
OIDC and RBAC are only officially supported on Kubecost Enterprise plans.
{% endhint %}

## Helm configuration

The OIDC integration in Kubecost is fulfilled via the `.Values.oidc` configuration parameters in the Helm chart.

```yaml
oidc:
   enabled: true
   clientID: "" # application/client client_id parameter obtained from provider, used to make requests to server
   clientSecret: "" # application/client client_secret parameter obtained from provider, used to make requests to server
   secretName: "kubecost-oidc-secret" # k8s secret where clientSecret will be stored
   authURL: "https://my.auth.server/authorize" # endpoint for login to auth server
   loginRedirectURL: "http://my.kubecost.url/model/oidc/authorize" # Kubecost url configured in provider for redirect after authentication
   discoveryURL: "https://my.auth.server/.well-known/openid-configuration" # url for OIDC endpoint discovery
#  hostedDomain: "example.com" # optional, blocks access to the auth domain specified in the hd claim of the provider ID token
```

{% hint style="info" %}
&#x20;`authURL` may require additional request parameters depending on the provider. Some commonly required parameters are `client_id=***` and `response_type=code`. Please check the provider documentation for more information.
{% endhint %}

## Supported identity providers

Please refer to the following references to find out more about how to configure the Helm parameters to suit each OIDC identiy provider integration.

* [Auth0 docs](https://auth0.com/docs/get-started/authentication-and-authorization-flow/add-login-auth-code-flow)
* [Azure docs](https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-protocols-oidc#send-the-sign-in-request)
* [Gluu docs](https://gluu.org/docs/gluu-server/4.0/admin-guide/openid-connect/)
* [Keycloak](/user-management-oidc-keycloak.md)
* [Google OAuth 2.0 docs](https://developers.google.com/identity/openid-connect/openid-connect#authenticatingtheuser)
* [Okta docs](https://developer.okta.com/docs/reference/api/oidc/#request-parameters)

{% hint style="info" %}
Auth0 does not support Introspection; therefore we can only validate the access token by calling /userinfo within our current remote token validation flow. This will cause the Kubecost UI to not function under an Auth0 integration, as it makes a large number of continuous calls to load the various components on the page and the Auth0 /userinfo endpoint is rate limited. Independent calls against Kubecost endpoints (eg. via cURL or Postman) should still be supported.
{% endhint %}

## Token validation

Once the Kubecost application has been successfully integrated with OIDC, we will expect requests to Kubecost endpoints to contain the JWT access token, either:

* as a cookie named `token`, or
* as part of the Authorization header `Bearer token`

The token is then validated remotely in one of two ways:

1. POST request to Introspect URL configured by identity provider
2. If no Introspect URL configured, GET request to /userinfo configured by identity provider

### Hosted domain

{% hint style="info" %}
This parameter is only supported if using the Google OAuth 2.0 identity provider
{% endhint %}

If the `hostedDomain` parameter is configured in the Helm chart, the application will deny access to users for which the identified domain is not equal to the specified domain. The domain is read from the `hd` claim in the ID token commonly returned alongside the access token.

If the domain is configured alongside the access token, then requests should contain the JWT ID token, either:

* as a cookie named `id_token`, or
* as part of an `Identification` header.

The JWT ID token must contain a field (claim) named `hd` with the desired domain value. We verify that the token has been properly signed (using provider certificates) and has not expired before processing the claim.

To remove a previously set Helm value, you will need to set the value to an empty string: `.Values.oidc.hostedDomain = ""`. To validate that the config has been removed, you can check the `/var/configs/oidc/oidc.json` inside the cost-model container.
