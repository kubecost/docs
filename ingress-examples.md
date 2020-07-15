Enabling external access to the Kubecost product requires exposing access to port 9090 on the `kubecost-cost-analyzer` pod.
Exposing this endpoint will handle routing to Grafana as well. 
This can be accomplished with a number of approaches, including Ingress or Service definitions.   

The following example definitions use the NGINX [Ingress Contoller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/).

## Basic auth example

```
apiVersion: v1
data:
  auth: YWRtaW46JGFwcjEkZ2tJenJxU2ckMWx3RUpFN1lFcTlzR0FNN1VtR1djMAo= # default is admin:admin -- to be replaced
kind: Secret
metadata:
  name: kubecost-auth
  namespace: kubecost
type: Opaque
---
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: kubecost-ingress
  namespace: kubecost
  labels:
    app: kubecost
  annotations:
     nginx.ingress.kubernetes.io/auth-type: basic
     nginx.ingress.kubernetes.io/auth-secret: kubecost-auth
     nginx.ingress.kubernetes.io/auth-realm: "Authentication Required - ok"
spec:
  backend:
    serviceName: kubecost-cost-analyzer
    servicePort: 9090
```

Here is a [second basic auth example](https://kubernetes.github.io/ingress-nginx/examples/auth/basic/) that uses a Kubernetes Secret. 

## Non-root path example

Note that when deploying *Grafana* on a non-root url, you also need to update your grafana.ini to reflect this. [More info](https://github.com/kubecost/cost-analyzer-helm-chart/blob/cae42c28e12ecf8f1ad13ee17be8ce6633380b96/cost-analyzer/values.yaml#L335-L339).

```
apiVersion: networking.k8s.io/v1beta1
kind: Ingress
metadata:
  name: kubecost-ingress
  annotations:
    kubernetes.io/ingress.class: nginx
    nginx.ingress.kubernetes.io/enable-cors: "true"
    # remove path prefix from requests before sending to kubecost-frontend
    nginx.ingress.kubernetes.io/rewrite-target: /$2
    # add trailing slash to requests of index
    nginx.ingress.kubernetes.io/configuration-snippet: |
      rewrite ^(/kubecost)$ $1/ permanent;
spec:
  rules:
  - host: demo.kubecost.io
    http:
      paths:
      # serve kubecost from demo.kubecost.io/kubecost/
      - path: /kubecost(/|$)(.*)
        backend:
          serviceName: kubecost-cost-analyzer # should be configured if another helm name or service address is used 
          servicePort: 9090
```
