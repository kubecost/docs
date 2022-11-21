Enabling Annotation Emission
============================

To enable annotation emissions for Kubecost, two flags must be set to true: one for pod annotations and one for namespace annotation. To accomplish this, there are two primary methods: through Helm or updating the values.yaml file. These values are defaulted to false so will need to be set to true for annotations to be emitted.

On a Helm install or upgrade command, include the flags:

```
--set kubecostMetrics.emitPodAnnotations=true
```

and

```
--set kubecostMetrics.emitNamespaceAnnotations=true
```

> **Note**: These flags can be set independently-- setting one of these to true and the other to false will omit one and not the other.

For example:

```
helm upgrade kubecost kubecost/cost-analyzer --namespace kubecost --set kubecostMetrics.emitNamespaceAnnotations=true --set kubecostMetrics.emitPodAnnotations=true
```

In the [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/values.yaml) file set the following values:

```
EMIT_POD_ANNOTATIONS_METRIC="true"
EMIT_NAMESPACE_ANNOTATIONS_METRIC="true"
```

<!--- {"article":"4407595918231","section":"4402815656599","permissiongroup":"1500001277122"} --->
