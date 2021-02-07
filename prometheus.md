# Running a query in Kubecost bundled Prometheus

**1. Connect to Prometheus**

Here is an example command to connect if you've installed Kubecost in the kubecost namespace:

```text
kubectl port-forward -n kubecost service/kubecost-prometheus-server 9003:80
```

**2. Visit Prometheus UI**

View `http://localhost:9003/` in your web browswer. You should be presented with a UI that looks like the following:

![](.gitbook/assets/prom-ui.png)

If you're unable to connect, confirm that the Prometheus server pod is in a `Running` state.

**3. Input your desired query + Execute**

