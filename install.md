# Installation

To get started with Kubecost and OpenCost, **the recommended path is to** [**install Kubecost Community Version**](https://kubecost.com/install). This installation method is available for free and leverages the Kubecost Helm Chart. It provides access to all OpenCost and Kubecost community functionality and can scale to large clusters. This will also provide a token for trialing and retaining data across different Kubecost product tiers.

## Kubecost Features

{% tabs %}
{% tab title="Standard Features" %}
Kubecost provides real-time cost visibility and insights for teams using Kubernetes, helping you continuously reduce your cloud costs.

*   **Cost Allocation**

    Flexible, customizable cost breakdown and resource allocation for accurate showbacks, [chargebacks](https://blog.kubecost.com/blog/kubernetes-chargeback), and ongoing monitoring
*   **Unified cost monitoring**

    See all of your Kubernetes and out-of-cluster spend in one place, with full cloud service billing integration
*   **Optimization Insights**

    Get customized recommendations based on your own environment and behavior patterns
*   **Alerts & Governance**

    Achieve peak application performance and improve reliability with customizable alerts, configurable Availability Tiers, and real-time updates.
*   **Purpose-built for teams running Kubernetes**

    Running containers on Kubernetes requires a new approach for visualizing and optimizing spend. Kubecost is designed from the ground up for Kubernetes and the Cloud Native ecosystem.
*   **Own & control all of your own data**

    Kubecost is fully deployed in your infrastructure—we don’t require you to egress any data to a remote service. It’s deeply important to us that users are able to retain and control access to their own private information, e.g. sensitive cloud spend data.
*   **Built on open source**

    Kubecost began as an open source project with a goal of giving small engineering teams access to great cost visibility. As a result, our solution is tightly integrated with the open source cloud native ecosystem, e.g. Kubernetes, Prometheus, and Grafana.
{% endtab %}

{% tab title="Business Features" %}
For medium-sized teams and companies with more complex infrastructure you need the right features in place for efficiency, administration, and security. Kubecost Business offers even more features and control so that any team can use our products, according to your entire organization’s standards.

*   **Multi-cluster visibility**

    View all Kubernetes clusters by easily toggling between each individual cluster. Supports installation of Kubecost across an unlimited number of individual clusters.
*   **Long-term metric retention & saved reports**

    Retain spend, allocation, and efficiency data for up to 30 days. Provides custom reports saving for easily sharing across teams.
*   **Team alerts & updates**

    Kubecost alerts allow teams to receive updates on real-time Kubernetes spend. [Learn more](/alerts.md)
*   **Business support**

    Direct engineering and product support via Slack channel, video, and phone.
{% endtab %}

{% tab title="Enterprise Features" %}
For larger teams and companies with more complex infrastructure, you need the right features in place for efficiency, administration, and security. Kubecost Enterprise offers even more features and control so that any team can use our products, according to your entire organization’s standards.

*   **Unified visibility across all Kubernetes clusters**

    View aggregate spend allocation across all environments by cluster, namespace, label, team, service, etc. As an example, this functionality allows you to see the cost of a namespace or set of labels across all of your clusters. An unlimited number of clusters is supported.
*   **Long-term metric retention**

    Retain data for years with various durable storage options. Provides record keeping on spend, allocation, and efficiency metrics with simple backup & restore functionality.
*   **Access control with SSO/SAML**

    Finely manage read and/or admin access by individual users or user groups. [Learn more](/user-management.md).
*   **High availability mode**

    Use multiple Kubecost replica pods with a Leader/Follower implementation to ensure one leader always exists across all replicas to run high availability mode. [Learn more](/high-availability.md).
*   **Advanced custom pricing**

    Advanced custom pricing pipelines give teams the ability to set custom per-asset pricing for resources. This is typically used for on-prem and air-gapped environments, but can also be applied to teams that want to allocate internal costs differently than cloud provider defaults.
*   **Advanced integrations**

    Connect internal alerting, monitoring, and BI solutions to Kubecost metrics and reporting.
*   **Enterprise Support**

    Dedicated SRE support via private Slack channel and video calls. Expert technical support and guidance based on your specific goals.
{% endtab %}
{% endtabs %}

## Alternative installation methods

* You can also install directly with the [Kubecost Helm Chart](https://github.com/kubecost/cost-analyzer-helm-chart/) with Helm v3.1+ using the following commands. This provides the same functionality as the step above but doesn't generate a product token for managing tiers or upgrade trials.

```bash
helm upgrade --install kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost --create-namespace
```

* You can run [Helm Template](https://helm.sh/docs/helm/helm_template/) against the [Kubecost Helm Chart](https://github.com/kubecost/cost-analyzer-helm-chart/) to generate local YAML output. This requires extra effort when compared to directly installing the Helm Chart but is more flexible than deploying a flat manifest.

```bash
helm template kubecost \
  --repo https://kubecost.github.io/cost-analyzer/ cost-analyzer \
  --namespace kubecost --create-namespace \
  -f your-custom-values.yaml
```

* You can install via flat manifest. This install path is not because it has limited flexibility for managing your deployment and future upgrades.

```bash
kubectl apply -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/develop/kubecost.yaml
```

* Lastly, you can deploy the open source OpenCost project directly as a Pod. This install path provides a subset of free functionality and is available [here](https://www.opencost.io/docs/install). Specifically, this install path deploys the underlying cost allocation model without the same UI or access to enterprise functionality: cloud provider billing integration, RBAC/SAML support and scale improvements in Kubecost.
