User Management - SSO/OIDC
==========================

> **Note**: OIDC capabilities are only included with a Kubecost Enterprise Subscription.

## Helm configuration

The OIDC integration in Kubecost is fulfilled via the helm configuration parameters `.Values.oidc` [as shown here](https://github.com/kubecost/cost-analyzer-helm-chart/blob/721555b6641f72f2fd0c12f737243268923430e0/cost-analyzer/values.yaml#L194-L202).

## Supported identity providers

Please refer to the following references to find out more about how to configure the Helm parameters to suit each OIDC identiy provider integration.

* [Auth0 docs](https://auth0.com/docs/get-started/authentication-and-authorization-flow/add-login-auth-code-flow)
* [Azure docs](https://learn.microsoft.com/en-us/azure/active-directory/develop/v2-protocols-oidc#send-the-sign-in-request)
* [Gluu docs](https://gluu.org/docs/gluu-server/4.0/admin-guide/openid-connect/)
* [Keycloak (see below)](#keycloak-setup)
* [Google OAuth 2.0 docs](https://developers.google.com/identity/openid-connect/openid-connect#authenticatingtheuser)
* [Okta docs](https://developer.okta.com/docs/reference/api/oidc/#request-parameters)

> **Note**: Auth0 does not support Introspection; therefore we can only validate the access token by calling /userinfo within our current remote token validation flow. This will cause the Kubecost UI to not function under an Auth0 integration, as it makes a large number of continuous calls to load the various components on the page and the Auth0 /userinfo endpoint is rate limited. Independent calls against Kubecost endpoints (eg. via cURL or Postman) should still be supported.

## Keycloak setup

1. Create a new [Keycloak Realm](https://www.keycloak.org/getting-started/getting-started-kube#_create_a_realm).
2. Navigate to "Realm Settings" -> "General" -> "Endpoints" -> "OpenID Endpoint Configuration" -> "Clients".
3. Click "Create" to add Kubecost to the list of clients. Define a `clientID`. Ensure the "Client Protocol" is set to `openid-connect`.
4. Click on your newly created client, then go to "Settings".
   1. Set "Access Type" to `confidential`.
   2. Set "Valid Redirect URIs" to `http://YOUR_KUBECOST_ADDRESS/model/oidc/authorize`.
   3. Set "Base URL" to `http://YOUR_KUBECOST_ADDRESS`.

The [`.Values.oidc`](https://github.com/kubecost/cost-analyzer-helm-chart/blob/721555b6641f72f2fd0c12f737243268923430e0/cost-analyzer/values.yaml#L194-L202) for Keycloak should be as follows:

```yaml
oidc:
  enabled: true
  # This should be the same as the `clientID` set in step 3 above
  clientID: "YOUR_CLIENT_ID"
  # Find this in Keycloak UI by going to your Kubecost client, then clicking on "Credentials".
  clientSecret: "YOUR_CLIENT_SECRET"
  # The k8s secret where clientSecret will be stored
  secretName: "kubecost-oidc-secret"
  # The login endpoint for the auth server
  authURL: "http://YOUR_KEYCLOAK_ADDRES/realms/YOUR_REALM_ID/protocol/openid-connect/auth?client_id=YOUR_CLIENT_ID&response_type=code"
  # Redirect after authentication
  loginRedirectURL: "http://YOUR_KUBECOST_ADDRESS/model/oidc/authorize"
  # Navigate to "Realm Settings" -> "General" -> "Endpoints" -> "OpenID Endpoint Configuration". Set to the discovery URL shown on this page.
  discoveryURL: "YOUR_DISCOVERY_URL"
```

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

To remove a previously set Helm value, you will need to set the value to an empty string: `.Values.oidc.hostedDomain = ""`. To validate that the config has been removed, you can check the `/var/configs/oidc/oidc.json` inside the cost-model container.

Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/user-management-oidc.md)


<!--- {"article":"10018767892119","section":"4402815636375","permissiongroup":"1500001277122"} --->