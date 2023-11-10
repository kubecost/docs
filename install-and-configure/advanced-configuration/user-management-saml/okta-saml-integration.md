# Okta SAML Integration for Kubecost

{% hint style="info" %}
SSO and RBAC are only officially supported on Kubecost Enterprise plans.
{% endhint %}

This guide will show you how to configure Kubecost integrations for SSO and RBAC with Okta.

## Okta SSO configuration

To enable SSO for Kubecost, this tutorial will show you how to create an application in Okta.

1. Go to the Okta admin dashboard (https://[your-subdomain]okta.com/admin/dashboard) and select _Applications_ from the left navigation. On the Applications page, select _Create App Integration_ > _SAML 2.0_ > _Next_.
2. On the 'Create SAML Integration' page, provide a name for your app. Feel free to also use this [official Kubecost logo](https://github.com/kubecost/poc-common-configurations/blob/main/saml-okta/images/kubecost-logo.png) for the App logo field. Then, select _Next_.
3. Your SSO URL should be your application root URL followed by '/saml/acs', like: https://[your-kubecost-address].com/saml/acs
4. Your Audience URI (SP Entity ID) should be set to your application root without a trailing slash: https://[your-kubecost-address.com
5. (Optional) If you intend to use RBAC: under Group Attribute Statements, enter a name (ex: _kubecost_group_) and a filter based on your group naming standards (example _Starts with kubecost__). Then, select _Next_.
6. Provide any feedback as needed, then select _Finish_.
7. Return to the Applications page, select your newly-created app, then select the _Sign On_ tab. Copy the URL for _Identity Provider metadata_, and add that value to `.Values.saml.idMetadataURL` in this [_values-saml.yaml_](https://github.com/kubecost/poc-common-configurations/blob/main/saml-okta/values-saml.yaml) file.

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

```
helm upgrade --install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost --create-namespace \
  -f values-saml.yaml
```

At this point, test your SSO to ensure it is working properly before moving on to the next section.

## Okta RBAC configuration (admin/readonly)

The simplest form of RBAC in Kubecost is to have two groups: `admin` and `readonly`. If your goal is to simply have these two groups, you do not need to configure filters. This will result in the logs message: `file corruption: '%!s(MISSING)'`, but this is expected.

The [values-saml.yaml](https://github.com/kubecost/poc-common-configurations/blob/main/saml-okta/values-saml.yaml) file contains the `admin` and `readonly` groups in the RBAC section:

```
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

Filters are used to give visibility to a subset of objects in Kubecost. Examples of the various filters available are in [filters.json](https://github.com/kubecost/poc-common-configurations/blob/main/saml-okta/filters.json) and [filters-examples.json](https://github.com/kubecost/poc-common-configurations/blob/main/saml-okta/filters-examples.json). RBAC filtering is capable of all the same types of filtering features as that of the [Allocation API](/apis/apis-overview/api-allocation.md).

It's possible to combine filtering with admin/readonly rights

These filters can be configured using groups or user attributes in your Okta directory. It is also possible to assign filters to specific users. The example below is using groups.

Filtering is configured very similarly to the admin/readonly above. The same group pattern match (kubecost_group) can be used for both, as is the case in this example:

```
    customGroups: # not needed for simple admin/readonly RBAC
      - assertionName: "kubecost_group"
```

The array of groups obtained during the auth request will be matched to the subject key in the filters.json:

```
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

1. Go to the Okta admin dashboard (https://[your-subdomain]okta.com/admin/dashboard) and select _Directory_ > _Groups_ from the left navigation. On the Groups page, select _Add group_.

2. Create groups for *kubecost_users*, *kubecost_admin* and *kubecost_dev-namespaces* by providing each value as the name with an optional description, then select _Save_. You will need to perform this step three times, one for each group.

3. Go to *Directory* > *People*, and add all users to the *kubecost_users* group and the appropriate users to each of the other groups for testing. You can do this by selecting users, then providing the relevant groups in the _Groups_ tab. Select _Save_ to confirm edits to a user. Kubecost admins will be part of both the read only *kubecost_users* and *kubecost_admin groups*. Kubecost will assign the most rights if there are conflicts.

4. Return to the Groups page. In *kubecost_users* > Application tab, assign the Kubecost application. You do not need to assign the other *kubecost_* groups to the Kubecost application because all users already have access in the *kubecost_users* group.

Modify filters.json as depicted above.

Create the configmap:

kubectl create configmap group-filters --from-file filters.json -n kubecost
Note: that you can modify the configmap without restarting any pods.

kubectl delete configmap -n kubecost group-filters && kubectl create configmap -n kubecost group-filters --from-file filters.json
