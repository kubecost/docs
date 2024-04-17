# Audits

{% hint style="warning" %}
The Audits dashboard cannot be used until you have enabled the Cost Events Audit API via Helm. See the [Cost Events Audit API](/apis/governance-apis/cost-events-audit-api.md#enabling-the-cost-events-audit-api) doc for instructions.
{% endhint %}

The Audit dashboard provides a log of changes made to your deployment. It's powered by the [Cost Events Audit API](/apis/governance-apis/cost-events-audit-api.md) and the [Predict API](/apis/governance-apis/spec-cost-prediction-api.md). Supported event types include creations and deletions of Deployments and StatefulSets.

![Audit dashboard](/.gitbook/assets/audit.png)

## Estimated monthly cost impact

Cost impact from additions or deletions is provided using the Predict API. Deletions should naturally result in cost savings, indicated by a negative value, with the opposite effect for additions.
