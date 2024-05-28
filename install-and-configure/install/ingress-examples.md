# Ingress Examples

Enabling external access to the Kubecost UI requires exposing access to port 9090 on the `kubecost-cost-analyzer` service. There are multiple ways to do this, including Ingress or port-forwarding.

As of Kubecost 2.2, the frontend has an option for `haMode` which changes the service name that the ingress needs to target. When using the helm ingress template, the correct service is automatically set based on this flag.

{% hint style="warning" %}
Please exercise caution when exposing Kubecost via an ingress controller especially if there is no authentication in use. Consult your organization's internal security practices.
{% endhint %}

Common samples below and others can be found on our [GitHub repository](https://github.com/kubecost/poc-common-configurations/tree/main/ingress-examples).

## Helm ingress template

This is recommended unless you have specific needs that a typical ingress template do not address. The advantage to this method is that the service name is automatically configured.

An example of using the Helm ingress using cert-manager:

```yaml
ingress:
  annotations:
    cert-manager.io/cluster-issuer: letsencrypt-http
  className: nginx
  enabled: true
  hosts:
  - kubecost.your.com
  tls:
  - hosts:
    - kubecost.your.com
    # letsencrypt automatically creates the secret, just need to give it a name:
    secretName: kubecost-tls
```

## NGINX Ingress Controller examples

The following example definitions use the NGINX [Ingress Controller](https://kubernetes.io/docs/concepts/services-networking/ingress-controllers/).

### Basic auth example

{% code overflow="wrap" %}
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
{% endcode %}

Here is a [second basic auth example](https://kubernetes.github.io/ingress-nginx/examples/auth/basic/) that uses a Kubernetes Secret.

### Non-root path example

To deploy Kubecost to a non-root path use the below configuration.&#x20;

_Note: When deploying Grafana on a non-root URL, you also need to update your grafana.ini to reflect this. More info can be found in_ [_values.yaml_](https://github.com/kubecost/cost-analyzer-helm-chart/blob/cae42c28e12ecf8f1ad13ee17be8ce6633380b96/cost-analyzer/values.yaml#L335-L339)_._

{% code overflow="wrap" %}
```yaml
apiVersion: networking.k8s.io/v1
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
        pathType: ImplementationSpecific
        backend:
          service:
            name: kubecost-cost-analyzer # should be configured if another helm name or service address is used
            port:
              number: 9090
```
{% endcode %}

### ALB Example

Once an AWS Load Balancer (ALB) Controller is installed, you can use the following Ingress resource manifest pointed at the Kubecost cost-analyzer service:

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
