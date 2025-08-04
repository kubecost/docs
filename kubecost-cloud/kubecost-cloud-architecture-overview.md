# Kubecost Cloud Architecture Overview

Kubecost Cloud uses an agent to gather metrics and send them to our SaaS platform. The agent requires an Agent package and a daemonSet:

### Kubecost Agent package

* Cost-model: Provides cost allocation calculations and metrics, reads from and scraped by Prometheus server.
* Prometheus server: Short-term time-series data store (14 days or less)
* ConfigMap-Reload: Updates Prometheus when changes are made.&#x20;

### Network costs DaemonSet

* Used to allocate costs to the workload responsible for egress costs
* Enabled on install (to learn how to uninstall the DaemonSet, see below)

## Architecture overview

![Kubecost Cloud architecture diagram](/images/cloudarchitecture.png)

## Disabling the network costs DaemonSet

The network costs DaemonSet will be installed to your Kubecost Cloud by default, however you can manually disable it by running this Helm upgrade command:

{% hint style="info" %}
Remember to provide your correct agent key and cluster ID in the below example code block.
{% endhint %}

```bash
helm upgrade --install kubecost-cloud \
  --repo https://kubecost.github.io/kubecost-cloud-agent/ kubecost-cloud-agent \
  --namespace kubecost-cloud --create-namespace \
  -f https://raw.githubusercontent.com/kubecost/kubecost-cloud-agent/main/values-cloud-agent.yaml \
  --set imageVersion="lunar-sandwich.v0.1.2" \
  --set cloudAgentKey="AGENTKEY" \
  --set cloudAgentClusterId="cluster-1" \
  --set cloudReportingServer="collector.app.kubecost.com:31357" \
  --set networkCosts.enabled=false
```
