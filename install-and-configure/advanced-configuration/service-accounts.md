# Service Accounts

Service Accounts are a way to allow programmatic access to the Kubecost API while having SAML or OIDC enabled.

## Limitations

- This is an enterprise only feature.
- All service account keys have administrator level access.
- Not all API endpoints are available with a key; only the endpoints of the aggregator service are available.
- Service keys can be created at any time, but will only be checked if SAML or OIDC is enabled. See [SAML documentation](user-management-saml) or [OIDC documentation](user-management-oidc).

## How to create a application key

- Go to the Service Accounts page
- Provide a name
- Click 'Create Key' and the key will be visible. The key will not be visible again; Kubecost does not store the key.

## How to use an application key

- Client must send a `X-API-KEY` header with each request, and the value of the header must be the API key.

### Example with cURL

```shell
curl -H "X-API-Key:exampleAPIKey" "https:/kubecost.example.com/model/allocation?window=1d"
```