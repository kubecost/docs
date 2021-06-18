Fetch and Count Number of Nodes 
===============================

The [allocation api](https://github.com/kubecost/docs/blob/master/allocation.md) provides the ability to filter by resource type.

```
/model/assets\?window\=today\&aggregate\=\&accumulate\=false\&filterServices\=Kubernetes\&filterTypes\=Node
```

[jq](https://stedolan.github.io/jq/) can be used to manipulate JSON returned from an API. Using a jq filter in combination with node filter you can fetch the number of nodes visible to kubecost: 

```
$ curl -skL http://kubecost:9090/model/assets\?window\=today\&aggregate\=\&accumulate\=false\&filterServices\=Kubernetes\&filterTypes\=Node | jq '.data| map_values(keys) | .[] | length'
8
```
