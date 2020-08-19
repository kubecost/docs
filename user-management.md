Kubecost’s SSO/SAML support makes it easy to manage application access and works with top identity providers, incuding Okta, Auth0, AzureAD and more. Here are the high-level options for access supported:

* **User authentication** provides a simple mechanism to restrict application access internally and externally  
* **Namespace-level access** restrict a user's access to a limited set of namespaces  
* **Pre-defined user roles** can be managed to provide tiered access  
    * Admin: has permissions to manage users, configure model inputs, and application settings.  
    * Viewer: user role with read-only permission  


<br/><br/>

SAML troubleshooting

Disable SAML and confirm that the cost-analzyer pod starts. 
If that is successful, but when SAML is added the pod is crashing or never enters the ready state, it is likely that there is panic loading or parsing SAML data. You should be able to pull the logs by fetching logs for the previous pod:

kubectl logs -n kubecost <pod-name> --previous

If you’re supplying the SAML from the address of an Identity Provider Server: curl the saml metadata endpoint from within the kubecost pod and ensure that a valid XML EntityDescriptor is being returned and downloaded. The response should be in this format:
```
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
Common errors are this URL 404-ing or returning HTML. Contact your SAML admin to find the URL on your identity provider that serves the raw XML file.
