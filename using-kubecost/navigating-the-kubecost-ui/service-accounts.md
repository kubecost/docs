# Service Accounts

{% hint style="info" %}
Service Accounts are only officially supported on Kubecost Enterprise plans.
{% endhint %}

Service Accounts are a way to allow programmatic access to the Kubecost API while having SAML or OIDC enabled. All service account keys have administrator level access. Not all API endpoints are available with a service account key; only the endpoints of the [Aggregator](/install-and-configure/install/multi-cluster/federated-etl/aggregator.md) service are available.

![Service Accounts](/images/serviceaccounts.png)

Service keys can be created at any time, but will only be checked if SAML or OIDC is enabled. See [SAML documentation](/install-and-configure/advanced-configuration/user-management-saml/README.md) or [OIDC documentation](/install-and-configure/advanced-configuration/user-management-oidc/user-management-oidc.md) if you have not configured one yet.

## Creating a Service Account key

{% hint style="info" %}
If RBAC through SAML or OIDC is enabled, you must be an admin user to create a service account. See our [Teams](/using-kubecost/navigating-the-kubecost-ui/teams.md) article for configuring roles in the UI, or our user management guides for [SAML](/install-and-configure/advanced-configuration/user-management-saml/README.md) or [OIDC](/install-and-configure/advanced-configuration/user-management-oidc/user-management-oidc.md) for more information.
{% endhint %}

Select _Teams_ from the left navigation. You will see a warning at the top of the page if you have not configured SAML or OIDC yet, and will be linked to relevant documentation. Otherwise, continue by selecting the *Service Accounts* header.

Select *Add Service Account*. Provide a name for your service account (this cannot be changed later). Confirm by selecting *Create*. Your service account will be automatically created and added to the Service Accounts page. After selecting *Create*, Kubecost will generate an API Key. Make sure you save this value by selecting the copy icon before closing the Service Account slide panel, as the key will be unretrievable in the future. Kubecost will not store this key value internally. Once the key has been saved, you can close out of the panel.

## Using a Service Account key

To use the generated key, you must send a `X-API-KEY` header with every request to a Kubecost Aggregator API endpoint, and the value of the header must be the API key.

### Example with cURL

```shell
curl -H "X-API-KEY:exampleAPIKey" "https://kubecost.example.com/model/allocation?window=1d"
```
