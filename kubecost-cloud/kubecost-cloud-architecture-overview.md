# Kubecost Cloud Architecture Overview

Kubecost Cloud uses an agent to gather metrics and send them to our SaaS platform. The agent requires an Agent package and a daemonSet:

### Kubecost Agent package

* Cost-model: Provides cost allocation calculations and metrics, reads from and scraped by Prometheus server.
* Prometheus server: Short-term time-series data store (14 days or less)
* ConfigMap-Reload: Updates Prometheus when changes are made.&#x20;

### Network costs daemonSet

* Used to allocate costs to the workload responsible for egress costs
* Enabled on install (to learn how to uninstall the daemonSet, see below)

## Architecture overview

![Kubecost Cloud architecture diagram](/images/cloudarchitecture.png)

## Disabling the network costs daemonSet

The network costs daemonSet will be installed to your Kubecost Cloud by default, however you can manually disable it by adjusting the Helm value, shown [here](https://github.com/kubecost/cost-analyzer-helm-chart/blob/fed60664f67ed5ef7b9e5947e7c28a9bde366cde/cost-analyzer/values.yaml#L682), or running this Helm upgrade command:

{% hint style="info" %}
Remember to provide your correct agent key, cluster name, and reporting server in the below example code block.
{% endhint %}

```sh
helm upgrade kubecost cost-analyzer \
--repo https://kubecost.github.io/cost-analyzer/ \
--namespace kubecost-cloud \
--set cloudAgentKey="AGENTKEY" \
--set cloudAgentClusterId="CLUSTER_NAME" \
--set cloudReportingServer="REPORTING_SERVER" \
--set networkCosts.enabled=false \
-f values-cloud-agent.yaml
```
