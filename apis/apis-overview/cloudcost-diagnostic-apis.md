# Cloud Cost Diagnostic APIs

These APIs are designed to help troubleshoot and provide diagnostics for Kubecost's cloud integration features like Cloud Usage and reconciliation. For an explanation of these integration features, review Kubecost's [cloud processes](/install-and-configure/install/cloud-integration/README.md#kubecosts-cloud-processes).

To review the `provider` parameter for rebuild/run APIs, see [Cloud Stores](/install-and-configure/install/cloud-integration/README.md#cloud-stores).

## Cloud Usage APIs

{% swagger method="get" path="/etl/cloudUsage/rebuild" baseUrl="http://<kubecost-address>/model" summary="Cloud Usage Rebuild API" %}
{% swagger-description %}
Restarts Cloud Usage pipeline. This operation ends the currently running Cloud Usage pipeline and rebuilds historic CloudUsages in the Daily CloudUsage Store.
{% endswagger-description %}

{% swagger-parameter in="path" name="commit" type="boolean" required="true" %}
Flag that acts as a safety precaution. These can be long-running processes so this endpoint should not be run arbitrarily. `true` will restart the process.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="provider" type="string" %}
Optional parameter for the `ProviderKey` of your CSP. If included, only the specified Cloud Store will run the operation. If not included, all Cloud Stores in the ETL will run the operation.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
```
{
    "code": 200,
    "data": "Rebuilding Cloud Usage For All Providers"
}
```
{% endswagger-response %}
{% endswagger %}

{% swagger method="get" path="/etl/cloudUsage/repair" baseUrl="http://<kubecost-address>/model" summary="Cloud Usage Repair API" %}
{% swagger-description %}
Reruns queries for Cloud Usages in the given window for the given Cloud Store or all Cloud Stores if no provider is set.
{% endswagger-description %}

{% swagger-parameter in="path" name="window" required="true" %}
The applicable window for repair by the Cloud Store. See [Using `window` parameter](/apis/apis-overview/assets-api.md#using-window-parameter) for more details.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="provider" type="string" %}
Optional parameter for the `ProviderKey` of your CSP. If included, only the specified Cloud Store will run the operation. If not included, all Cloud Stores in the ETL will run the operation.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
{% code overflow="wrap" %}
```
{
    "code": 200,
    "data": "Cloud Usage Repair process has begun for [<window>) for all providers"
}
```
{% endcode %}
{% endswagger-response %}
{% endswagger %}

## Reconciliation APIs

{% swagger method="get" path="/etl/asset/reconciliation/run" baseUrl="http://<kubecost-address>/model" summary="Reconciliation Run API" %}
{% swagger-description %}
Completely restart reconciliation pipeline. This operation ends the currently running reconciliation pipeline and reconciles historic Assets in the Daily Asset Store.
{% endswagger-description %}

{% swagger-parameter in="path" type="boolean" name="commit" required="true" %}
Flag that acts as a safety precaution. These can be long-running processes so this endpoint should not be run arbitrarily. `true` will restart the process.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="provider" %}
Optional parameter for the `ProviderKey` of your CSP. If included, only the specified Cloud Store will run the operation. If not included, all Cloud Stores in the ETL will run the operation.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
```
{
    "code": 200,
    "data": "Reconciliation Assets For All Providers"
}
```
{% endswagger-response %}
{% endswagger %}

{% swagger method="get" path="/etl/asset/reconciliation/repair" baseUrl="http://<kubecost-address>/model" summary="Reconciliation Repair API" %}
{% swagger-description %}
Reruns queries for reconciliation in the given window for the given Cloud Store or all Cloud Stores if no provider is set.
{% endswagger-description %}

{% swagger-parameter in="path" name="window" required="true" type="string" %}
The applicable window for repair by the Cloud Store. See [Using `window` parameter](/apis/apis-overview/assets-api.md#using-window-parameter) for more details.
{% endswagger-parameter %}

{% swagger-parameter in="path" name="provider" type="string" %}
Optional parameter for the `ProviderKey` of your CSP. If included, only the specified Cloud Store will run the operation. If not included, all Cloud Stores in the ETL will run the operation.
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}
{% code overflow="wrap" %}
```json
{
    "code": 200,
    "data": "Reconciliation Repair process has begun for [<window>) for all providers"
}
```
{% endcode %}
{% endswagger-response %}
{% endswagger %}

## ETL Status API

{% swagger method="get" path="/etl/status" baseUrl="http://<kubecost-address>/model" summary="ETL Status API" %}
{% swagger-description %}
Returns a status object for the ETL. This includes sections for `allocation`, `assets`, and `cloud`.
{% endswagger-description %}

{% swagger-response status="200: OK" description="" %}

{% endswagger-response %}
{% endswagger %}
