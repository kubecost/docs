# Collections APIs: collection complement costs

[Collections APIs](README.md#table-of-contents) / Querying by collection / Query complement costs of a collection

## Query complement costs of a collection

Use the following request to query the complement costs of a collection, which includes all domain costs not included in the collection. 

### Request

```
GET /collections/query/complement?id=<string>&window=<string>
```

### Examples

```
GET /collections/query/complement?id=8a939ba1-ff15-4600-b711-2cb109114914&window=30d
```

```json
{
    "window": {
        "start": "2023-01-01T00:00:00Z",
        "end": "2023-02-01T00:00:00Z"
    },
    "data": {
        "cost": {
            "totalCost": 2000.0,
            "idleCost": 20.0,
            "domainCosts": {
                "cloudCost": {
                    "totalCost": 1800
                },
                "kubernetesCost": {
                    "totalCost": 200.0,
                    "idleCost": 20.0
                }
            }
        }
    }
}
```

## Query complement cloud costs of a collection

Use the following request to query the complement cloud costs of a collection, which includes only the cloud costs not included in the collection. Optional pagination and filtering parameters are provided for navigating the data, similar to the Cloud Costs API.

### Request

```
GET /collection/query/complement/cloud?id=<string>&window=<string>(&aggregate=<string>&filter=<string>&limit=<number>&offset=<number>)
```

### Examples

```
GET /collection/query/complement/cloud?id=8a939ba1-ff15-4600-b711-2cb109114914&window=30d
```

```json
{
    "window": {
        "start": "2023-01-01T00:00:00Z",
        "end": "2023-02-01T00:00:00Z"
    },
    "data": {
        "cost": {
            "totalCost": 100.0,
            "domainCosts": {
                "cloudCost": {
                    "totalCost": 100.0
                }
            }
        }
    }
}
```

```
GET /collection/query/complement/cloud?id=8a939ba1-ff15-4600-b711-2cb109114914&window=30d&aggregate=service
```

```json
{
    "window": {
        "start": "2023-01-01T00:00:00Z",
        "end": "2023-02-01T00:00:00Z"
    },
    "data": {
        "cost": {
            "totalCost": 100.0,
            "domainCosts": {
                "cloudCost": {
                    "totalCost": 100.0
                }
            }
        },
        "items": [
            {
                "cost": 20.0,
                "name": "AmazonEC2"
            },
            {
                "cost": 10.0,
                "name": "AWS ELB"
            },
            ...
            {
                "cost": 5.0,
                "name": "Microsoft.Compute"
            }
        ]
    }
}
```

```
GET /collection/query/complement/cloud?id=8a939ba1-ff15-4600-b711-2cb109114914&window=30d&aggregate=providerID&filter=service:"AmazonEC2"
```

```json
{
    "window": {
        "start": "2023-01-01T00:00:00Z",
        "end": "2023-02-01T00:00:00Z"
    },
    "data": {
        "cost": {
            "totalCost": 20.0,
            "domainCosts": {
                "cloudCost": {
                    "totalCost": 20.0
                }
            }
        },
        "items": [
            {
                "cost": 12.0,
                "name": "i-nrfu3q8i475"
            },
            {
                "cost": 8.0,
                "name": "i-je1823e3477"
            }
        ]
    }
}
```

## Query complement Kubernetes costs of a collection

Use the following request to query the complement Kubernetes costs of a collection, which includes only the Kubernetes costs not included in the collection. Optional pagination and filtering parameters are provided for navigating the data, similar to the Allocation API.

### Request

```
GET /collection/query/complement/kubernetes?id=<string>&window=<string>(&aggregate=<string>&filter=<string>&limit=<number>&offset=<number>)
```

### Examples

```
GET /collection/query/complement/kubernetes?id=8a939ba1-ff15-4600-b711-2cb109114914&window=30d
```

```json
{
    "window": {
        "start": "2023-01-01T00:00:00Z",
        "end": "2023-02-01T00:00:00Z"
    },
    "data": {
        "cost": {
            "totalCost": 100.0,
            "idleCost": 20.0,
            "domainCosts": {
                "kubernetesCost": {
                    "totalCost": 100.0,
                    "idleCost": 20.0
                }
            }
        }
    }
}
```

```
GET /collection/query/complement/kubernetes?id=8a939ba1-ff15-4600-b711-2cb109114914&window=30d&aggregate=namespace
```

```json
{
    "window": {
        "start": "2023-01-01T00:00:00Z",
        "end": "2023-02-01T00:00:00Z"
    },
    "data": {
        "cost": {
            "totalCost": 100.0,
            "idleCost": 20.0,
            "domainCosts": {
                "kubernetesCost": {
                    "totalCost": 100.0,
                    "idleCost": 20.0
                }
            }
        },
        "items": [
            {
                "cost": 20.0,
                "name": "kubecost"
            },
            {
                "cost": 10.0,
                "name": "default"
            },
            ...
            {
                "cost": 5.0,
                "name": "kube-system"
            }
        ]
    }
}
```

```
GET /collection/query/complement/kubernetes?id=8a939ba1-ff15-4600-b711-2cb109114914&window=30d&aggregate=controller&filter=namespace:"kubecost"
```

```json
{
    "window": {
        "start": "2023-01-01T00:00:00Z",
        "end": "2023-02-01T00:00:00Z"
    },
    "data": {
        "cost": {
            "totalCost": 20.0,
            "idleCost": 10.0,
            "domainCosts": {
                "kubernetesCost": {
                    "totalCost": 20.0,
                    "idleCost": 10.0
                }
            }
        },
        "items": [
            {
                "cost": 12.0,
                "name": "cost-analyzer"
            },
            {
                "cost": 8.0,
                "name": "aggregator"
            }
        ]
    } 
}
```