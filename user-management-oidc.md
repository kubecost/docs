User Management - SSO/OIDC
==========================

> **Note**: OIDC capabilities are only included with a Kubecost Enterprise Subscription.

## Helm configuration

The OIDC integration in Kubecost is fulfilled via the helm configuration parameters `.Values.oidc` [as shown here](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values.yaml).

## Supported identity providers

Please refer to the following references to find out more about how to configure the Helm parameters to suit each OIDC identiy provider integration.

* [Gluu docs](https://gluu.org/docs/gluu-server/4.0/admin-guide/openid-connect/)
* [Okta docs](https://developer.okta.com/docs/reference/api/oidc/#request-parameters)
* [Azure docs](https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-protocols-oidc#send-the-sign-in-request)
* [Google OAuth 2.0 docs](https://developers.google.com/identity/openid-connect/openid-connect#authenticatingtheuser)
* [Auth0 docs](https://auth0.com/docs/get-started/authentication-and-authorization-flow/add-login-auth-code-flow)

> **Note**: Auth0 does not support Introspection; therefore we can only validate the access token by calling /userinfo within our current remote token validation flow. This will cause the Kubecost UI to not function under an Auth0 integration, as it makes a large number of continuous calls to load the various components on the page and the Auth0 /userinfo endpoint is rate limited. Independent calls against Kubecost endpoints (eg. via cURL or Postman) should still be supported.

## Token validation

Once the Kubecost application has been successfully integrated with OIDC, we will expect requests to Kubecost endpoints to contain the JWT access token, either:

* as a cookie named `token`, or
* as part of the Authorization header `Bearer token`

The token is then validated remotely in one of two ways:

1. POST request to Introspect URL configured by identity provider
2. If no Introspect URL configured, GET request to /userinfo configured by identity provider

### Hosted domain

> **Note**: This parameter is only supported if using the Google OAuth 2.0 identity provider

If the `hostedDomain` parameter is configured in the Helm chart, the application will deny access to users for which the identified domain is not equal to the specified domain. The domain is read from the `hd` claim in the ID token commonly returned alongside the access token.

If the domain is configured alongside the access token, then requests should contain the JWT ID token, either:

* as a cookie named `id_token`, or
* as part of an `Identification` header.

The JWT ID token must contain a field (claim) named `hd` with the desired domain value. We verify that the token has been properly signed (using provider certificates) and has not expired before processing the claim.

Removing a previously set Helm value is done by setting `.Values.oidc.hostedDomain = ""`. Simply removing the hostedDomain field from the helm config will not work at the moment.

Validate that the config has been correctly removed by checking that `hostedDomain=""` in the **/var/configs/oidc/oidc.json** file inside the cost-model container.

For Google OAuth 2.0, the domain to match the hostedDomain helm parameter is the hd parameter in the id_token field of the token endpoint response.

Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/user-management-oidc.md)

<!--- {"article":"","section":"4402815636375","permissiongroup":"1500001277122"} --->
