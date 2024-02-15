# Service Accounts

{% hint style="info" %}
Service Accounts are only officially supported on Kubecost Enterprise plans.
{% endhint %}

Service Accounts are a way to allow programmatic access to the Kubecost API while having SAML or OIDC enabled. All service account keys have administrator level access. Not all API endpoints are available with a service account key; only the endpoints of the [Aggregator](/install-and-configure/install/multi-cluster/federated-etl/aggregator.md) service are available.

![Service Accounts](/images/serviceaccounts.png)

Service keys can be created at any time, but will only be checked if SAML or OIDC is enabled. See [SAML documentation](user-management-saml) or [OIDC documentation](user-management-oidc) if you have not configured one yet.

## Creating a Service Account key

Select _Teams_ from the left navigation. You will see a warning at the top of the page if you have not configured SAML or OIDC yet, and will be linked to relevant documentation. Otherwise, continue by selecting the *Service Accounts* header.

Select *Add Service Account*. Provide a name for your service account (this cannot be changed later). Confirm by selecting *Create*. Your service account will be automatically created and added to the Service Accounts page. After selecting *Create*, Kubecost will generate an API Key. Make sure you save this value by selecting the copy icon before closing the Service Account slide panel, as the key will be unretrievable in the future. Kubecost will not store this key value internally. Once the key has been saved, you can close out of the panel.

## Using a Service Account key

To use the generated key, you must send a `X-API-KEY` header with every request to a Kubecost Aggregator API endpoint, and the value of the header must be the API key.

### Example with cURL

```shell
curl -H "X-API-Key:exampleAPIKey" "https:/kubecost.example.com/model/allocation?window=1d"
```