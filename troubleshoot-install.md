Troubleshooting
===============

Once an installation is complete, access the Kubecost frontend to view the status of the product. If the Kubecost UI is unavailable, review these troubleshooting resources to determine the problem:

## General troubleshooting commands
These kubernetes commands can be helpful when finding issues with deployments:

1. This command will find all events that aren't normal, with the most recent listed last. Use this if pods are not even starting:

    ```bash
    kubectl get events --sort-by=.metadata.creationTimestamp --field-selector type!=Normal
    ```

12. If a pod is in CrashLoopBackOff, check its logs. Commonly it will be a misconfiguration in helm. If the cost-analyzer pod is the issue, check the logs with:

    ```bash
    kubectl logs deployment/kubecost-cost-analyzer -c cost-model
    ```

3. Alternatively, Lens is a great tool for diagnosing many issues in a single view. See our blog post on [using Lens with Kubecost](https://blog.kubecost.com/blog/lens-kubecost-extension/)

## Issue: no persistent volumes available for this claim and/or no storage class is set

Your clusters need a default storage class for the Kubecost and Prometheus persistent volumes to be successfully attached.

To check if a storage class exists, you can run

```kubectl get storageclass```

You should see a storageclass name with (default) next to it as in this example.

<pre>
NAME                PROVISIONER           AGE
standard (default)  kubernetes.io/gce-pd  10d
</pre>

If you see a name but no (default) next to it, run

`kubectl patch storageclass <name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'`

If you don’t see a name, you need to add a storage class. For help doing this, see the following guides:

* AWS: [https://docs.aws.amazon.com/eks/latest/userguide/storage-classes.html](https://docs.aws.amazon.com/eks/latest/userguide/storage-classes.html)
* Azure: [https://kubernetes.io/docs/concepts/storage/storage-classes/#azure-disk](https://kubernetes.io/docs/concepts/storage/storage-classes/#azure-disk)

Alternatively, you can deploy Kubecost without persistent storage to store by following these steps:

> **Note** This setup is only for experimental purpose. The metric data is reset when kubecost's pod is rescheduled.

1. On your terminal, run this command to add the Kubecost Helm repository:

    `helm repo add kubecost https://kubecost.github.io/cost-analyzer/`

2. Next, run this command to deploy Kubecost without persistent storage:

    ```
    helm upgrade -install kubecost kubecost/cost-analyzer \
    --namespace kubecost --create-namespace \
    --set persistentVolume.enabled="false" \
    --set prometheus.server.persistentVolume.enabled="false"
    ```

## Issue: Unable to establish a port-forward connection

Review the output of the port-forward command:

```
$ kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090
Forwarding from 127.0.0.1:9090 -> 9090
Forwarding from [::1]:9090 -> 9090
```

Forwarding from `127.0.0.1` indicates kubecost should be reachable via a browser at `http://127.0.0.1:9090` or `http://localhost:9090`.

In some cases it may be necessary for kubectl to bind to all interfaces. This can be done with the addition of the flag `--address 0.0.0.0`.

```
$ kubectl port-forward --address 0.0.0.0 --namespace kubecost deployment/kubecost-cost-analyzer 9090
Forwarding from 0.0.0.0:9090 -> 9090
```

Navigating to kubecost while port-forwarding should result in "Handling connection" output in the terminal: 

```
kubectl port-forward --address 0.0.0.0 --namespace kubecost deployment/kubecost-cost-analyzer 9090
Forwarding from 0.0.0.0:9090 -> 9090
Handling connection for 9090
Handling connection for 9090
```

To troubleshoot further check the status of pods in the kubecost namespace:

```
kubectl get pods -n kubecost`
```

All `kubecost-*` pods should have `Running` or `Completed` status.

<pre>
NAME                                                     READY   STATUS    RESTARTS   AGE
kubecost-cost-analyzer-599bf995d4-rq8g8                  2/2     Running   0          5m
kubecost-grafana-5cdd75755b-5s9j9                        1/1     Running   0          5m
kubecost-prometheus-kube-state-metrics-bd985f98b-bl8xd   1/1     Running   0          5m
kubecost-prometheus-node-exporter-24b8x                  1/1     Running   0          5m
kubecost-prometheus-server-6fb8f99bb7-4tjwn              2/2     Running   0          5m
</pre>

If the cost-analyzer or prometheus-server __pods are missing__, we recommend reinstalling with Helm using `--debug` which enables verbose output.

If any __pod is not Running__ other than cost-analyzer-checks, you can use the following command to find errors in the recent event log:

`kubectl describe pod <pod-name> -n kubecost`

## Issue: FailedScheduling kubecost-prometheus-node-exporter

If there is an existing `node-exporter` daemonset, the Kubecost Helm chart may timeout due to a conflict. You can disable the installation of `node-exporter` by passing the following parameters to the Helm install.

```bash
helm install kubecost/cost-analyzer --debug --wait --namespace kubecost --name kubecost \
    --set kubecostToken="<INSERT_YOUR_TOKEN>" \
    --set prometheus.nodeExporter.enabled=false \
    --set prometheus.serviceAccounts.nodeExporter.create=false
 ```

## Issue: Unable to connect to a cluster

You may encounter the following screen if the Kubecost frontend is unable to connect with a live Kubecost server.

![No clusters found](https://raw.githubusercontent.com/kubecost/docs/main/images/no-cluster.png)

Recommended troubleshooting steps are as follows:

If you are using a port other than 9090 for your port-forward, try adding the url with port to the "Add new cluster" dialog.

Next, you can review messages in your browser's developer console. Any meaningful errors or warnings may indicate an unexpected response from the Kubecost server.

Next, point your browser to the `/model` endpoint on your target URL. For example, visit `http://localhost:9090/model/` in the scenario shown above. You should expect to see a Prometheus config file at this endpoint. If your cluster address has changed, you can visit Settings in the Kubecost product to update or you can also [add a new](https://github.com/kubecost/docs/blob/main/multi-cluster.md) cluster.

If you are unable to successfully retrieve your config file from this /model endpoint, we recommend the following:

1. Check your network connection to this host
2. View the status of all Prometheus and Kubecost pods in this cluster's deployment to determine if any container are not in a `Ready` or `Completed` state. When performing the default Kubecost install this can be completed with `kubectl get pods -n kubecost`. All pods should be either Running or Completed. You can run `kubectl describe` on any pods not currently in this state.
3. Finally, view pod logs for any pod that is not in the Running or Completed state to find a specific error message.

## Issue: Unable to load app

If all Kubecost pods are running and you can connect / port-forward to the kubecost-cost-analyzer pod but none of the app's UI will load, we recommend testing the following:

1. Connect directly to a backend service with the following command:
    `kubectl port-forward --namespace kubecost service/kubecost-cost-analyzer 9001`
2. Ensure that `http://localhost:9001` returns the prometheus YAML file

If this is true, you are likely to be hitting a CoreDNS routing issue. We recommend using local routing as a solution:

1. Go to <https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/templates/cost-analyzer-frontend-config-map-template.yaml#L13>
2. Replace ```{{ $serviceName }}.{{ .Release.Namespace }}``` with ```localhost```

## Issue: PodSecurityPolicy CRD is missing for `kubecost-grafana` and `kubecost-cost-analyzer-psp`

PodSecurityPolicy has been [removed from Kubernetes v1.25](https://kubernetes.io/docs/concepts/security/pod-security-policy/). This will result in the following error during install.

```bash
$ helm install kubecost kubecost/cost-analyzer
Error: INSTALLATION FAILED: unable to build kubernetes objects from release manifest: [
    resource mapping not found for name: "kubecost-grafana" namespace: "" from "": no matches for kind "PodSecurityPolicy" in version "policy/v1beta1" ensure CRDs are installed first,
    resource mapping not found for name: "kubecost-cost-analyzer-psp" namespace: "" from "": no matches for kind "PodSecurityPolicy" in version "policy/v1beta1" ensure CRDs are installed first
]
```

To disable PodSecurityPolicy in your deployment:

```bash
# Verify that you don't see "podsecuritypolicy" referenced anywhere
$ helm upgrade -i kubecost kubecost/cost-analyzer --namespace kubecost --dry-run \
    --set podSecurityPolicy.enabled=false \
    --set networkCosts.podSecurityPolicy.enabled=false \
    --set prometheus.podSecurityPolicy.enabled=false \
    --set grafana.rbac.pspEnabled=false

# Install or upgrade Kubecost with PodSecurityPolicy disabled in Grafana
$ helm upgrade -i kubecost kubecost/cost-analyzer --namespace kubecost \
    --set podSecurityPolicy.enabled=false \
    --set networkCosts.podSecurityPolicy.enabled=false \
    --set prometheus.podSecurityPolicy.enabled=false \
    --set grafana.rbac.pspEnabled=false
```

## Question: How can I run on Minikube?

1. Edit nginx configmap ```kubectl edit cm nginx-conf -n kubecost```
2. Search for 9001 and 9003 (should find kubecost-cost-analyzer.kubecost:9001 & kubecost-cost-analyzer.kubecost:9003)
3. Change both entries to localhost:9001 and localhost:9003
4. Restart the kubecost-cost-analyzer pod in the kubecost namespace

## Error loading metadata

Kubecost makes use of cloud provider metadata servers to access instance and cluster metadata. If a restrictive network policy is place this may need to be modified to allow connections from the kubecost pod or namespace.

Error example:

```
gcpprovider.go Error loading metadata cluster-name: Get "http://169.254.169.254/computeMetadata/v1/instance/attributes/cluster-name": dial tcp 169.254.169.254:80: i/o timeout
```

Have a question not answered on this page? Email us at [support@kubecost.com](support@kubecost.com) or [join the Kubecost Slack community](https://join.slack.com/t/kubecost/shared_invite/zt-1dz4a0bb4-InvSsHr9SQsT_D5PBle2rw)!

---

Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/troubleshoot-install.md)

<!--- {"article":"4407601830679","section":"4402815696919","permissiongroup":"1500001277122"} --->
