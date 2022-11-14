# Kubecost HTTP Response Code Troubleshooting

If you have experienced an HTTP response code while using Kubecost, consult this doc for a possible fix.

You will likely encounter these response codes in the browser, when performing REST requests through a client like cURL, or when viewing the logs `kubectl logs deploy/kubecost-cost-analyzer -c cost-analyzer-frontend -n kubecost`.

## HTTP 403 Forbidden

This is most likely due to a user authenticating to Kubecost or performing an action in Kubecost that they don't have permissions to do (for example, saving a report when the user has read-only access). It can be caused by mesh networking, firewalls, load balancers, or some other service 
in the network path.

* Review the Helm values used to determine if SAML, OIDC, and RBAC are being used which could lead to the 403 error.
* Verify if the 403 error occurs when port forwarding to the cost-analyzer frontend. This will allow you to determine if the error is being introduced by an external service.

## HTTP 499 Client closed connection

This is usually the NGINX gateway (inside the `kubecost-cost-analyzer` pod) reporting that the client has closed the connection.

* All client requests may need increased timeouts.
* If client requests are only timing out on Kubecost and nothing else, Kubecost may need more CPU/memory so that it can process the API requests faster.
* A router/proxy between the client and the Kubecost service may be timing out the request too quickly.

### Test command

> **Note**: The following test command can be used for troubleshooting both 499 and 504 errors.

* If running the following command fails or hangs when the pod is ready, the error is likely due to intermittent DNS:
  *  `kubectl exec -i -t -n kubecost kubecost-cost-analyzer-55c45d9d95-8m2sq -c cost-analyzer-frontend -- curl kubecost-cost-analyzer.kubecost:9090/model/clusterInfo`

## HTTP 504 Gateway timeout

Almost always because the `cost-model` container in the `kubecost-cost-analyzer` pod is down. If the pods are consistently restarting, this could be due to OOM (Out of Memory) errors. As noted in our [AWS Cloud Integration](https://guide.kubecost.com/hc/en-us/articles/4407595928087-AWS-Cloud-Integration#summary-and-pricing) doc:

> Kubecost’s `cost-model` requires roughly 2 CPU and 10 GB of RAM per 50,000 pods monitored. The backing Prometheus database requires roughly 2 CPU and 25 GB per million metrics ingested per minute. You can pick the EC2 instances necessary to run Kubecost accordingly.
> Kubecost can write its cache to disk. Roughly 32 GB per 100,000 pods monitored is sufficient. 

* Ensure you have allowed enough memory requests and limits.
