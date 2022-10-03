Guide: 1-click request sizing
=============================

> **Note**: This feature is in a pre-release (alpha/beta) state. It has limitations. Please read the documentation carefully.

1-click request sizing is a feature that will instantly update [container
resource
requests](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/#requests-and-limits)
in your cluster based on Kubecost's sizing
[recommendations](https://github.com/kubecost/docs/blob/main/api-request-right-sizing.md). This allows you to instantly
optimize resource allocation across your entire cluster, without fiddling with
excessive YAML or arcane `kubectl` commands. You can easily eliminate resource
over-allocation in your cluster, which paves the way for vast savings via
cluster right-sizing and other optimizations.

## Setup

Install Kubecost with Cluster Controller enabled, which is the only Kubecost
component with write permission to your cluster.

Make sure the Kubecost helm repo is set up! See [kubecost.com/install](https://www.kubecost.com/install#show-instructions)

This command will install Kubecost if you haven't already. You can use "--set clusterController.enabled=true" to get Cluster Controller running if you already have Kubecost installed.

```bash
helm upgrade \
    -i \
    --create-namespace kubecost \
    kubecost/cost-analyzer \
    --set kubecostToken="aWljaGFlbEBrdQQY29zdljb203yadf98" \
    --set clusterController.enabled=true
```

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
