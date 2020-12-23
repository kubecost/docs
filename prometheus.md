## Running a query in Kubecost bundled Prometheus

1. Connect to Prometheus

Here is an example command to connect if you've installed Kubecost in the kubecost namespace:

```
kubectl port-forward -n kubecost service/kubecost-prometheus-server 9003:80
```

2. Visit Prometheus UI

You should be presented with a UI that looks like the following:

