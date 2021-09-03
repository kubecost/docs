Namespace Contacts
==================

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

Edit this doc on [Github](https://github.com/kubecost/docs/blob/master/namespace-contacts.md)

<!--- {"article":"4407595972119","section":"4402815656599","permissiongroup":"1500001277122"} --->