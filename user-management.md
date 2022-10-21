User Management - SSO/SAML/RBAC
================================

> **Note**: SSO and RBAC capabilities are only included with a Kubecost Enterprise Subscription.

Kubecost supports access control/Single Sign On (SSO) with SAML 2.0. Kubecost works with most identity providers including Okta, Auth0, AzureAD, PingID, and KeyCloak.

## High-level access control options

* **User authentication** SSO provides a simple mechanism to restrict application access internally and externally
* **Custom access roles** Limit users based on attributes or group membership to view a set of namespaces, labels, cluster, or other aggregations
* **Pre-defined user roles**
    * admin: full control with permissions to manage users, configure model inputs, and application settings.
    * readonly: user role with read-only permission
    * editor: role can change and build alerts and reports, but cannot edit application settings and otherwise functions as read-only.

## Setup guides

- [AzureAD setup guide](https://github.com/kubecost/poc-common-configurations/tree/main/saml-azuread)
- [Okta setup guide](https://github.com/kubecost/poc-common-configurations/tree/main/saml-okta)

 > **Note**: All SAML 2.0 providers also work. The above guides can be used as templates for what is required.

## SAML troubleshooting guide
1. Disable SAML and confirm that the cost-analyzer pod starts.
2. If Step 1 is successful, but the pod is crashing or never enters the ready state when SAML is added, it is likely that there is panic loading or parsing SAML data. You should be able to pull the logs by fetching logs for the previous pod:

`kubectl logs -n kubecost <pod-name> --previous`

If you’re supplying the SAML from the address of an Identity Provider Server: curl the saml metadata endpoint from within the Kubecost pod and ensure that a valid XML EntityDescriptor is being returned and downloaded. The response should be in this format:

```shell
kubectl exec kubecost-cost-analyzer-84fb785f55-2ssgj -c cost-analyzer-frontend -n kubecost -it -- /bin/sh
curl https://dev-elu2z98r.auth0.com/samlp/metadata/c6nY4M37rBP0qSO1IYIqBPPyIPxLS8v2

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

### Common SAML error states are as follows:
**The URL returns a 404 error or returning HTML**

Contact your SAML admin to find the URL on your identity provider that serves the raw XML file.
 
**Returning an EntitiesDescriptor instead of an EntityDescriptor**

Certain metadata URLs could potentially return an EntitiesDescriptor, instead of an EntityDescriptor. While Kubecost does not currently support using an EntitiesDescriptor, you can instead copy the EntityDescriptor into a new file you create called metadata.xml:

* Download the XML from the metadata URL into a file called *metadata.xml*
* Copy all the attributes from `EntitiesDescriptor` to the `EntityDescriptor` that are not present.
* Remove the `<EntitiesDescriptor>` tag from the beginning.
* Remove the `</EntitiesDescriptor>` from the end of the XML file.

You are left with data in a similar format to the example below: 

```xml
<EntityDescriptor xmlns="urn:oasis:names:tc:SAML:2.0:metadata" xmlns:dsig="http://www.w3.org/2000/09/xmldsig#" entityID="kubecost-entity-id">
  .... 
</EntityDescriptor>
```

Then, you can upload the EntityDescriptor to a secret in the same namespace as kubecost and use that directly.

`kubectl create secret generic metadata-secret --from-file=./metadata.xml  --namespace kubecost`

To use this secret, in your helm values set metadataSecretName to the name of the secret created above, and set idpMetadataURL to the empty string:

```yaml
saml:
  metadataSecretName: “metadata-secret”
  idpMetadataURL: “”
```

**Invalid NameID format**

On Keycloak, if you receive an “Invalid NameID format” error, you should set the option “force nameid format” in Keycloak. See [Keycloak docs](https://www.keycloak.org/documentation) for more details.

**Users of CSI driver for storing SAML secret**

For users who want to use CSI driver for storing SAML secret, we suggest this [guide](https://secrets-store-csi-driver.sigs.k8s.io/topics/sync-as-kubernetes-secret.html).

**InvalidNameIDPolicy format**

From the following [PingIdentity article](https://support.pingidentity.com/s/article/Cannot-provide-requested-name-identifier-qualified-with-SampleNameNEW):
>An alternative solution is to add an attribute called "SAML_SP_NAME_QUALIFIER" to the connection's attribute contract with a TEXT value of the requested SPNameQualifier. When you do this, select the following for attribute name format:
`urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified`

On the PingID side: specify an attribute contract “SAML_SP_NAME_QUALIFIER” with the format `urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified`.

On the Kubecost side: in your Helm values, set `saml.nameIDFormat` to the same format set by PingID:

```yaml
saml:
  nameIDFormat: “urn:oasis:names:tc:SAML:1.1:nameid-format:unspecified”
```

Make sure `audienceURI` and `appRootURL` match the entityID configured within PingFed.

Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/user-management.md)

<!--- {"article":"4407595985047","section":"4402815636375","permissiongroup":"1500001277122"} --->
