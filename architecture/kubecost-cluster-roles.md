# Kubecost Cluster Roles

Kubecost requires read only RBAC permissions on most cluster resources in order to build a granular cost-model for all resources. `Role` can be set to make changes in your namespace, while `ClusterRole` is required to make changes across the cluster (and therefore in all namespaces).

`cluster-admin` is required to install Kubecost. However, this role is not required to modify the deployment afterwards.

Kubecost requires `get`, `list`, and `watch` permissions over many common Kubernetes pod and pod controller resources such as pods, deployments, StatefulSets as well as other resources which factor into to cost analysis such as namespaces, nodes, events, etc.

The source of these rules can be found in Kubecost's ClusterRole template:

```yaml
{{- if not .Values.kubecostModel.etlReadOnlyMode -}}
{{- if and .Values.reporting .Values.reporting.logCollection -}}
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  namespace: {{ .Release.Namespace }}
  name: {{ template "cost-analyzer.serviceAccountName" . }}
  labels:
    {{ include "cost-analyzer.commonLabels" . | nindent 4 }}
rules:
- apiGroups: 
    - ''
  resources:
    - "pods/log"
  verbs:
    - get
    - list
    - watch
---
{{- end }}
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: {{ template "cost-analyzer.serviceAccountName" . }}
  labels:
    {{ include "cost-analyzer.commonLabels" . | nindent 4 }}
rules:
  - apiGroups:
      - ''
    resources:
      - configmaps
      - nodes
      - pods
      - events
      - services
      - resourcequotas
      - replicationcontrollers
      - limitranges
      - persistentvolumeclaims
      - persistentvolumes
      - namespaces
      - endpoints
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - apps
    resources:
      - statefulsets
      - deployments
      - daemonsets
      - replicasets
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - batch
    resources:
      - cronjobs
      - jobs
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - autoscaling
    resources:
      - horizontalpodautoscalers
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - policy
    resources:
      - poddisruptionbudgets
    verbs:
      - get
      - list
      - watch
  - apiGroups: 
      - storage.k8s.io
    resources: 
      - storageclasses
    verbs:
      - get
      - list
      - watch
  - apiGroups:
      - events.k8s.io
    resources:
      - events
    verbs:
      - get
      - list
      - watch
{{- end }}
```
