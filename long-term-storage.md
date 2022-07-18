Multi-Cluster / Long Term Storage
=================================

Kubecost leverages Thanos to enable durable storage for three different purposes:

1. Centralize metric data for a global multi-cluster view into Kubernetes costs via a Prometheus sidecar
1. Allow for unlimited data retention
1. Backup Kubecost [ETL data](https://guide.kubecost.com/hc/en-us/articles/4407601815191-ETL-S3-Backup)

> **Note**: This feature requires an [Enterprise license](https://kubecost.com/pricing).

To enable Thanos, follow these steps:

## Step 1: Create *object-store.yaml*

This step creates the *object-store.yaml* file that contains your durable storage target (e.g. GCS, S3, etc.) configuration and access credentials.
The details of this file are documented thoroughly in [Thanos documentation](https://thanos.io/tip/thanos/storage.md/).

We have guides for using cloud-native storage for the largest cloud providers. Other providers can be similarly configured.

Use the appropriate guide for your cloud provider:

* [Google Cloud Storage](https://github.com/kubecost/docs/blob/main/long-term-storage-gcp.md)
* [AWS/S3](https://github.com/kubecost/docs/blob/main/long-term-storage-aws.md)
* [Azure](https://github.com/kubecost/docs/blob/main/long-term-storage-azure.md)

## Step 2: Create object-store secret

Create a secret with the .yaml file generated in the previous step:

```shell
kubectl create secret generic kubecost-thanos -n kubecost --from-file=./object-store.yaml
```

## Step 3: Unique Cluster ID

Each cluster needs to be labelled with a unique Cluster ID, which is done in two places.

`values-clusterName.yaml`

```yaml
kubecostProductConfigs:
  clusterName: kubecostProductConfigs_clusterName
prometheus:
  server:
    global:
      external_labels:
        cluster_id: kubecostProductConfigs_clusterName
```

## Step 4: Deploying Kubecost with Thanos

The Thanos subchart includes `thanos-bucket`, `thanos-query`, `thanos-store`,  `thanos-compact`, and service discovery for `thanos-sidecar`. These components are recommended when deploying Thanos on the primary cluster.

These values can be adjusted under the `thanos` block in *values-thanos.yaml*. Available options are here: [thanos/values.yaml](https://github.com/kubecost/cost-analyzer-helm-chart/blob/master/cost-analyzer/charts/thanos/values.yaml)

```shell
helm upgrade kubecost kubecost/cost-analyzer \
    --install \
    --namespace kubecost \
    -f https://raw.githubusercontent.com/kubecost/cost-analyzer-helm-chart/master/cost-analyzer/values-thanos.yaml \
    -f values-clusterName.yaml
```

> **Note**: The `thanos-store` container is configured to request 2.5GB memory, this may be reduced for smaller deployments. `thanos-store` is only used on the primary Kubecost cluster.

To verify installation, check to see all Pods are in a *READY* state. View Pod logs for more detail and see common troubleshooting steps below.

## Troubleshooting

Thanos sends data to the bucket every 2 hours. Once 2 hours have passed, logs should indicate if data has been sent successfully or not.

You can monitor the logs with:

```bash
kubectl logs --namespace kubecost -l app=prometheus -l component=server --prefix=true --container thanos-sidecar --tail=-1 | grep uploaded
```

Monitoring logs this way should return results like this:

```log
[pod/kubecost-prometheus-server-xxx/thanos-sidecar] level=debug ts=2022-06-09T13:00:10.084904136Z caller=objstore.go:206 msg="uploaded file" from=/data/thanos/upload/BUCKETID/chunks/000001 dst=BUCKETID/chunks/000001 bucket="tracing: kc-thanos-store"
```

As an aside, you can validate the Prometheus metrics are all configured with correct cluster names with:

```bash
kubectl logs --namespace kubecost -l app=prometheus -l component=server --prefix=true --container thanos-sidecar --tail=-1 | grep external_labels
```

To troubleshoot the IAM Role Attached to the serviceaccount, you can create a Pod using the same service account used by the thanos-sidecar (default is `kubecost-prometheus-server`):

`s3-pod.yaml`

```yaml
apiVersion: v1
kind: Pod
metadata:
  labels:
    run: s3-pod
  name: s3-pod
spec:
  serviceAccountName: kubecost-prometheus-server
  containers:
  - image: amazon/aws-cli
    name: my-aws-cli
    command: ['sleep', '500']
```

```bash
kubectl apply -f s3-pod.yaml
kubectl exec -i -t s3-pod -- aws s3 ls s3://kc-thanos-store
```

This should return a list of objects (or at least not give a permission error).

### Cluster not writing data to thanos bucket

If a cluster is not successfully writing data to the bucket, review `thanos-sidecar` logs with the following command:

```shell
kubectl logs kubecost-prometheus-server-<your-pod-id> -n kubecost -c thanos-sidecar
```

Logs in the following format are evidence of a successful bucket write:

```text
level=debug ts=2019-12-20T20:38:32.288251067Z caller=objstore.go:91 msg="uploaded file" from=/data/thanos/upload/BUCKET-ID/meta.json dst=debug/metas/BUCKET-ID.json bucket=kc-thanos
```

### Stores not listed at the `/stores` endpoint

If thanos-query can't connect to both the sidecar and the store, you may want to directly specify the store gRPC service address instead of using DNS discovery (the default). You can quickly test if this is the issue by running:

 `kubectl edit deployment kubecost-thanos-query -n kubecost`

and adding

`--store=kubecost-thanos-store-grpc.kubecost:10901`

to the container args. This will cause a query restart and you can visit `/stores` again to see if the store has been added.

If it has, you'll want to use these addresses instead of DNS more permanently by setting .Values.thanos.query.stores in *values-thanos.yaml*.

<pre>
...
thanos:
  store:
    enabled: true
    grpcSeriesMaxConcurrency: 20
    blockSyncConcurrency: 20
    extraEnv:
      - name: GOGC
        value: "100"
    resources:
      requests:
        memory: "2.5Gi"
  query:
    enabled: true
    timeout: 3m
    # Maximum number of queries processed concurrently by query node.
    maxConcurrent: 8
    # Maximum number of select requests made concurrently per a query.
    maxConcurrentSelect: 2
    resources:
      requests:
        memory: "2.5Gi"
    autoDownsampling: false
    extraEnv:
      - name: GOGC
        value: "100"
    <b>stores:</b>
      <b>- "kubecost-thanos-store-grpc.kubecost:10901"</b>
</pre>

### Additional Troubleshooting

A common error is as follows, which means you do not have the correct access to the supplied bucket:

```text
thanos-svc-account@project-227514.iam.gserviceaccount.com does not have storage.objects.list access to thanos-bucket., forbidden"
```

Assuming Pods are running, use port forwarding to connect to the `thanos-query-http` endpoint:

```shell
kubectl port-forward svc/kubecost-thanos-query-http 8080:10902 --namespace kubecost
```

Then navigate to <http://localhost:8080> in your browser. This page should look very similar to the Prometheus console.

![image](https://raw.githubusercontent.com/kubecost/docs/main/images/thanos-query.png)

If you navigate to *Stores* using the top navigation bar, you should be able to see the status of both the `thanos-store` and `thanos-sidecar` which accompanied the Prometheus server:

![image](https://raw.githubusercontent.com/kubecost/docs/main/images/thanos-store.png)

Also note that the sidecar should identify with the unique `cluster_id` provided in your *values.yaml* in the previous step. Default value is `cluster-one`.

The default retention period for when data is moved into the object storage is currently *2h* - This configuration is based on Thanos suggested values. __By default, it will be 2 hours before data is written to the provided bucket.__

Instead of waiting *2h* to ensure that thanos was configured correctly, the default log level for the thanos workloads is `debug` (it's very light logging even on debug). You can get logs for the `thanos-sidecar`, which is part of the `prometheus-server` Pod, and `thanos-store`. The logs should give you a clear indication of whether or not there was a problem consuming the secret and what the issue is. For more on Thanos architecture, view [this resource](https://github.com/thanos-io/thanos/blob/master/docs/design.md).

## Additional Help

Please let us know if you run into any issues, we are here to help.

Visit our [Slack community](https://join.slack.com/t/kubecost/shared_invite/enQtNTA2MjQ1NDUyODE5LWFjYzIzNWE4MDkzMmUyZGU4NjkwMzMyMjIyM2E0NGNmYjExZjBiNjk1YzY5ZDI0ZTNhZDg4NjlkMGRkYzFlZTU) and try our #support channel, or email us at <team@kubecost.com>.

---
Edit this doc on [GitHub](https://github.com/kubecost/docs/blob/main/long-term-storage.md)

<!--- {"article":"4407595964695","section":"4402815636375","permissiongroup":"1500001277122"} --->
