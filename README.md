# Welcome to the Docs!

## Welcome!

**Kubecost helps you monitor and manage cost and capacity in Kubernetes environments.** We integrate with your infrastructure to help your team track, manage, and reduce spend.

Below are frequently visited Kubecost documentation pages for both the [Commercial Kubecost product](http://kubecost.com) and [OpenCost](https://www.opencost.io/).

On this site, you’ll find everything you need to set up Kubecost for your team.

{% tabs %}
{% tab title="Kubecost Free" %}
Kubecost provides real-time cost visibility and insights for teams using Kubernetes, helping you continuously reduce your cloud costs.

*   **Cost allocation**

    Flexible, customizable cost breakdown and resource allocation for accurate showbacks, [chargebacks](https://blog.kubecost.com/blog/kubernetes-chargeback), and ongoing monitoring
*   **Unified cost monitoring**

    See all of your Kubernetes and out-of-cluster spend in one place, with full cloud service billing integration
*   **Optimization Insights**

    Get customized recommendations based on your own environment and behavior patterns
*   **Alerts and governance**

    Achieve peak application performance and improve reliability with customizable alerts, configurable Availability Tiers, and real-time updates.
*   **Purpose-built for teams running Kubernetes**

    Running containers on Kubernetes requires a new approach for visualizing and optimizing spend. Kubecost is designed from the ground up for Kubernetes and the Cloud Native ecosystem.
*   **Own & control all of your own data**

    Kubecost is fully deployed in your infrastructure—we don’t require you to egress any data to a remote service. It’s deeply important to us that users are able to retain and control access to their own private information, e.g. sensitive cloud spend data.
*   **Built on open source**

    Kubecost began as an open source project with a goal of giving small engineering teams access to great cost visibility. As a result, our solution is tightly integrated with the open source cloud native ecosystem, e.g. Kubernetes, Prometheus, and Grafana.
{% endtab %}

{% tab title="Kubecost Enterprise" %}
For larger teams and companies with more complex infrastructure, you need the right features in place for efficiency, administration, and security. Kubecost Enterprise offers even more features and control so that any team can use our products, according to your entire organization’s standards.

*   **Unified visibility across all Kubernetes clusters**

    View aggregate spend allocation across all environments by cluster, namespace, label, team, service, etc. As an example, this functionality allows you to see the cost of a namespace or set of labels across all of your clusters. An unlimited number of clusters is supported.
*   **Long-term metric retention**

    Retain data for years with various durable storage options. Provides record keeping on spend, allocation, and efficiency metrics with simple backup & restore functionality.
*   **Access control with SSO/SAML**

    Finely manage read and/or admin access by individual users or user groups. [Learn more](user-management.md).
*   **High availability mode**

    Use multiple Kubecost replica pods with a Leader/Follower implementation to ensure one leader always exists across all replicas to run high availability mode. [Learn more](high-availability.md).
*   **Advanced custom pricing**

    Advanced custom pricing pipelines give teams the ability to set custom per-asset pricing for resources. This is typically used for on-prem and air-gapped environments, but can also be applied to teams that want to allocate internal costs differently than cloud provider defaults.
*   **Advanced integrations**

    Connect internal alerting, monitoring, and BI solutions to Kubecost metrics and reporting.
*   **Enterprise Support**

    Dedicated SRE support via private Slack channel and video calls. Expert technical support and guidance based on your specific goals.
{% endtab %}
{% endtabs %}

## Quick installation

Check out our [Installation guide](https://docs.kubecost.com/install-and-configure/install) to review your install options and get started on your Kubecost journey. Installation and onboarding only take a few minutes.

## Getting started

Once Kubecost has been successfully installed, check out our [First Time User Guide](https://docs.kubecost.com/install-and-configure/install/first-time-user-guide) which will get you started with connecting to your cluster's cloud service provider, review your data, and setting up multi-cluster environments.

If your Kubecost installation was not successful, go to our [Troubleshoot Install](https://docs.kubecost.com/troubleshooting/troubleshoot-install) doc which will work you through some of the most common installation-related issues.

Additionally, check out our [blog ](https://blog.kubecost.com/blog/cost-monitoring/)to learn more about best practices with Kubecost's cost monitoring.

## Staying in the loop

You can stay up to date with Kubecost by following releases on [GitHub](https://github.com/kubecost/cost-analyzer-helm-chart/releases).

Contact us via email ([support@kubecost.com](mailto:support@kubecost.com)) or join us on [Slack](https://kubecost.com/join-slack) if you have questions!
