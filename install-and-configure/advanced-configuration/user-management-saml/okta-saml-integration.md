# Okta SAML Integration for Kubecost

{% hint style="info" %}
SSO and RBAC are Kubecost Enterprise only features.
{% endhint %}

This guide will show you how to configure Kubecost integrations for SSO and RBAC with Okta.

## Okta SSO configuration

To enable SSO for Kubecost, this tutorial will show you how to create an application in Okta.

1. Go to the Okta admin dashboard (https://{YOUR-SUBDOMAIN}.okta.com/admin/dashboard) and select _Applications_ from the left navigation. On the Applications page, select _Create App Integration_ > _SAML 2.0_ > _Next_.
2. On the 'Create SAML Integration' page, provide a name for your app. You can use this [official Kubecost logo](https://github.com/kubecost/poc-common-configurations/blob/main/saml-okta/images/kubecost-logo.png) for the App logo field. Select _Next_.
3. Set your SSO URL to your application root URL followed by '/saml/acs': https://{YOUR-KUBECOST-DOMAIN}.com/saml/acs
4. Set your Audience URI (SP Entity ID) to your application root without a trailing slash: https://{YOUR-KUBECOST-DOMAIN}.com
5. (Optional) For RBAC configuration: Under Group Attribute Statements, enter a name (ex: _kubecost_group_) and a filter based on your group naming standards (example _Starts with kubecost__). Select _Next_.
6. Provide any feedback as needed, then select _Finish_.
7. Return to the Applications page, select your newly-created app, then select the _Sign On_ tab. Copy the URL for _Identity Provider metadata_ and add that value to `.Values.saml.idpMetadataURL` in this [_values-saml.yaml_](https://github.com/kubecost/poc-common-configurations/blob/main/saml-okta/values-saml.yaml) file.

![Okta screenshot](/images/okta-saml-1.png)

8. To fully configure SAML 2.0, select _View Setup Instructions_, download the X.509 certificate, and name the file _myservice.cert_.

![Okta screenshot](/images/okta-saml-2.png)

9. Create a secret using the certificate with the following command:

`kubectl create secret generic kubecost-okta --from-file myservice.cert --namespace kubecost`

{% hint style="info" %}
For configuring single app logout, read [Okta's documentation](https://help.okta.com/en-us/content/topics/apps/apps_single_logout.htm) on the subject. then, update the `values.saml:redirectURL`value in your [_values.yaml_](https://github.com/kubecost/poc-common-configurations/blob/main/saml-okta/values-saml.yaml) file.
{% endhint %}

10. Use this [Okta document](https://help.okta.com/en-us/content/topics/apps/apps-manage-assignments.htm) to assign individuals or groups access to your Kubecost application.
11. Finally, add `-f values-saml.yaml` to your Kubecost Helm upgrade command:

```bash
helm upgrade --install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost --create-namespace \
  -f values-saml.yaml
```

At this point, test your SSO to ensure it is working properly before moving on to the next section.

## Okta RBAC configuration (admin/readonly)

The simplest form of RBAC in Kubecost is to have two groups: `admin` and `readonly`. If your goal is to simply have these two groups, you do not need to configure filters. This will result in the logs message: `file corruption: '%!s(MISSING)'`, but this is expected.

The [values-saml.yaml](https://github.com/kubecost/poc-common-configurations/blob/main/saml-okta/values-saml.yaml) file contains the `admin` and `readonly` groups in the RBAC section:

```yaml
  rbac:
    enabled: true
    groups:
      - name: admin
        enabled: true # if admin is disabled, all SAML users will be able to make configuration changes to the kubecost frontend
        assertionName: "kubecost_group" # a SAML Assertion, one of whose elements has a value that matches on of the values in assertionValues
        assertionValues:
          - "kubecost_admin"
          - "kubecost_superusers"
      - name: readonly
        enabled: true # if readonly is disabled, all users authorized on SAML will default to readonly
        assertionName:  "kubecost_group"
        assertionvalues:
          - "kubecost_users"
```

The `assertionName: "kubecost_group"` value needs to match the name given in Step 5 of the Okta SSO Configuration section.

## Okta RBAC configuration (filtering)

Filters are used to give visibility to a subset of objects in Kubecost. Examples of the various filters available are in [filters.json](https://github.com/kubecost/poc-common-configurations/blob/main/saml-okta/filters.json) and [filters-examples.json](https://github.com/kubecost/poc-common-configurations/blob/main/saml-okta/filters-examples.json). RBAC filtering is capable of all the same types of filtering features as that of the [Allocation API](/apis/monitoring-apis/api-allocation.md).

It's possible to combine filtering with admin/readonly rights.

These filters can be configured using groups or user attributes in your Okta directory. It is also possible to assign filters to specific users. The example below is using groups.

Filtering is configured very similarly to the admin/readonly above. The same group pattern match (kubecost_group) can be used for both, as is the case in this example:

```yaml
    customGroups: # not needed for simple admin/readonly RBAC
      - assertionName: "kubecost_group"
```

The array of groups obtained during the authorization request will be matched to the subject key in the _filters.json_:

```json
{
   "kubecost_admin":{
      "allocationFilters":[
         {
            "namespace":"*",
            "cluster":"*"
         }
      ]
   },
   "kubecost_users":{
      "allocationFilters":[
         {
            "namespace":"",
            "cluster":"*"
         }
      ]
   },
   "kubecost_dev-namespaces":{
      "allocationFilters":[
         {
            "namespace":"dev-*,nginx-ingress",
            "cluster":"*"
         }
      ]
   }
}
```

As an example, we will configure the following:

* Admins will have full access to the Kubecost UI and have visibility to all resources
* Kubecost users, by default, will not have visibility to any namespace and will be `readonly`. If a group doesn't have access to any resources, the Kubecost UI may appear to be broken
* The dev-namespaces group will have read only access to the Kubecost UI and only have visibility to namespaces that are prefixed with `dev-` or are exactly `nginx-ingress`

1. Go to the Okta admin dashboard (https://{YOUR-SUBDOMAIN}.okta.com/admin/dashboard) and select _Directory_ > _Groups_ from the left navigation. On the Groups page, select _Add group_.

2. Create groups for _kubecost_users_, _kubecost_admin_ and _kubecost_dev-namespaces_ by providing each value as the name with an optional description, then select _Save_. You will need to perform this step three times, one for each group.

3. Select each group, then select _Assign people_ and add the appropriate users for testing. Select _Done_ to confirm edits to a group. Kubecost admins will be part of both the read only _kubecost_users_ and _kubecost_admin groups_. Kubecost will assign the most rights if there are conflicts.

4. Return to the Groups page. Select _kubecost_users_, then in the _Applications_ tab, assign the Kubecost application. You do not need to assign the other _kubecost__ groups to the Kubecost application because all users already have access in the _kubecost_users_ group.

5. Modify filters.json as depicted above.

6. Create the ConfigMap using the following command:

```bash
kubectl create configmap group-filters --from-file filters.json -n kubecost
```

You can modify the ConfigMap without restarting any pods.

```bash
kubectl delete configmap -n kubecost group-filters && kubectl create configmap -n kubecost group-filters --from-file filters.json
```

## Encrypted SAML claims

1. Generate an X509 certificate and private key. Below is an example using OpenSSL:

   `openssl genpkey -algorithm RSA -out saml-encryption-key.pem -pkeyopt rsa_keygen_bits:2048`

2. Generate a certificate signing request (CSR)

   `openssl req -new -key saml-encryption-key.pem -out request.csr`

3. Request your organization's domain owner to sign the certificate, or generate a self-signed certificate:

   `openssl x509 -req -days 365 -in request.csr -signkey saml-encryption-key.pem -out saml-encryption-cert.cer`

4. Go to your application, then under the _General_ tab, edit the following SAML Settings:

   * Assertion Encryption: _Encrypted_
   * In the Encryption Algorithm box that appears, select _AES256-CBC_.
   * Select _Browse Files_ in the Encryption Certificate field and upload an image file of your certifcate.

5. Create a secret with the certificate. The file name **must** be _saml-encryption-cert.cer_.

   `kubectl create secret generic kubecost-saml-cert --from-file saml-encryption-cert.cer --namespace kubecost`

6. Create a secret with the private key. The file name **must** be _saml-encryption-key.pem_.

   `kubectl create secret generic kubecost-saml-decryption-key --from-file saml-encryption-key.pem --namespace kubecost`

7. Pass the following values via Helm into your _values.yaml_:

   ```yaml
   saml:
      encryptionCertSecret: "kubecost-saml-cert"
      decryptionKeySecret: "kubecost-saml-decryption-key"
   ```

## Troubleshooting

You can look at the logs on the aggregator and cost-model containers. In this example, the assumption is that the prefix for Kubecost groups is `kubecost_`. This script is currently a work in progress.

{% code overflow="wrap" %}

```bash
kubectl logs deployment/kubecost-cost-analyzer -c cost-model --follow |grep -v -E 'resourceGroup|prometheus-server'|grep -i -E 'group|xmlname|saml|login|audience|kubecost_'
```

{% endcode %}

If `kubecostAggregator.enabled` is `true` or unspecified in _values.yaml_:

{% code overflow="wrap" %}

```bash
kubectl logs statefulsets/kubecost-aggregator --follow |grep -v -E 'resourceGroup|prometheus-server'|grep -i -E 'group|xmlname|saml|login|audience|kubecost_'
```

{% endcode %}

If `kubecostAggregator.enabled` is `false` in _values.yaml_:

{% code overflow="wrap" %}

```bash
kubectl logs services/kubecost-aggregator --follow |grep -v -E 'resourceGroup|prometheus-server'|grep -i -E 'group|xmlname|saml|login|audience|kubecost_'
```

{% endcode %}

When the group has been matched, you will see:

{% code overflow="wrap" %}

```console
auth.go:167] AUDIENCE: [readonly group:readonly@kubecost.com]
auth.go:167] AUDIENCE: [admin group:admin@kubecost.com]
```

{% endcode %}

{% code overflow="wrap" %}

```console
configwatchers.go:69] ERROR UPDATING group-filters CONFIG: []map[string]string: ReadMapCB: expect }, but found l, error found in #10 byte of ...|el": "{ "label": "ap|..., bigger context ...|nFilters": [
         {

            "label": "{ "label": "app", "value": "nginx" }"
         }
     |...
```

{% endcode %}

This is what you should expect to see:

{% code overflow="wrap" %}

```console

I0330 14:48:20.556725       1 costmodel.go:3421]   kubecost_user_type: {XMLName:{Space:urn:oasis:names:tc:SAML:2.0:assertion Local:Attribute} FriendlyName: Name:kubecost_user_type NameFormat:urn:oasis:names:tc:SAML:2.0:attrname-format:basic Values:[{XMLName:{Space:urn:oasis:names:tc:SAML:2.0:assertion Local:AttributeValue} Type: Value:}]}
I0330 14:48:20.556767       1 costmodel.go:3421]   firstname: {XMLName:{Space:urn:oasis:names:tc:SAML:2.0:assertion Local:Attribute} FriendlyName: Name:firstname NameFormat:urn:oasis:names:tc:SAML:2.0:attrname-format:basic Values:[{XMLName:{Space:urn:oasis:names:tc:SAML:2.0:assertion Local:AttributeValue} Type: Value:cost_admin}]}
I0330 14:48:20.556776       1 costmodel.go:3421]   kubecost_group: {XMLName:{Space:urn:oasis:names:tc:SAML:2.0:assertion Local:Attribute} FriendlyName: Name:kubecost_group NameFormat:urn:oasis:names:tc:SAML:2.0:attrname-format:basic Values:[{XMLName:{Space:urn:oasis:names:tc:SAML:2.0:assertion Local:AttributeValue} Type: Value:kubecost_admin}]}
I0330 14:48:20.556788       1 log.go:47] [Info] Adding authorizations '[admin group:admin@kubecost.com]' for user
I0330 14:48:20.556802       1 log.go:47] [Info] Token expiration set to 2022-03-31 14:48:20.556796875 +0000 UTC m=+86652.635776798
I0330 14:48:20.589730       1 log.go:47] [Info] Login called
I0330 14:48:20.619630       1 log.go:47] [Info] Attempting to authenticate saml...
I0330 14:48:20.619839       1 costmodel.go:813] Authenticated saml
I0330 14:48:20.702125       1 log.go:47] [Info] Attempting to authenticate saml...
I0330 14:48:20.702229       1 costmodel.go:813] Authenticated saml
...
I0330 14:48:21.011787       1 auth.go:167] AUDIENCE: [admin group:admin@kubecost.com]
```

{% endcode %}
