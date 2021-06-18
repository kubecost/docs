Authentication - Thanos and Prometheus
======================================


# Basic Auth

## Thanos:
 
```
$ echo -n "<username>" > USERNAME

$ echo -n “<password>” PASSWORD

$ kubectl create secret generic mcdbsecret -n kubecost --from-file=USERNAME --from-file=PASSWORD

$ helm upgrade kubecost stagingrepo/cost-analyzer -n kubecost -f <existing values.yaml> --set global.thanos.queryServiceBasicAuthSecretName=mcdbsecret
```



## Prometheus:

```
$ echo -n "<username>" > USERNAME

$ echo -n “<password>” PASSWORD

$ kubectl create secret generic dbsecret -n kubecost --from-file=USERNAME --from-file=PASSWORD

$ helm upgrade kubecost stagingrepo/cost-analyzer -n kubecost -f <existing values.yaml> --set global.prometheus.queryServiceBasicAuthSecretName=dbsecret
```

# Bearer Token:
 

## Thanos:

```
$ echo -n "<token>" > TOKEN

$ kubectl create secret generic mcdbsecret -n kubecost --from-file=TOKEN 

$ helm upgrade kubecost stagingrepo/cost-analyzer -n kubecost -f <existing values.yaml> --set global.thanos.queryServiceBearerTokenSecretName=dbsecret
```



## Prometheus:

```
$ echo -n "<token>" > TOKEN

$ kubectl create secret generic dbsecret -n kubecost --from-file=TOKEN 

$ helm upgrade kubecost stagingrepo/cost-analyzer -n kubecost -f <existing values.yaml> --set global.prometheus.queryServiceBearerTokenSecretName=dbsecret
```
