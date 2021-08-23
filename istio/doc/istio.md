+----------------------------------+
| Installation Kubecost with Istio |
+----------------------------------+

The following requirements are given:
	- Rancher with default monitoring
	- Use of an existing Prometheus and Grafana
	  (Kubecost will be installed without Prometheus and Grafana)
	- Istio with gateway and sidecar for deployments

#
# 1. Prometheus-Rules for Kubecost
#

I have modified the rules for Prometheus, so that they also work with Kubecost
and Rancher without a relabel (cavdisor metrcis). So far, all metrics can be
calculated in a non-production environment.

IMPORTANT
-->	Kubecost v1.58.0 has been released and includes changes to support cadvisor metrics
-->	without the container_name rewrite rule.

#
# 2. Activation of Istio
#

a.	Istio is activated by editing the namespace. To do this, execute the command
	"kubectl edit namespace kubecost" and insert the label "istio-injection: enbled".
	
b.	After Istio has been activated, some adjustments must be made to the deployment with
	"kubectl -n kubecost edit deployment kubecost-cost-analyzer" to allow communication
	within the namespace, for example, the healtch-check is completed successfully. When
	editing the deployment, the two annotations must be added to
	".spec.template.metadata.annotations":
	-	traffic.sidecar.istio.io/excludeOutboundIPRanges: "10.43.0.1/32"
	-	sidecar.istio.io/rewriteAppHTTPProbers: "true"

#
# 3. Authorization Policy
#

An authorization-policy governs access restrictions in namespaces and specifies how
resources within a namespace are allowed to access it.

a.	ap-ingress: for communication with Istio
b.	ap-intern: for communication with Kubecost
c.	ap-extern: as a port share (9003) for communication from Prometheus
	(namespace "cattle-monitoring-system") to Kubecost (namespace "kubecost")

#
# 4. Peer-Authentication
#

Peer authentication is used to set how traffic is tunneled to the Istio sidecar. In my
case, I disabled TLS is enforced so that Prometheus can grap the metrics from Kubcost
(if this is not done, an HTTP 503 error appears as feedback).

pa-default

#
# 5. Destination Rule
#

A destination rule is used to specify how traffic should be handled after routing to a
service. In my case, TLS is disabled for connections from Kubecost to Prometheus and Grafana
(namespace "cattle-monitoring-system").

dr-prometheus
dr-grafana

#
# 6. Virtual Service
#

A virtual service is used to direct data traffic specifically to individual services
within the service mesh. The virtual service defines how the routing ist to run. A gateway
is required for a virtual service.

vs-kubecost

After creating the virtual service, Kubcost should be accessible at the Url
http(s)://${gateway}/kubecost/.
