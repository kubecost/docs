Guide: 1-click request sizing
=============================

> **Note**: This feature is in a pre-release (alpha/beta) state. It has limitations. Please read the documentation carefully.

1-click request sizing is a feature that will instantly update [container
resource
requests](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits)
in your cluster based on Kubecost's sizing
[recommendations](https://github.com/kubecost/docs/blob/main/api-request-right-sizing.md). 

## Setup

See the high-level [automatic request right-sizing guide](https://github.com/kubecost/docs/blob/main/auto-request-sizing.md).

## Using 1-click request sizing

1. Visit the request sizing page of your Kubecost installation
      ```bash
      kubectl port-forward \
          -n kubecost \
          service/kubecost-cost-analyzer \
          9090
      ```

      Then visit [http://localhost:9090/request-sizing.html](http://localhost:9090/request-sizing.html)

2. Modify the request sizing settings, like profile, window, and filters, until
   you have a set of recommendations you are ready to apply to your cluster.

3. Click the "Automatically implement recommendations" button.

      ![](https://raw.githubusercontent.com/kubecost/docs/main/images/one-click-request-sizing/configured-with-button.png)

4. Confirm!

      ![](https://raw.githubusercontent.com/kubecost/docs/main/images/one-click-request-sizing/confirm-dialog.png)

## Technical details

If you want to learn more about the APIs that power 1-click request sizing,
including their limitations, see the corresponding [API
documentation](https://github.com/kubecost/docs/blob/main/api-request-recommendation-apply.md).


<!--- {"article":"5843816284823","section":"4402815656599","permissiongroup":"1500001277122"} --->
