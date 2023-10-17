# Kubecost Cluster Roles

Kubecost requires read only RBAC permissions on most cluster resources in order to build a granular cost-model for all resources. `Role` can be set to make changes in your namespace, while `ClusterRole` is required to make changes across the cluster (and therefore in all namespaces).

`cluster-admin` is required to install Kubecost. However, this role is not required to modify the deployment afterwards.

Below are the rules of ClusterRoles associated with Kubecost's cost-analyzer. The source of these rules comes from [Kubecost's cluster role template](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/templates/cost-analyzer-cluster-role-template.yaml).

{% code overflow="wrap" %}
```yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{ template "cost-analyzer.serviceAccountName" . }}
  labels:
    {{ include "cost-analyzer.commonLabels" . | nindent 4 }}
rules:
  - apiGroups: [""]
    resources: [“configmaps”, “deployments”, “nodes”, “pods”, “events”, “services”, “resourcequotas”, “replicationcontrollers”, “limitranges”, “persistentvolumeclaims”, “persistentvolumes”, “namespaces”, “endpoints”]
    verbs: [“get”, “list”, “watch”]
  - apiGroups: [extensions]
    resources: ["daemonsets", "deployments", "replicasets"]
    verbs: [“get”, “list”, “watch”]
{{- $isLeaderFollowerEnabled := include "cost-analyzer.leaderFollowerEnabled" . }}
{{- if $isLeaderFollowerEnabled }}
  - apiGroups: ["coordination.k8s.io"]
    resources: ["leases"]
    verbs: ['*']
{{- end }}
  - apiGroups: ["apps"]
    resources: ["statefulsets", "deployments", "daemonsets", "replicasets"]
    verbs: [“list”, “watch”]
  - apiGroups: ["batch"]
    resources: "cronjobs", "jobs"
    verbs: [“get”, “list”, “watch”]
  - apiGroups: ["autoscaling"]
    resources: ["horizontalpodautoscalers"]
    verbs: [“get”, “list”, “watch”]
  - apiGroups: ["policy"]
    resources: ["poddisruptionbudgets"]
    verbs: [“get”, “list”, “watch”]
  - apiGroups: ["storage.k8s.io"]
    resources: ["storageclasses"]
    verbs: [“get”, “list”, “watch”]
  - apiGroups: ["events.k8s.io"]
    resources: ["events"]
    verbs: [“get”, “list”, “watch”]
```yaml
{% endcode %}
