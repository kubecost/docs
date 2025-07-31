# User Management (SAML)

{% hint style="info" %}
SSO and RBAC are Kubecost Enterprise only features.
{% endhint %}

Kubecost supports single sign-on (SSO) and role-based access control (RBAC) with SAML 2.0. Kubecost works with most identity providers including Okta, Auth0, Microsoft Entra ID ([formerly Azure AD](https://learn.microsoft.com/en-us/azure/active-directory/fundamentals/new-name)), PingID, and KeyCloak.

## Overview of features

- User authentication (`.Values.saml`): SSO provides a simple mechanism to restrict application access internally and externally
- Pre-defined user roles (`.Values.saml.rbac`):
  - `admin`: Full control with permissions to manage users, configure model inputs, and application settings.
  - `readonly`: User role with read-only permission.
  - `editor`: Role can change and build alerts and reports, but cannot edit application settings and otherwise functions as read-only.
- Custom access roles (_filters.json_): Limit users based on attributes or group membership to view a set of namespaces, clusters, or other aggregations

{% code overflow="wrap" %}

```yaml
# EXAMPLE CONFIGURATION
# View setup guides below, for full list of Helm configuration values
saml:
  enabled: true
  secretName: "kubecost-okta"
  idpMetadataURL: "https://your.idp.subdomain.okta.com/app/exk4h09oysB785123/sso/saml/metadata"
  appRootURL: "https://kubecost.your.com"
  authTimeout: 1440
  audienceURI: "https://kubecost.your.com"
  nameIDFormat: "urn:oasis:names:tc:SAML:2.0:attrname-format:basic"
  rbac:
    enabled: true
    groups:
      - name: admin
        enabled: true
        assertionName: "kubecost_group"
        assertionValues:
          - "kubecost_admin"
          - "kubecost_superusers"
      - name: readonly
        enabled: true
        assertionName: "kubecost_group"
        assertionvalues:
          - "kubecost_users"
    customGroups:
      - assertionName: "kubecost_group"
```

{% endcode %}

## SAML setup guides

- [Microsoft Entra ID (formerly Azure AD) SAML Integration for Kubecost](microsoft-entra-id-saml-integration-for-kubecost.md)
- [Okta setup guide](okta-saml-integration.md)

{% hint style="info" %}
All SAML 2.0 providers also work. The above guides can be used as templates for what is required.
{% endhint %}

## Using the Kubecost API

When SAML SSO is enabled in Kubecost, the following ports will require authentication:

- `service/kubecost-cost-analyzer`: ports 9003 and 9090
- `service/kubecost-aggregator`: port 9004

{% code overflow="wrap" %}

```bash
curl -L 'http://kubecost.mycompany.com/model/allocation?window=1d' \
  -H 'Cookie: token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJhdWQiOlsiYWRtaW4iLCJncm91cDprdWJlY29zdF9hZG1pbiIsImdyb3VwOmFkbWluQG15Y29tcGFueS5jb20iXSwiZXhwIjoxNjkwMzA2MjYwLjk0OTYyMX0.iLbUuMo0eYhNg0hzv_EEHLIX5Z0du4woPevX3wEnAh8'
```

{% endcode %}

For admins, Kubecost additionally exposes unauthenticated APIs:

`service/kubecost-cost-analyzer`: port 9007

```bash
kubectl port-forward service/kubecost-cost-analyzer 9007:9007
curl -L 'localhost:9007/allocation?window=1d&aggregate=namespace'
```

`service/kubecost-aggregator`: port 9008

```bash
kubectl port-forward service/kubecost-aggregator 9008:9008
curl -L 'localhost:9008/allocation?window=1d&aggregate=namespace'
```

## View your SAML Group

You will be able to view your current SAML Group in the Kubecost UI by selecting _Settings_ from the left navigation, then scrolling to 'SAML Group'. Your access level will be displayed in the 'Current SAML Group' box.

## Read-only mode

Kubecost's SAML supports read-only mode. This leverages SAML for authentication, then assigns all authenticated users as read-only users. Note, that this overrides any existing RBAC configurations.

```yaml
saml:
  enabled: true
readonly: true
```

## Troubleshooting

1. Disable SAML and verify that the `cost-analyzer` pod starts successfully. If the `aggregator` pod is enabled, verify it also starts successfully.
2. If Step 1 is successful but re-enabling SAML causes the pod to crash or never enter the ready state, it is likely there is panic when parsing SAML data. Run `kubectl logs services/kubecost-aggregator` for further details.

If you have specified a `.Values.saml.idpMetadataURL`, try running `curl` from within the `kubecost` pod and ensure that a valid XML EntityDescriptor is being returned and downloaded. The response should be in the format shown below. Kubecost expects both `entityID` and `IDPSSODescriptor.SingleSignOnService.Location` to exist in the response.

{% code overflow="wrap" %}

```bash
$ kubectl exec deployment/kubecost-cost-analyzer -c cost-analyzer-frontend -n kubecost -it -- /bin/sh
$ curl https://dev-elu2z98r.auth0.com/samlp/metadata/c6nY4M37rBP0qSO1IYIqBPPyIPxLS8v2

<EntityDescriptor entityID="urn:dev-elu2z98r.auth0.com" xmlns="urn:oasis:names:tc:SAML:2.0:metadata">
  <IDPSSODescriptor protocolSupportEnumeration="urn:oasis:names:tc:SAML:2.0:protocol">
    <KeyDescriptor use="signing">
      <KeyInfo xmlns="http://www.w3.org/2000/09/xmldsig#">
        <X509Data>
         <X509Certificate>...</X509Certificate>
        </X509Data>
      </KeyInfo>
    </KeyDescriptor>
    <SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="https://dev-elu2z98r.auth0.com/samlp/c6nY4M37rBP0qSO1IYIqBPPyIPxLS8v2/logout"/>
    <SingleLogoutService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://dev-elu2z98r.auth0.com/samlp/c6nY4M37rBP0qSO1IYIqBPPyIPxLS8v2/logout"/>
    <NameIDFormat>urn:oasis:names:tc:SAML:1.1:nameid-format:emailAddress</NameIDFormat>
    <NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:persistent</NameIDFormat>
    <NameIDFormat>urn:oasis:names:tc:SAML:2.0:nameid-format:transient</NameIDFormat>
    <SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-Redirect" Location="https://dev-elu2z98r.auth0.com/samlp/c6nY4M37rBP0qSO1IYIqBPPyIPxLS8v2"/>
    <SingleSignOnService Binding="urn:oasis:names:tc:SAML:2.0:bindings:HTTP-POST" Location="https://dev-elu2z98r.auth0.com/samlp/c6nY4M37rBP0qSO1IYIqBPPyIPxLS8v2"/>
    <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="E-Mail Address" xmlns="urn:oasis:names:tc:SAML:2.0:assertion"/>
    <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/givenname" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Given Name" xmlns="urn:oasis:names:tc:SAML:2.0:assertion"/>
    <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Name" xmlns="urn:oasis:names:tc:SAML:2.0:assertion"/>
    <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/surname" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Surname" xmlns="urn:oasis:names:tc:SAML:2.0:assertion"/>
    <Attribute Name="http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier" NameFormat="urn:oasis:names:tc:SAML:2.0:attrname-format:uri" FriendlyName="Name ID" xmlns="urn:oasis:names:tc:SAML:2.0:assertion"/>
  </IDPSSODescriptor>
</EntityDescriptor>
```

{% endcode %}

### Common SAML errors

**The URL returns a 404 error or returning HTML**

Contact your SAML admin to find the URL on your identity provider that serves the raw XML file.

**Returning an EntitiesDescriptor instead of an EntityDescriptor**

Certain metadata URLs could potentially return an EntitiesDescriptor, instead of an EntityDescriptor. While Kubecost does not currently support using an EntitiesDescriptor, you can instead copy the EntityDescriptor into a new file you create called metadata.xml:

- Download the XML from the metadata URL into a file called _metadata.xml_
- Copy all the attributes from `EntitiesDescriptor` to the `EntityDescriptor` that are not present.
- Remove the `<EntitiesDescriptor>` tag from the beginning.
- Remove the `</EntitiesDescriptor>` from the end of the XML file.

You are left with data in a similar format to the example below:

{% code overflow="wrap" %}

```xml
<EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata" xmlns:dsig="http://www.w3.org/2000/09/xmldsig#" entityID="kubecost-entity-id">
  ....
</EntityDescriptor>
```

{% endcode %}

Then, you can upload the EntityDescriptor to a secret in the same namespace as kubecost and use that directly.

`kubectl create secret generic metadata-secret --from-file=./metadata.xml --namespace kubecost`

To use this secret, in your helm values set metadataSecretName to the name of the secret created above, and set idpMetadataURL to the empty string:

```yaml
saml:
  metadataSecretName: "metadata-secret"
  idpMetadataURL: ""
```

**Invalid NameID format**

On Keycloak, if you receive an "Invalid NameID format" error, you should set the option "force nameid format" in Keycloak. See [Keycloak docs](https://www.keycloak.org/documentation) for more details.

**Users of CSI driver for storing SAML secret**

For users who want to use CSI driver for storing SAML secret, we suggest this [guide](https://secrets-store-csi-driver.sigs.k8s.io/topics/sync-as-kubernetes-secret.html).

**InvalidNameIDPolicy format**

From a [PingIdentity article](https://support.pingidentity.com/s/article/Cannot-provide-requested-name-identifier-qualified-with-SampleNameNEW):

> An alternative solution is to add an attribute called `SAML_SP_NAME_QUALIFIER` to the connection's attribute contract with a TEXT value of the requested SPNameQualifier. When you do this, select the following for attribute name format: `urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified`

On the PingID side: specify an attribute contract `SAML_SP_NAME_QUALIFIER` with the format `urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified`.

On the Kubecost side: in your Helm values, set `saml.nameIDFormat` to the same format set by PingID:

```yaml
saml:
  nameIDFormat: "urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified"
```

Make sure `audienceURI` and `appRootURL` match the entityID configured within PingFed.
