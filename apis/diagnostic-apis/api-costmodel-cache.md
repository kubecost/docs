# Cost-model Cache API

The Kubecost cost-model container queries the k8s api-server to understand the resources which exist on the cluster. It then caches this information in memory. The following APIs are served by the cost-model container on each cluster, and provide a way to inspect the current state of the cache.

{% swagger method="get" path="/allNodes" baseUrl="http://<your-kubecost-address>/model/" summary="allNodes API" %}
{% swagger-description %}
List of all nodes in the cluster.
{% endswagger-description %}

{% swagger method="get" path="/allNamespaces" baseUrl="http://<your-kubecost-address>/model/" summary="allNamespaces API" %}
{% swagger-description %}
List of all namespaces on the cluster.
{% endswagger-description %}

{% swagger method="get" path="/allDeployments" baseUrl="http://<your-kubecost-address>/model/" summary="allDeployments API" %}
{% swagger-description %}
List of all Deployments on the cluster.
{% endswagger-description %}

{% swagger-parameter in="path" name="namespace" type="string" %}
Filter query by namespace.
{% endswagger-parameter %}

{% swagger method="get" path="/allStatefulSets" baseUrl="http://<your-kubecost-address>/model/" summary="allStatefulSets API" %}
{% swagger-description %}
List of all StatefulSets on the cluster.
{% endswagger-description %}

{% swagger-parameter in="path" name="namespace" type="string" %}
Filter query by namespace.
{% endswagger-parameter %}

{% swagger method="get" path="/allDaemonSets" baseUrl="http://<your-kubecost-address>/model/" summary="allDaemonSets API" %}
{% swagger-description %}
List of all DaemonSets on the cluster.
{% endswagger-description %}

{% swagger method="get" path="/allPods" baseUrl="http://<your-kubecost-address>/model/" summary="allPods API" %}
{% swagger-description %}
List of all Pods on the cluster.
{% endswagger-description %}

{% swagger method="get" path="/allPersistentVolumes" baseUrl="http://<your-kubecost-address>/model/" summary="allPersistentVolumes API" %}
{% swagger-description %}
List of all PersistentVolumes on the cluster.
{% endswagger-description %}

{% swagger method="get" path="/allStorageClasses" baseUrl="http://<your-kubecost-address>/model/" summary="allStorageClasses API" %}
{% swagger-description %}
List of all StorageClasses on the cluster.
{% endswagger-description %}
