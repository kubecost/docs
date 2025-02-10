# Namespace Contacts

{% hint style="warning" %}
As of v1.88.0 of Kubecost, the `setNamespaceAttributes` and `getNamespaceAttributes`API endpoints are now deprecated. This page should not be consulted.
{% endhint %}

Use the following API to set a namespace owner, contact info and enable/disable email alerts. This API is available at:

`http://<kubecost-address>/api/setNamespaceAttributes`

Here's an example address:

`http://localhost:9090/api/setNamespaceAttributes`

You should pass a POST variable in this format:

```json
namespaces: {
  kubecost: {
    ownerLabel: "John Doe", 
    email: "jdoe@corp.com", 
    sendAlert: "true"
  }
}
```

Expected response: this API should return a 200 response code with JSON string representation of the object passed.
