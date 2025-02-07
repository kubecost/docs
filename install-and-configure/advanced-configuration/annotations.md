# Enabling Annotation Emission

If interested in filtering or aggregating by [Kubernetes Annotations](https://kubernetes.io/docs/concepts/overview/working-with-objects/annotations/) when using the [Allocation API](/apis/monitoring-apis/api-allocation.md), you will need to enable annotation emission on each cluster you want annotations emmitted from. This will configure your Kubecost installation to generate the `kube_pod_annotations` and `kube_namespace_annotations` metrics as listed in our [Kubecost Metrics](/architecture/user-metrics.md) doc.

You can enable it in your _values.yaml_:

```yaml
kubecostMetrics:
  emitPodAnnotations: true
  emitNamespaceAnnotations: true
```

You can also enable it via your `helm install` or `helm upgrade` command:

```bash
helm upgrade -i kubecost kubecost/cost-analyzer \
  --namespace kubecost \
  --set kubecostMetrics.emitNamespaceAnnotations=true \
  --set kubecostMetrics.emitPodAnnotations=true
```

{% hint style="info" %}
These flags can be set independently. Setting one of these to true and the other to false will omit one and not the other.
{% endhint %}
