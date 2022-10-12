Installation Kubecost with Istio (Rancher)
================================

The following requirements are given:
- Rancher with default monitoring
- Use of an existing Prometheus and Grafana (Kubecost will be installed without Prometheus and Grafana)
- Istio with gateway and sidecar for deployments

> **Note**: Kubecost v1.85.0 has been released and includes changes to support cadvisor metrics without the container_name rewrite rule.

## Activation of Istio


1.	Istio is activated by editing the namespace. To do this, execute the command
	`kubectl edit namespace kubecost` and insert the label `istio-injection: enabled`
	
2.	After Istio has been activated, some adjustments must be made to the deployment with
	`kubectl -n kubecost edit deployment kubecost-cost-analyzer` to allow communication within the namespace. For example, the healtch-check is completed successfully. When editing the deployment, the two annotations must be added: 
```
annotations:
	traffic.sidecar.istio.io/excludeOutboundIPRanges: "10.43.0.1/32"
	sidecar.istio.io/rewriteAppHTTPProbers: "true"
```

## Authorization polices


An authorization policy governs access restrictions in namespaces and specifies how
resources within a namespace are allowed to access it.

### ap-ingress: communication with Istio

```
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: ap-ingress
  namespace: kubecost
spec:
  rules:
  - from:
    - source:
        principals:
        - cluster.local/ns/istio-system/sa/istio-ingressgateway-service-account
```

### ap-intern:  communication with Kubecost

```
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: ap-intern
  namespace: kubecost
spec:
  rules:
  - from:
    - source:
        principals:
        - cluster.local/ns/kubecost/sa/kubecost-cost-analyzer
```

### ap-extern: as a port share (9003) for communication from Prometheus (namespace "cattle-monitoring-system") to Kubecost (namespace "kubecost")

```
apiVersion: security.istio.io/v1beta1
kind: AuthorizationPolicy
metadata:
  name: ap-extern
  namespace: kubecost
spec:
  rules:
  - to:
    - operation:
        ports:
          - "9003"
```

## Peer Authentication


Peer authentication is used to set how traffic is tunneled to the Istio sidecar. In the example, enforcing TLS is disabled so that Prometheus can grap the metrics from Kubecost (if this action is not performed, an HTTP 503 error appears as feedback).

### pa-default.yaml

```
apiVersion: security.istio.io/v1beta1
kind: PeerAuthentication
metadata:
  name: pa-default
  namespace: kubecost
spec:
  mtls:
    mode: PERMISSIVE
```

## Destination Rule


A destination rule is used to specify how traffic should be handled after routing to a
service. In my case, TLS is disabled for connections from Kubecost to Prometheus and Grafana
(namespace "cattle-monitoring-system").

### dr-prometheus.yaml 
```
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: dr-prometheus
  namespace: kubecost
spec:
  host: rancher-monitoring-prometheus.cattle-monitoring-system.svc.cluster.local
  trafficPolicy:
    tls:
      mode: DISABLE
```

### dr-grafana.yaml 
```
apiVersion: networking.istio.io/v1alpha3
kind: DestinationRule
metadata:
  name: dr-grafana
  namespace: kubecost
spec:
  host: rancher-monitoring-grafana.cattle-monitoring-system.svc.cluster.local
  trafficPolicy:
    tls:
      mode: DISABLE
```

## Virtual Service

A virtual service is used to direct data traffic specifically to individual services
within the service mesh. The virtual service defines how the routing ist to run. A gateway
is required for a virtual service.

### vs-kubecost.yaml

```
apiVersion: networking.istio.io/v1beta1
kind: VirtualService
metadata:
  labels:
    cattle.io/creator: norman
  name: vs-kubecost
  namespace: kubecost
spec:
  gateways:
  - ${gateway}
  hosts:
  - ${host}
  http:
  - match:
    - uri:
        prefix: /kubecost
    rewrite:
      uri: /
    route:
    - destination:
        host: kubecost-cost-analyzer.kubecost.svc.cluster.local
        port:
          number: 9090
```

After creating the virtual service, Kubecost should be accessible at the URL
`http(s)://${gateway}/kubecost/`.

Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/istio-rancher.md)


<!--- {"article":"4408175613719","section":"4402815636375","permissiongroup":"1500001277122"} --->
