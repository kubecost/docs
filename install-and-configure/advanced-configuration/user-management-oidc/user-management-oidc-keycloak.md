# Configure Keycloak Identity Provider for Kubecost

{% hint style="info" %}
OIDC is a Kubecost Enterprise only feature.
{% endhint %}

1. Create a new [Keycloak Realm](https://www.keycloak.org/getting-started/getting-started-kube#\_create\_a\_realm).
2. Navigate to _Realm Settings_ > _General_ > _Endpoints_ > _OpenID Endpoint Configuration_ > _Clients_.
3. Select _Create_ to add Kubecost to the list of clients. Define a `clientID`. Ensure the Client Protocol is set to `openid-connect`.
4. Select your newly created client, then go to _Settings_.
   1. Set Access Type to `confidential`.
   2. Set Valid Redirect URIs to `http://YOUR_KUBECOST_ADDRESS/model/oidc/authorize`.
   3. Set Base URL to `http://YOUR_KUBECOST_ADDRESS`.

The [`.Values.oidc`](https://github.com/kubecost/cost-analyzer-helm-chart/blob/721555b6641f72f2fd0c12f737243268923430e0/cost-analyzer/values.yaml#L194-L202) for Keycloak should be as follows:

{% code overflow="wrap" %}
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
{% endcode %}
