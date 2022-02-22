Running a query in Kubecost bundled Prometheus
==============================================

__1. Connect to Prometheus__

Here is an example command to connect if you've installed Kubecost in the kubecost namespace:

```
kubectl port-forward -n kubecost service/kubecost-prometheus-server 9003:80
```

__2. Visit Prometheus UI__

View `http://localhost:9003/` in your web browser. You should be presented with a UI that looks like the following:

![](https://github.com/kubecost/docs/blob/main/images/prom-ui.png)

If you're unable to connect, confirm that the Prometheus server pod is in a `Running` state. 


__3. Input your desired query + Execute__

Edit this doc on [Github](https://github.com/kubecost/docs/blob/main/prometheus.md)

<!--- {"article":"4407601824279","section":"4402815656599","permissiongroup":"1500001277122"} --->
