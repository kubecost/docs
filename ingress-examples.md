Ingress Examples
================

Enabling external access to the Kubecost product requires exposing access to port 9090 on the `kubecost-cost-analyzer` Pod.
Exposing this endpoint will handle routing to Grafana as well.
This can be accomplished with a number of approaches, including Ingress or Service definitions.

> **Note:** you should be cautious about exposing endpoints and recommend consulting your orgnanization's internal recommendations. 

Common samples below and others can be found on our [GitHub repository](https://github.com/kubecost/poc-common-configurations/tree/main/ingress-examples).

The following example definitions use the NGINX [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/).

## Basic auth example

```yaml
# https://kubernetes.github.io/ingress-nginx/examples/auth/basic/
apiVersion: v1
data:
  auth: Zm9vOiRhcHIxJE9GRzNYeWJwJGNrTDBGSERBa29YWUlsSDkuY3lzVDAK
kind: Secret
metadata:
  name: basic-auth
  namespace: default
type: Opaque
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kubecost-ingress-tls
  annotations:
    # type of authentication
    nginx.ingress.kubernetes.io/auth-type: basic
    # name of the secret that contains the user/password definitions
    nginx.ingress.kubernetes.io/auth-secret: basic-auth
    # message to display with an appropriate context why the authentication is required
    nginx.ingress.kubernetes.io/auth-realm: 'Authentication Required - kubecost'
spec:
  ingressClassName: nginx
  rules:
  - host: kubecost.your.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: kubecost-cost-analyzer
            port:
              number: 9090
  tls:
  - hosts:
      - kubecost.your.com
    secretName: kubecost-tls
    # Use any cert tool/cert-manager or create manually: kubectl create secret tls kubecost-tls --cert /etc/letsencrypt/live/kubecost.your.com/fullchain.pem --key /etc/letsencrypt/live/kubecost.your.com/privkey.pem
```

Here is a [second basic auth example](https://kubernetes.github.io/ingress-nginx/examples/auth/basic/) that uses a Kubernetes Secret.

## Non-root path example

Note that when deploying Grafana on a non-root URL, you also need to update your grafana.ini to reflect this. [More info](https://github.com/kubecost/cost-analyzer-helm-chart/blob/cae42c28e12ecf8f1ad13ee17be8ce6633380b96/cost-analyzer/values.yaml#L335-L339).

```yaml
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


## ALB Example

Once an AWS Load Balancer Controller is installed, you can use the following Ingress resource manifest pointed at the Kubecost cost-analyzer service:


```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: kubecost-alb-ingress
  annotations:
    kubernetes.io/ingress.class: alb
    alb.ingress.kubernetes.io/target-type: ip
    alb.ingress.kubernetes.io/scheme: internet-facing
spec:
  rules:
    - http:
        paths:
        - path: /
          pathType: Prefix
          backend:
            service:
              name: kubecost-cost-analyzer
              port:
                number: 9090
```

Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/ingress-examples.md)

<!--- {"article":"4407601820055","section":"4402815636375","permissiongroup":"1500001277122"} --->
