# Audit Dashboard

The Audit dashboard provides a log of changes made to your deployment. It's powered by the Audit Events Cost API and the Predict API. Supported event types include additions and deletions.

![Audit dashboard](https://github.com/kubecost/docs/blob/e4232c2fa7d77f7141942f1afa1766d33e7efd59/images/audit.png)

## Estimated monthly cost impact

Cost impact from additions or deletions is provided using the Predict API. Deletions should naturally result in cost savings, indicated by a negative value, with the opposite effect for additions.

