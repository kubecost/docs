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

## Okta RBAC configuration