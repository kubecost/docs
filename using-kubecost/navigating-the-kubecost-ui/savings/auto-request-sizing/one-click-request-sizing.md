# 1-click Request Right-Sizing

{% hint style="warning" %}
This feature is in beta. Please read the documentation carefully.
{% endhint %}

1-click request right-sizing (RRS) is a feature that will instantly update [container resource requests](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits) in your cluster based on Kubecost's sizing [recommendations](/apis/apis-overview/api-request-right-sizing-v2.md).

If you want to learn more about the APIs that power 1-click RRS, including their limitations, see the corresponding [API documentation](/apis/apis-overview/api-request-recommendation-apply.md).

## Setup

See the high-level [container request right-sizing guide](auto-request-sizing.md).

## Using 1-click RRS

1.  Select _Savings_ in the left navigation, then select _Right-size your container requests_. The Request right-sizing recommendations page opens.

    ![Request right-sizing recommendations Beta page](../../../../images/rightsizing.png)
2.  Select _Customize_ to modify the request sizing settings, like profile, window, and filters, until you have a set of recommendations you are ready to apply to your cluster.

    ![Customize Request Sizing Recommendations](<../../../../images/rightsizingcustomize (1) (1) (1) (1) (1) (1) (1) (1) (1) (1) (1) (1).png>)
3. Select _Automatically Implement Recommendations_. Select _Yes, apply the recommendation_ to confirm.
