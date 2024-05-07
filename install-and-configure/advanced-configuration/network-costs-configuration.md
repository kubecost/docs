# Network Cost Configuration

## Overview

The network costs DaemonSet is an optional utility that gives Kubecost more detail to attribute costs to the correct pods.

When `networkCost` is enabled, Kubecost gathers pod-level network traffic metrics to allocate network transfer costs to the pod responsible for the traffic.

See this doc for more detail on [network cost allocation methodology](/using-kubecost/navigating-the-kubecost-ui/cost-allocation/network-allocation.md).

The network costs metrics are collected using a DaemonSet (one pod per node) that uses source and destination detail to determine egress and ingress data transfers by pod and are classified as internet, cross-region and cross-zone.

## Usage

With the network costs DaemonSet enabled, the Network column on the Allocations page will reflect the portion of network transfer costs based on the chart-level aggregation.

![Allocation dashboard Network column](/images/allocation-network-costs.png)

For an in-depth cost breakdown of your network costs, you can scroll down on the Overview page to your Network Costs Breakdown, where you can select individual namespaces and view cloud service traffic destinations.

![Network Costs Breakdown](/images/networkcostbreakdown.png)

Selecting a namespace or adding `/network` to your Kubecost address will open the 'Allocation / Network costs' page, lists key metrics such as egress and cross-zone costs.

![Network Costs page](/images/networkcostpage.png)

### Grafana dashboard

There are Grafana dashboards that are included with the Kubecost installation, but you can also find them in our [cost-analyzer-helm-chart repository](https://github.com/kubecost/cost-analyzer-helm-chart/blob/develop/cost-analyzer/grafana-dashboards/grafana-templates/).

## Enabling network costs

To enable this feature, set the following parameters in your values file following the [Helm installation](https://kubecost.com/install) guide:

```yaml
networkCosts:
  enabled: true
  logLevel: info  # error, warn, info, debug, trace
```

## Additional configuration

You can view a list of common config options in this [_values.yaml_](https://github.com/kubecost/cost-analyzer-helm-chart/blob/8f0a12126330bcdfed467c2cf90fcd5c4834edae/cost-analyzer/values.yaml#L2237) template.

### Prometheus

* If using Kubecost-bundled Prometheus instance, the scrape is automatically configured.
* If you are integrating with an existing Prometheus, you can set `networkCosts.prometheusScrape=true` and the network costs service should be auto-discovered.
* Alternatively, a serviceMonitor is also [available](https://github.com/kubecost/cost-analyzer-helm-chart/blob/700cfa306c8e78bc9a1039b584769b9a0e0757d0/cost-analyzer/values.yaml#L716).

## Cloud Provider Service Tagging

Service tagging allows Kubecost to identify network activity between the pods and various cloud services (e.g. AWS S3, EC2, RDS, Azure Storage, Google Cloud Storage).

![network-services-card](/images/network-svc-card.png)

To enable this, set the following Helm values:

* AWS [`networkCosts.config.services.amazon-web-services=true`](https://github.com/kubecost/cost-analyzer-helm-chart/blob/5787607bf307379363715a220a271e203f0207b4/cost-analyzer/values.yaml#L582)
* Azure [`networkCosts.config.services.azure-cloud-services=true`](https://github.com/kubecost/cost-analyzer-helm-chart/blob/5787607bf307379363715a220a271e203f0207b4/cost-analyzer/values.yaml#L585)
* GCP [`networkCosts.config.services.google-cloud-services=true`](https://github.com/kubecost/cost-analyzer-helm-chart/blob/5787607bf307379363715a220a271e203f0207b4/cost-analyzer/values.yaml#L579)

{% code overflow="wrap" %}
```yaml
networkCosts:
  config:
    services:
      # google-cloud-services: when set to true, enables labeling traffic metrics with google cloud
      # service endpoints
      google-cloud-services: false
      # amazon-web-services: when set to true, enables labeling traffic metrics with amazon web service
      # endpoints.
      amazon-web-services: false
      # azure-cloud-services: when set to true, enables labeling traffic metrics with azure cloud service
      # endpoints
      azure-cloud-services: false
      # user defined services provide a way to define custom service endpoints which will label traffic metrics
      # falling within the defined address range.
      #services:
      #  - service: "test-service-1"
      #    ips:
      #      - "19.1.1.2"
      #  - service: "test-service-2"
      #    ips:
      #      - "15.128.15.2"
      #      - "20.0.0.0/8"
```
{% endcode %}

## Resource limiting

In order to reduce resource usage, Kubecost recommends setting a CPU limit on the network costs DaemonSet. This will cause a few seconds of delay during peak usage and does not affect overall accuracy. This is done by default in Kubecost 1.99+.

For existing deployments, these are the recommended values:

```yaml
networkCosts:
  config:
    resources:
      limits:
        cpu: 500m
      requests:
        cpu: 50m
        memory: 20Mi
```

### Benchmarking metrics

The network-simulator was used to real-time simulate updating ConnTrack entries while simultaneously running a cluster simulated network costs instance. To profile the heap, after a warmup of roughly five minutes, a heap profile of 1,000,000 ConnTrack entries was gathered and examined.

Each ConnTrack entry is equivalent to two transport directions, so every ConnTrack entry is two map entries (connections).

After modifications were made to the network costs to parallelize the delta and dispatch, large map comparisons were significantly lighter in memory. The same tests were performed against simulated data with the following footprint results.

![Benchmarking metrics](/images/post-optimization.png)

## Kubernetes network traffic metrics

The primary source of network metrics is a DaemonSet Pod hosted on each of the nodes in a cluster. Each DaemonSet pod uses `hostNetwork: true` such that it can leverage an underlying kernel module to capture network data. Network traffic data is gathered and the destination of any outbound networking is labeled as:

* Internet Egress: Network target destination was not identified within the cluster.
* Cross Region Egress: Network target destination was identified, but not in the same provider region.
* Cross Zone Egress: Network target destination was identified, and was part of the same region but not the same zone.

These classifications are important because they correlate with network costing models for most cloud providers. To see more detail on these metric classifications, you can view pod logs with the following command:

```
kubectl logs kubecost-network-costs-<pod-identifier> -n kubecost
```

This will show you the top source and destination IP addresses and bytes transferred on the node where this Pod is running. To disable logs, you can set the helm value `networkCosts.trafficLogging` to `false`.

## Overriding traffic classifications

For traffic routed to addresses outside of your cluster but inside your VPC, Kubecost supports the ability to directly classify network traffic to a particular IP address or CIDR block. This feature can be configured in [_values.yaml_](https://github.com/kubecost/cost-analyzer-helm-chart/blob/v1.101/cost-analyzer/values.yaml#L669-L707) under `networkCosts.config`. Classifications are defined as follows:

{% hint style="info" %}
Load Balancers that proxy traffic to the internet (ingresses and gateways) can be specifically classified.
{% endhint %}

* In-zone: A list of destination addresses/ranges that will be classified as in-zone traffic, which is free for most providers.
* In-region: A list of addresses/ranges that will be classified as the same region between source and destinations but different zones.
* Cross-region: A list of addresses/ranges that will be classified as different regions from the source regions.
* Internet: By design, all IP addresses not in a specific list are considered internet. This list can include IPs that would otherwise be "in-zone" or local to be classified as Internet traffic.

```yaml
networkCosts:
  config:
    destinations:
      # In Zone contains a list of address/range that will be
      # classified as in zone.
      in-zone:
        # Loopback Addresses in "IANA IPv4 Special-Purpose Address Registry"
        - "127.0.0.0/8"
        # IPv4 Link Local Address Space
        - "169.254.0.0/16"
        # Private Address Ranges in RFC-1918
        - "10.0.0.0/8" # Remove this entry if using Multi-AZ Kubernetes
        - "172.16.0.0/12"
        - "192.168.0.0/16"

      # In Region contains a list of address/range that will be
      # classified as in region. This is synonymous with cross
      # zone traffic, where the regions between source and destinations
      # are the same, but the zone is different.
      in-region: []

      # Cross Region contains a list of address/range that will be
      # classified as non-internet egress from one region to another.
      cross-region: []

      # Internet contains a list of address/range that will be
      # classified as internet traffic. This is synonymous with traffic
      # that cannot be classified within the cluster.
      # NOTE: Internet classification filters are executed _after_
      # NOTE: direct-classification, but before in-zone, in-region,
      # NOTE: and cross-region.
      internet: []

      # Direct Classification specifically maps an ip address or range
      # to a region (required) and/or zone (optional). This classification
      # takes priority over in-zone, in-region, and cross-region configurations.
      direct-classification: []
      # - region: "us-east1"
      #   zone: "us-east1-c"
      #   ips:
      #     - "10.0.0.0/24"
```

## Permissions

The network costs DaemonSet requires a privileged [`spec.containers[*].securityContext`](https://kubernetes.io/docs/concepts/security/pod-security-standards/) and `hostNetwork: true` in order to leverage an underlying kernel module to capture network data.

Additionally, the network costs DaemonSet mounts to the following directories on the host filesytem. It needs both read & write access. The network costs DaemonSet will only write to the filesystem to enable `conntrack` ([docs ref](https://www.kernel.org/doc/Documentation/networking/nf_conntrack-sysctl.txt))

* `/proc/net/`
* `/proc/sys/net/netfilter`

## Troubleshooting

To verify this feature is functioning properly, you can complete the following steps:

1. Confirm the `kubecost-network-costs` pods are Running. If these Pods are not in a Running state, _kubectl describe_ them and/or view their logs for errors.
2. Ensure `kubecost-networking` target is Up in your Prometheus Targets list. View any visible errors if this target is not Up. You can further verify data is being scrapped by the presence of the `kubecost_pod_network_egress_bytes_total` metric in Prometheus.
3. Verify Network Costs are available in your Kubecost Allocation view. View your browser's Developer Console on this page for any access/permissions errors if costs are not shown.

### Common issues

* Failed to locate network pods: Error message is displayed when the Kubecost app is unable to locate the network pods, which we search for by a label that includes our release name. In particular, we depend on the label `app=<release-name>-network-costs` to locate the pods. If the app has a blank release name this issue may happen.
* Resource usage is a function of unique src and dest IP/port combinations. Most deployments use a small fraction of a CPU and it is also ok to have this Pod CPU throttled. Throttling should increase parse times but should not have other impacts. The following Prometheus metrics are available in v15.3 for determining the scale and the impact of throttling:
  * `kubecost_network_costs_parsed_entries` is the last number of ConnTrack entries parsed `kubecost_network_costs_parse_time` is the last recorded parse time

## Feature limitations

* Today this feature is supported on Unix-based images with ConnTrack
* Actively tested against GCP, AWS, and Azure
* Pods that use hostNetwork share the host IP address
