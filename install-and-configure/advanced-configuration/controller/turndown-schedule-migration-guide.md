# TurndownSchedule Migration Guide

In v1.94 of Kubecost, the `turndownschedules.kubecost.k8s.io/v1alpha1` Custom Resource Definition (CRD) was [moved](https://github.com/kubecost/cost-analyzer-helm-chart/pull/1444) to `turndownschedules.kubecost.com/v1alpha1` to adhere to [Kubernetes policy for CRD domain namespacing](https://github.com/kubernetes/enhancements/pull/1111). This is a breaking change for users of Cluster Controller's turndown functionality. Please follow this guide for a successful migration of your turndown schedule resources.

{% hint style="danger" %}
As part of this change, the CRD was updated to use `apiextensions.k8s.io/v1` because `v1beta1` was removed in K8s v1.22. If using Kubecost v1.94+, Cluster Controller's turndown functionality will not work on K8s versions before the introduction of `apiextensions.k8s.io/v1`.
{% endhint %}

## Scenario 1: You have deployed Cluster Controller but don't use turndown

In this situation, you've deployed Kubecost's Cluster Controller at some point using `--set clusterController.enabled=true`, but you don't use the turndown functionality.

That means that this command should return one line:

```bash
kubectl get crd turndownschedules.kubecost.k8s.io
```

And this command should return no resources:

```bash
kubectl get turndownschedules.kubecost.k8s.io
```

This situation is easy! You can do nothing, and turndown should continue to behave correctly because `kubectl get turndownschedule` and related commands will correctly default to the new `turndownschedules.kubecost.com/v1alpha1` CRD after you upgrade to Kubecost v1.94 or higher.

If you would like to clean up the old CRD, simply run `kubectl delete crd turndownschedules.kubecost.k8s.io` after upgrading Kubecost to v1.94 or higher.

## Scenario 2: You currently use turndown

In this situation, you've deployed Kubecost's Cluster Controller at some point using `--set clusterController.enabled=true` and you have at least one `turndownschedule.kubecost.k8s.io` resource currently present in your cluster.

That means that this command should return one line:

```bash
kubectl get crd turndownschedules.kubecost.k8s.io
```

And this command should return at least one resource:

```bash
kubectl get turndownschedules.kubecost.k8s.io
```

We have a few steps to perform if you want Cluster Controller's turndown functionality to continue to behave according to your already-defined turndown schedules.

1. Upgrade Kubecost to v1.94 or higher with `--set clusterController.enabled=true`
2. Make sure the new CRD has been defined after your Kubecost upgrade

    This command should return a line:

    ```bash
    kubectl get crd turndownschedules.kubecost.com
    ```

3. Copy your existing `turndownschedules.kubecost.k8s.io` resources into the new CRD

    ```bash
    kubectl get turndownschedules.kubecost.k8s.io -o yaml \
      | sed 's|kubecost.k8s.io|kubecost.com|' \
      | kubectl apply -f -
    ```

4. (optional) Delete the old `turndownschedules.kubecost.k8s.io` CRD

    Because the CRDs have a finalizer on them, we have to follow [this workaround](https://github.com/kubernetes/kubernetes/issues/60538#issuecomment-369099998) to remove the finalizer from our old resources. This lets us clean up without locking up.

    ```bash
    kubectl patch \
      crd/turndownschedules.kubecost.k8s.io \
      -p '{"metadata":{"finalizers":[]}}' \
      --type=merge
    ```

    > **Note**: The following command may be unnecessary because Helm should automatically remove the `turndownschedules.kubecost.k8s.io` resource during the upgrade. The removal will remain in a pending state until the finalizer patch above is implemented.

    ```bash
    kubectl delete crd turndownschedules.kubecost.k8s.io
    ```
