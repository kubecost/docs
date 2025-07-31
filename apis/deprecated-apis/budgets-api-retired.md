# Budget API (Deprecated)

{% hint style="danger" %}
This version of the Budget API is deprecated and this doc should no longer be consulted. Please reference the current [Budget API](/apis/governance-apis/budget-api.md) doc for updated information.
{% endhint %}

The Budget API allows you to create, update, and delete recurring budget rules to control your Kubernetes spending. Weekly and monthly budgets can be established to set limits on cost spend.

{% swagger method="post" path="/model/budget/recurring/set" baseUrl="http://<your-kubecost-address>" summary="Set recurring budget rule or update existing rule" %}
{% swagger-description %}
Creates a recurring budget rule or updates a recurring budget rule when provided the ID of the existing rule.
{% endswagger-description %}

{% swagger-parameter in="body" name="name" type="string" required="true" %}
Name of the budget rule
{% endswagger-parameter %}

{% swagger-parameter in="body" name="filter" type="string" %}
The filter (either `namespace` or `cluster`) for the rule.
{% endswagger-parameter %}

{% swagger-parameter in="body" name="interval" type="string" required="true" %}
The interval that the budget will reset with (either `weekly` or `monthly`).
{% endswagger-parameter %}

{% swagger-parameter in="body" name="intervalDay" type="int" %}
The day the budget will reset. When `interval=weekly`, `intervalDay` is the day of the week, with `intervalDay=0` for Sunday, `intervalDay=1` for Monday, etc. When `interval=monthly`, `intervalDay` corresponds with the day of the month.
{% endswagger-parameter %}

{% swagger-parameter in="body" name="amount" type="string" %}
The budget limit value. Currency can be configured in _Settings >_ Cloud Cost Settings > Currency dropdown.
{% endswagger-parameter %}

{% swagger-parameter in="body" name="id" type="string" %}
Only should be used when updating a budget rule, ID of the budget rule being modified
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}

```json
{
    "code": 200,
    "data": [
        {
            "name": "",
            "id": "",
            "property": "",
            "values": [
                ""
            ],
            "kind": "soft",
            "interval": "weekly",
            "intervalDay": 0,
            "amount": 0
        }
}
```

{% endswagger-response %}
{% endswagger %}

{% swagger method="get" path="/model/budget/recurring/list" baseUrl="http://<your-kubecost-address>" summary="Get recurring budget rule(s)" %}
{% swagger-description %}
Lists all existing recurring budget rules
{% endswagger-description %}

{% swagger-response status="200: OK" description="" %}

```json
{
    "code": 200,
    "data": [
        {
            "name": "",
            "id": "",
            "property": "",
            "values": [
                ""
            ],
            "kind": "soft",
            "interval": "weekly",
            "intervalDay": 0,
            "amount": 0
        }
}
```

{% endswagger-response %}
{% endswagger %}

{% swagger method="delete" path="/model/budget/recurring/delete" baseUrl="https://<your-kubecost-address>" summary="Delete recurring budget rule" %}
{% swagger-description %}
Deletes a budget rule defined by `id`
{% endswagger-description %}

{% swagger-parameter in="path" name="id" type="string" %}
ID of the recurring budget rule to be deleted
{% endswagger-parameter %}

{% swagger-response status="200: OK" description="" %}

```json
{
    "code": 200,
    "data": []
}
```

{% endswagger-response %}
{% endswagger %}

## Formatting parameters when creating/updating budget rules

Creating and updating recurring budget rules uses POST requests, which will require submitting a JSON object in the body of your request instead of adding parameters directly into the path (such as when deleting a recurring budget rule). See the Examples section below for more information on formatting your requests.

## Using the `id` parameter

The `id` parameter when using the endpoint `/setRecurringBudgetRules` is considered optional, but its use will vary depending on whether you want to create or update a budget rule.&#x20;

When creating a new budget rule, `id` should not be used. An ID for the budget rule will then be randomly generated in the response. When updating an existing budget rule, `id` needs to be used to identify which budget rule you want to modify, even if you only have one existing rule.

The `id` value of your recurring budget is needed to update or delete it. If you don't have the `id` value saved, you can retrieve it using `/getRecurringBudgetRules`, which will generate all existing budgets and their respective `id` values.

## Configuring currency

The `amount` parameter will always be determined using your configured currency type. You can manually change your currency type in Kubecost by selecting _Settings_, then scrolling to Currency and selecting your desired currency from the dropdown (remember to confirm your choice by selecting _Save_ at the bottom of the page).

Kubecost does **not** convert spending costs to other currency types; it will only change the symbol displayed in the UI next to costs. For best results, configure your currency to what matches your spend.

## Examples

#### Create a soft recurring budget rule for my test cluster which resets every Wednesday, with a budget of $100.00 USD

{% tabs %}
{% tab title="Request" %}

```json
{
  "name": "example-test",
  "property": "cluster",
  "values": [
    "test"
  ],
  "kind": "soft",
  "interval": "weekly",
  "intervalDay": 3,
  "amount": 100
}
```

{% endtab %}

{% tab title="Response" %}

```json
{
    "code": 200,
    "data": [
        {
            "name": "example-test",
            "id": "e59c076c-a5c1-422b-a9d6-e39bd8037c0a",
            "property": "cluster",
            "values": [
                "test"
            ],
            "kind": "soft",
            "interval": "weekly",
            "intervalDay": 3,
            "amount": 100
        }
}
```

{% endtab %}
{% endtabs %}

#### Get all existing recurring budget rules in place

{% tabs %}
{% tab title="Request" %}

```http
http://<your-kubecost-address>/model/getRecurringBudgetRules
```

{% endtab %}

{% tab title="Response" %}

```json
{
    "code": 200,
    "data": [
        {
            "name": "example-rule-1",
            "id": "e18c936b-6f24-4a21-a4a6-8b764e62e039",
            "filter": "namespace",
            "kind": "soft",
            "interval": "weekly",
            "intervalDay": 2,
            "amount": 25
        },
        {
            "name": "example-rule-2",
            "id": "9487dc23-46a6-4477-8e81-9530fa23fdea",
            "filter": "cluster",
            "kind": "hard",
            "interval": "monthly",
            "intervalDay": 15,
            "amount": 50
        }
    ]
}
```

{% endtab %}
{% endtabs %}
