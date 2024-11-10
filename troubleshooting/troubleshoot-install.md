# Troubleshoot Install

Once an installation is complete, access the Kubecost UI to view the status of the product (select _Settings_ > _Diagnostics_ > _View Full Diagnostics_). If the Kubecost UI is unavailable, review these troubleshooting resources to determine the problem.

## General troubleshooting commands

These Kubernetes commands can be helpful when finding issues with deployments.

This command will find all events that aren't normal, with the most recent listed last. Use this if pods are not even starting:

{% code overflow="wrap" %}
```bash
kubectl get events --sort-by=.metadata.creationTimestamp --field-selector type!=Normal
```
{% endcode %}

Another option is to check for a describe command of the specific pod in question. This command will give a list of the Events specific to this pod.

{% code overflow="wrap" %}
```bash
> kubectl -n kubecost get pods
NAME                                          READY   STATUS              RESTARTS   AGE
kubecost-cost-analyzer-5cb499f74f-c5ndf       0/2     ContainerCreating   0          2m14s
kubecost-kube-state-metrics-99bb8c55b-v2bgd   1/1     Running             0          2m14s
kubecost-prometheus-server-f99987f55-86snj    2/2     Running             0          2m14s

> kubectl -n kubecost describe pod kubecost-cost-analyzer-5cb499f74f-c5ndf
Name:         kubecost-cost-analyzer-5cb499f74f-c5ndf
Namespace:    kubecost
Priority:     0
Node:         gke-kc-integration-test--default-pool-e04c72e7-vsxl/10.128.0.102
Start Time:   Wed, 19 Oct 2022 04:15:05 -0500
Labels:       app=cost-analyzer
            app.kubernetes.io/instance=kubecost
            app.kubernetes.io/name=cost-analyzer
            pod-template-hash=b654c4867
...
Events:
    <RELEVANT ERROR MESSAGES HERE>
    <RELEVANT ERROR MESSAGES HERE>
    <RELEVANT ERROR MESSAGES HERE>
```
{% endcode %}

If a pod is in CrashLoopBackOff, check its logs. Commonly it will be a misconfiguration in Helm. If the cost-analyzer pod is the issue, check the logs with:

```bash
kubectl logs deployment/kubecost-cost-analyzer -c cost-model
```

Alternatively, Lens is a great tool for diagnosing many issues in a single view. See our blog post on [using Lens with Kubecost](https://blog.kubecost.com/blog/lens-kubecost-extension/) to learn more.

## Configuring Log Levels

You can adjust the log output while deploying through Helm by using the `logLevel` property and/or the `LOG_FORMAT` environment variable.

### Adjusting Log Level
Adjusting the log level increases or decreases the level of verbosity written to the logs. The `logLevel` property accepts the following values:

* `trace`
* `debug`
* `info`
* `warn`
* `error`
* `fatal`

For example, to set the log level to `debug`, add the following flag to the Helm command:

{% code overflow="wrap" %}
```bash
--set 'kubecostModel.logLevel=debug'
```
{% endcode %}

### Adjusting Log Format

Adjusting the log format changes the format in which the logs are output making it easier for log aggregators to parse and display logged messages. The `LOG_FORMAT` environment variable accepts the values `JSON`, for a structured output, and `pretty` for a nice, human-readable output.

| Value  | Output                                                                                                                     |
|--------|----------------------------------------------------------------------------------------------------------------------------|
| `JSON`   | `{"level":"info","time":"2006-01-02T15:04:05.999999999Z07:00","message":"Starting cost-model (git commit \"1.91.0-rc.0\")"}` |
| `pretty` | `2006-01-02T15:04:05.999999999Z07:00 INF Starting cost-model (git commit "1.91.0-rc.0")`                                     |

### Temporarily set log level

To temporarily set the log level without restarting the pod, you can send a POST request to `/logs/level` with one of the valid log levels. This does not persist between pod restarts, Helm deployments, etc. Here's an example:

```sh
curl -X POST \
    'http://localhost:9090/model/logs/level' \
    -d '{"level": "debug"}'
```

A GET request can be sent to the same endpoint to retrieve the current log level.

## Other issues

### Failed to download cost-analyzer Helm chart

If your Kubecost installation fails and you are unable to download the cost-analyzer Helm chart from GitHub chart repository, run `helm repo update`, then run your install command again. The install should run successfully.

### Cost-model container Go panic on Azure Kubernetes Service (AKS) when using the Files Container Storage Interface (CSI) driver

Some AKS users have reported that the cost-model container in the kubecost-cost-analyzer pod will panic with the following message when using the [Azure Files Container Storage Interface (CSI) driver](https://learn.microsoft.com/en-us/azure/aks/azure-files-csi):

{% code overflow="wrap" %}
```
goroutine 32660 [running]:
runtime.throw({0x347c9c7?, 0x30?})
	/usr/local/go/src/runtime/panic.go:1047 +0x5d fp=0xc01421cb70 sp=0xc01421cb40 pc=0x43919d
runtime.sigpanic()
	/usr/local/go/src/runtime/signal_unix.go:834 +0x125 fp=0xc01421cbd0 sp=0xc01421cb70 pc=0x44fb85
github.com/opencost/opencost/pkg/kubecost.isBinaryTag(...)
	/app/opencost/pkg/kubecost/kubecost_codecs.go:103
github.com/opencost/opencost/pkg/kubecost.(*AllocationSet).UnmarshalBinary(0x40dd8a?, {0x7fa5669b5000, 0xb621c, 0xb621c})
	/app/opencost/pkg/kubecost/kubecost_codecs.go:1932 +0x9d fp=0xc01421cc48 sp=0xc01421cbd0 pc=0xd1a5dd
github.com/kubecost/kubecost-cost-model/pkg/core/store.(*FileStorageStrategy[...]).Load.func1()
	/app/kubecost-cost-model/pkg/core/store/filestrategy.go:230 +0x3f fp=0xc01421cc78 sp=0xc01421cc48 pc=0x28f00df
github.com/kubecost/kubecost-cost-model/pkg/core/sys.(*RWPageFile).Read(0xc01520b830, 0xc01421cda0)
```
{% endcode %}

To resolve this issue, please use an alternate storage class for the Kubecost `cost-analyzer` PV. For example the [Azure Disk Container Storage Interface (CSI)](https://learn.microsoft.com/en-us/azure/aks/azure-disk-csi).

### No persistent volumes available for this claim and/or no storage class is set

Your clusters need a default storage class for the Kubecost and Prometheus persistent volumes to be successfully attached. To check if a storage class exists, run:

```bash
kubectl get storageclass
```

You should see a StorageCase name with `(default)` next to it. See:

```
NAME                PROVISIONER           AGE
standard (default)  kubernetes.io/gce-pd  10d
```

If you see a name but no `(default)` next to it, run:

`kubectl patch storageclass <name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'`

If you don’t see a name, you need to add a StorageClass. For help doing this, see this Kubernetes article on [Storage Classes](https://kubernetes.io/docs/concepts/storage/storage-classes/) for assistance.

Alternatively, you can deploy Kubecost without persistent storage to store by following these steps:

{% hint style="warning" %}
This setup is only for experimental purpose. The metric data is reset when Kubecost's pod is rescheduled.
{% endhint %}

1.  In your terminal, run this command to add the Kubecost Helm repository:

    `helm repo add kubecost https://kubecost.github.io/cost-analyzer/`
2.  Next, run this command to deploy Kubecost without persistent storage:

    ```bash
    helm upgrade -install kubecost kubecost/cost-analyzer \
    --namespace kubecost --create-namespace \
    --set persistentVolume.enabled="false" \
    --set prometheus.server.persistentVolume.enabled="false"
    ```

### Waiting for a volume to be created, either by external provisioner "ebs.csi.aws.com" or manually created by system administrator

If the PVC is in a pending state for more than 5 minutes, and the cluster is Amazon EKS 1.23+, the error message appears as the following example:

```bash
kubectl describe pvc cost-analyzer -n kubecost | grep "ebs.csi.aws.com"
```

Example result:

{% code overflow="wrap" %}
```bash
Annotations:   volume.beta.kubernetes.io/storage-provisioner: ebs.csi.aws.com
               volume.kubernetes.io/storage-provisioner: ebs.csi.aws.com

Normal  ExternalProvisioning  69s (x82 over 21m)  persistentvolume-controller  waiting for a volume to be created, either by external provisioner "ebs.csi.aws.com" or manually created by system administrator
```
{% endcode %}

YTo fix this, you need to install the [AWS EBS CSI driver](https://docs.aws.amazon.com/eks/latest/userguide/ebs-csi.html). This may be because the Amazon EKS cluster version 1.23+ uses the "ebs.csi.aws.com" provisioner, and the AWS EBS CSI driver has not been installed yet.

### Unable to establish a port-forward connection

Review the output of the port-forward command:

```bash
$ kubectl port-forward --namespace kubecost deployment/kubecost-cost-analyzer 9090
Forwarding from 127.0.0.1:9090 -> 9090
Forwarding from [::1]:9090 -> 9090
```

Forwarding from `127.0.0.1` indicates Kubecost should be reachable via a browser at `http://127.0.0.1:9090` or `http://localhost:9090`.

In some cases it may be necessary for kubectl to bind to all interfaces. This can be done with the addition of the flag `--address 0.0.0.0`.

{% code overflow="wrap" %}
```bash
$ kubectl port-forward --address 0.0.0.0 --namespace kubecost deployment/kubecost-cost-analyzer 9090
Forwarding from 0.0.0.0:9090 -> 9090
```
{% endcode %}

Navigating to Kubecost while port-forwarding should result in "Handling connection" output in the terminal:

{% code overflow="wrap" %}
```bash
kubectl port-forward --address 0.0.0.0 --namespace kubecost deployment/kubecost-cost-analyzer 9090
Forwarding from 0.0.0.0:9090 -> 9090
Handling connection for 9090
Handling connection for 9090
```
{% endcode %}

To troubleshoot further, check the status of pods in the Kubecost namespace:

```bash
kubectl get pods -n kubecost`
```

All `kubecost-*` pods should have `Running` or `Completed` status.

{% code overflow="wrap" %}
```
NAME                                                     READY   STATUS    RESTARTS   AGE
kubecost-cost-analyzer-599bf995d4-rq8g8                  2/2     Running   0          5m
kubecost-grafana-5cdd75755b-5s9j9                        1/1     Running   0          5m
kubecost-prometheus-kube-state-metrics-bd985f98b-bl8xd   1/1     Running   0          5m
kubecost-prometheus-node-exporter-24b8x                  1/1     Running   0          5m
kubecost-prometheus-server-6fb8f99bb7-4tjwn              2/2     Running   0          5m
```
{% endcode %}

If the cost-analyzer or prometheus-server pods are missing, we recommend reinstalling with Helm using `--debug` which enables verbose output.

If any pod is not Running other than cost-analyzer-checks, you can use the following command to find errors in the recent event log:

```
kubectl describe pod <pod-name> -n kubecost
```

### FailedScheduling kubecost-prometheus-node-exporter

If there is an existing node-exporter DaemonSet, the Kubecost Helm chart may timeout due to a conflict. The Node Exporter is disabled by default, but if it was enabled at any point, you can disable it by changing the flag during your `helm upgrade` command:
{% code overflow="wrap" %}
```bash
    --set prometheus.serviceAccounts.nodeExporter.enabled=false
```
{% endcode %}

### Unable to connect to a cluster

You may encounter the following screen if the Kubecost UI is unable to connect with a live Kubecost server.

![No clusters found](/images/no-cluster.png)

Recommended troubleshooting steps are as follows:

If you are using a port other than 9090 for your port-forward, try adding the URL with 'port' to the "Add new cluster" dialog.

Next, you can review messages in your browser's developer console. Any meaningful errors or warnings may indicate an unexpected response from the Kubecost server.

Next, point your browser to the `/model` endpoint on your target URL. For example, visit `http://localhost:9090/model/` in the scenario shown above. You should expect to see a Prometheus config file at this endpoint. If your cluster address has changed, you can visit Settings in the Kubecost product to update or you can also [add a new](/install-and-configure/install/multi-cluster/multi-cluster.md) cluster.

If you are unable to successfully retrieve your config file from this `/model` endpoint, we recommend the following:

1. Check your network connection to this host
2. View the status of all Prometheus and Kubecost pods in this cluster's deployment to determine if any container are not in a `Ready` or `Completed` state. When performing the default Kubecost install this can be completed with `kubectl get pods -n kubecost`. All pods should be either Running or Completed. You can run `kubectl describe` on any pods not currently in this state.
3. Finally, view pod logs for any pod that is not in the `Running` or `Completed` state to find a specific error message.

### Issue: Kubecost UI won't load

If all Kubecost pods are running and you can connect/port-forward to the kubecost-cost-analyzer pod, but none of the app's UI will load, we recommend testing the following:

1. Connect directly to a backend service with the following command: `kubectl port-forward --namespace kubecost service/kubecost-cost-analyzer 9001`
2. Ensure that `http://localhost:9001` returns the Prometheus YAML file

If this is true, you are likely to be hitting a CoreDNS routing issue. We recommend using local routing as a solution:

1. Go to this [_cost-analyzer-frontend-config-map-template.yaml_](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/templates/cost-analyzer-frontend-config-map-template.yaml#L13)_._
2. Replace `{{ $serviceName }}.{{ .Release.Namespace }}` with `localhost`

### PodSecurityPolicy CRD is missing for `kubecost-grafana` and `kubecost-cost-analyzer-psp`

PodSecurityPolicy (PSP) has been [removed from Kubernetes v1.25](https://kubernetes.io/docs/concepts/security/pod-security-policy/). This will result in the following error during install.

{% code overflow="wrap" %}
```bash
$ helm install kubecost kubecost/cost-analyzer
Error: INSTALLATION FAILED: unable to build kubernetes objects from release manifest: [
    resource mapping not found for name: "kubecost-grafana" namespace: "" from "": no matches for kind "PodSecurityPolicy" in version "policy/v1beta1" ensure CRDs are installed first,
    resource mapping not found for name: "kubecost-cost-analyzer-psp" namespace: "" from "": no matches for kind "PodSecurityPolicy" in version "policy/v1beta1" ensure CRDs are installed first
]
```
{% endcode %}

To disable PSP in your deployment:

1. Back up your Helm values with `helm get values -n kubecost kubecost > kubecost-values.yaml`
2. Open `kubecost-values.yaml` and delete any references to `podSecurityPolicy` or `psp`
3. Delete all Helm secrets in the Kubecost namespace:

    {% code overflow="wrap" %}
    ```bash
    # Get the list of secrets
    kubectl get secrets -n kubecost
    # Backup secrets to a file
    kubectl get secrets -n kubecost -o yaml > kubecost-secrets.yaml
    # Delete any secret with the helm values, which look like: sh.helm.release.v1.aggregator.vX
    kubectl delete secrets -n kubecost SECRET_NAME
    ```
    {% endcode %}

4. Upgrade Kubecost as you normally would, be absolutely certain to pass the -f flag with your values file:

{% code overflow="wrap" %}
```bash
helm upgrade kubecost kubecost/cost-analyzer --namespace kubecost -f kubecost-values.yaml
```
{% endcode %}

### With Kubernetes v1.25, Helm commands fail when PodSecurityPolicy CRD is missing for `kubecost-grafana` and `kubecost-cost-analyzer-psp` in existing Kubecost installs

Since PodSecurityPolicy (PSP) has been [removed from Kubernetes v1.25](https://kubernetes.io/docs/concepts/security/pod-security-policy/), it's possible to encounter a state where all Kubecost-related Helm commands fail after Kubernetes has been upgraded to v1.25.

{% code overflow="wrap" %}
```bash
$ helm upgrade kubecost kubecost/cost-analyzer
Error: UPGRADE FAILED: unable to build kubernetes objects from current release manifest: [
resource mapping not found for name: "kubecost-grafana" namespace: "" from "": no matches for kind "PodSecurityPolicy" in version "policy/v1beta1"
ensure CRDs are installed first, resource mapping not found for name: "kubecost-cost-analyzer-psp" namespace: "" from "": no matches for kind "PodSecurityPolicy" in version "policy/v1beta1"
ensure CRDs are installed first
]
```
{% endcode %}

To prevent this Helm error state please upgrade Kubecost to at least v1.99 prior to upgrading Kubernetes to v1.25. Additionally please follow the [above](#podsecuritypolicy-crd-is-missing-for-kubecost-grafana-and-kubecost-cost-analyzer-psp) instructions for disabling PSP.

If Kubecost PSP is not disabled prior to Kubernetes v1.25 upgrades, you may need to manually delete the Kubecost install. Prior to doing this please ensure you have [ETL backups enabled](https://docs.kubecost.com/v/1.0x/install-and-configure/install/etl-backup) as well as Helm values, and Prometheus/Thanos data backed up. Manual removal can be done by deleting the Kubecost namespace.

### The `kube-state-metrics` pod fails to start, `Failed to list *v1beta1.Ingress` and or `Failed to list *v1beta1.CertificateSigningRequest`

This error found in the `kube-state-metrics` logs occurs when API's are not present in Kubernetes. This will cause the KSM pod startup to fail. The full error is as follows.

{% code overflow="wrap" %}
```
E0215 13:33:44.225827 1 reflector.go:156] pkg/mod/k8s.io/client-go@v0.0.0-20191109102209-3c0d1af94be5/tools/cache/reflector.go:108: Failed to list *v1beta1.Ingress: the server could not find the requested resource (get ingresses.extensions)
E0215 13:33:44.225870 1 reflector.go:156] pkg/mod/k8s.io/client-go@v0.0.0-20191109102209-3c0d1af94be5/tools/cache/reflector.go:108: Failed to list *v1beta1.CertificateSigningRequest: the server could not find the requested resource
```
{% endcode %}

To resolve this error you can disable the corresponding KSM metrics collectors by setting the following Helm values to `false`.

* [prometheus.kube-state-metrics.collectors.ingresses=false](https://github.com/kubecost/cost-analyzer-helm-chart/blob/9f3d7974247bfd3910fbf69d0d4bd66f1335201a/cost-analyzer/charts/prometheus/charts/kube-state-metrics/values.yaml#L99|prometheus.kube-state-metrics.collectors.ingresses=false)
* [prometheus.kube-state-metrics.collectors.certificatesigningrequests=false](https://github.com/kubecost/cost-analyzer-helm-chart/blob/9f3d7974247bfd3910fbf69d0d4bd66f1335201a/cost-analyzer/charts/prometheus/charts/kube-state-metrics/values.yaml#L92)

You can verify the changes are in place by describing the KSM deployment, the collectors should no longer be present in the Container Arguments list.

```
kubectl get deployment -n kubecost kubecost-kube-state-metrics -o yaml
```

### Failed to download "oci://public.ecr.aws/kubecost/cost-analyzer" at version "x.xx.x"

This error appears when you install Kubecost using AWS optimized version on your Amazon EKS cluster. There are a few reasons that generate this error message:

#### A. The Kubecost version that you tried to install is not available yet

Check our ECR public gallery for the latest available version at https://gallery.ecr.aws/kubecost/cost-analyzer

#### B. Your docker authentication token for Amazon ECR public gallery is expired

Try to login to the Amazon ECR public gallery again to refresh the authentication token with the following commands:

{% code overflow="wrap" %}
```bash
aws ecr-public get-login-password --region us-east-1 | docker login --username AWS --password-stdin public.ecr.aws
export HELM_EXPERIMENTAL_OCI=1
aws ecr-public get-login-password --region us-east-1 | helm registry login --username AWS --password-stdin public.ecr.aws
```
{% endcode %}

### How can I run on Minikube?

1. Edit nginx configmap `kubectl edit cm nginx-conf -n kubecost`
2. Search for 9001 and 9003 (should find kubecost-cost-analyzer.kubecost:9001 & kubecost-cost-analyzer.kubecost:9003)
3. Change both entries to localhost:9001 and localhost:9003
4. Restart the kubecost-cost-analyzer pod in the kubecost namespace

### What is the difference between `kubecostToken` and `productKey`

`.Values.kubecostToken` is primarily used to manage trial access and is provided to you when visiting [http://kubecost.com/install](http://kubecost.com/install).

`kubecostProductConfigs.productKey` is used to apply an Enterprise license. More information can be found in the [Adding a Product Key](/install-and-configure/advanced-configuration/add-key.md) section.

### Error loading metadata

Kubecost makes use of cloud provider metadata servers to access instance and cluster metadata. If a restrictive network policy is place this may need to be modified to allow connections from the kubecost pod or namespace. Example:

{% code overflow="wrap" %}
```
gcpprovider.go Error loading metadata cluster-name: Get "http://169.254.169.254/computeMetadata/v1/instance/attributes/cluster-name": dial tcp 169.254.169.254:80: i/o timeout
```
{% endcode %}

### Local disks showing costs in Assets

Some cloud providers do not charge you for local disks physically attached to the node (e.g. ephemeral storage). By default, Kubecost monitors your local disk usage/capacity and applies an associated cost. To disable this feature use the following config:

```yaml
kubecostModel:
  extraEnv:
    - name: "ASSET_INCLUDE_LOCAL_DISK_COST"
      value: "false"
```

This configuration will need to be applied to any cluster on which you do not want to charge for local disks and only takes effect on data moving forward. To fix historical data, you will need to [repair Asset & Allocation ETL](/troubleshooting/etl-repair.md) for each affected cluster, then wait for Kubecost's Aggregator to reingest the updated ETL data.

## Additional support

Do you have a question not answered on this page? Email us at [support@kubecost.com](mailto:support@kubecost.com) or [join the Kubecost Slack community](https://kubecost.com/join-slack)!
