# Namespace Contacts

> &#x20;**Note:** The `setNamespaceAttributes` and `getNamespaceAttributes` API endpoints were removed in v1.88.0 and are now **deprecated**.

Use the following API to set a namespace owner, contact info and enable/disable email alerts. This API is available at:

`http://<kubecost-address>/api/setNamespaceAttributes`

Here's an example address:

`http://localhost:9090/api/setNamespaceAttributes`

You should pass a POST variable in this format:

```
namespaces: {
  kubecost: {
    ownerLabel: "Ajay Tripathy", 
    email: "ajay@kubecost.com", 
    sendAlert: "true"
  }
}
```

Expected response: this API should return a 200 response code with JSON string representation of the object passed.
