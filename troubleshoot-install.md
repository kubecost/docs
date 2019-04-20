## [Issue: no persistent volumes available for this claim and/or no storage class is set](#pv-issue)

Your clusters needs a default storage class for the Kubecost and Prometheus persistent volumes to be successfully attached.

To check if a storage class exists, you can run

```kubectl get storageclass```

You should see a storageclass name with (default) next to it as in this example. 

<pre>
NAME                PROVISIONER           AGE 
standard (default)  kubernetes.io/gce-pd  10d
</pre>

If you see a name but no (default) next to it, run 

```kubectl patch storageclass <name> -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'```

If you don’t see a name, you need to add a storage class. For help doing this, see the following guides:

* AWS: https://docs.aws.amazon.com/eks/latest/userguide/storage-classes.html
* Azure: https://kubernetes.io/docs/concepts/storage/storage-classes/#azure-disk


## [Issue: unable to establish a port-forward connection](#connection-issue)

First, check the status of pods in the target namespace:

`kubectl get pods -n kubecost`

You should see the following pods running

<pre>
NAME                                                     READY   STATUS    RESTARTS   AGE
kubecost-cost-analyzer-599bf995d4-rq8g8                  3/3     Running   2          5m
kubecost-grafana-5cdd75755b-5s9j9                        1/1     Running   0          5m
kubecost-prometheus-kube-state-metrics-bd985f98b-bl8xd   1/1     Running   0          5m
kubecost-prometheus-node-exporter-24b8x                  1/1     Running   0          5m
kubecost-prometheus-node-exporter-4k4w8                  1/1     Running   0          5m
...
kubecost-prometheus-node-exporter-vxpw8                  1/1     Running   0          5m
kubecost-prometheus-node-exporter-zd6rd                  1/1     Running   0          5m
kubecost-prometheus-pushgateway-6f4f8bbfd9-k5r47         1/1     Running   0          5m
kubecost-prometheus-server-6fb8f99bb7-4tjwn              2/2     Running   0          5m
</pre>

If any pod is not Running other than cost-analyzer-checks, you can use the following command to find errors in the recent event log:

`kubectl describe pods <pod-name> -n kubecost`

Should you encounter an unexpected error, please reach out for help on  [Slack](https://join.slack.com/t/kubecost/shared_invite/enQtNTA2MjQ1NDUyODE5LTg0MzYyMDIzN2E4M2M5OTE3NjdmODJlNzBjZGY1NjQ3MThlODVjMGY3NWZlNjQ5NjIwNDc2NGU3MWNiM2E5Mjc) or via email at [team@kubecost.com](team@kubecost.com). 
