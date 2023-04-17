# Contexts

Kubecost supports the ability to monitor multiple **contexts** of clusters. A context refers to either a single monitored cluster, or a set of clusters that leverage [durable storage](long-term-storage.md).

Below are the steps for adding additional contexts on the Kubecost Business and Enterprise tier.

## Add from frontend

When adding a context directly from the frontend, Kubecost adds it locally for your browser. To make this context accessible to other users in your organization, follow the steps to [add at install-time](context-switcher.md#add-at-install-time) below.

1. Install Kubecost on the additional cluster you would like to view. The recommended Kubecost install path is available at [kubecost.com/install](https://www.kubecost.com/install).
2.  Expose port 9090 of the `kubecost-cost-analyzer` Pod. This can be done with a Kubernetes Ingress ([example](ingress-examples.md)) or LoadBalancer ([example](images/kubecost-lb.yaml)).

    > **Note**: By default, a LoadBalancer exposes endpoints to the wide internet. Be careful about following the authentication requirements of your organization and environment.
3. Select _Switch Context_ in the lower left corner of the Kubecost UI. The Contexts window opens.
4. Provide the accessible URL (with port included) for the target Kubecost installation, then select _Add_. Here's an example: `http://e9a706220bae04199-1639813551.us-east-2.elb.amazonaws.com:9090`

## Add at install-time

After following Steps 1 and 2 above, provide a list of context names/endpoints under `kubecostProductConfigs.clusters` in [values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/values.yaml) during Helm install or upgrade. Here's an example values block:

```yaml
 kubecostProductConfigs:
  clusters:
   - name: "Cluster A"
     address: http://cluster-a.kubecost.com:9090
```
