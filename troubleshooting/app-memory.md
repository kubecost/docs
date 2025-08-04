Kubecost Memory Usage
=====================

## Heap

There are a number of configuration parameters that impact Kubecost and Prometheus memory usage.
To capture a breakdown of current memory usage, visit this URL:

```http
http://<your-kubecost-endpoint>/model/debug/pprof/heap
```

## Profile

To capture an application profile, visit this URL:

```http
http://<your-kubecost-endpoint>/model/debug/pprof/profile?seconds=30
```

Next, share these files directly with our team via email (<support@kubecost.com>) or directly on Slack.
