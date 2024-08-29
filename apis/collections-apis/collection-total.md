# Query collection total costs

[Collections APIs](./#table-of-contents) / Querying by collection / Query total costs of a collection

## Query total costs of collection

Use the following request to query the total costs of a collection, which includes all domain costs included in the collection. Optionally, request to also see the total costs of each group within the collection, as well as the cost of the overlap among those groups.

### Request

```
GET /model/collection/query/total?id=<string>&window=<string>(&groups=<true>)
```

### Examples

```
GET /model/collection/query/total?id=8a939ba1-ff15-4600-b711-2cb109114914&window=30d
```

```json
{
    "id": "8a939ba1-ff15-4600-b711-2cb109114914",
    "name": "Infrastructure",
    "category": "Team", 
    "window": {
        "start": "2023-01-01T00:00:00Z",
        "end": "2023-02-01T00:00:00Z"
    },
    "data": {
        "cost": {
            "totalCost": 60.0,
            "idleCost": 10.0,
            "domainCosts": {
                "kubernetesCost": {
                    "totalCost": 40.0,
                    "idleCost": 10.0
                },
                "cloudCost": {
                    "totalCost": 20.0
                }
            },
        },
    }
}
```

```
GET /model/collection/query/total?id=8a939ba1-ff15-4600-b711-2cb109114914&window=30d&groups=true
```

```json
{
    "id": "8a939ba1-ff15-4600-b711-2cb109114914",
    "name": "Infrastructure",
    "category": "Team", 
    "window": {
        "start": "2023-01-01T00:00:00Z",
        "end": "2023-02-01T00:00:00Z"
    },
    "data": {
        "cost": {
            "totalCost": 60.0,
            "idleCost": 10.0,
            "domainCosts": {
                "kubernetesCost": {
                    "totalCost": 40.0,
                    "idleCost": 10.0
                },
                "cloudCost": {
                    "totalCost": 20.0
                }
            },
        },
        "overlap": -10.0,
        "groups": [
            {
                "selectors": {
                    "kubernetes": {
                        "kind": "container",
                        "filterString": "namespace:\"infrastructure\""
                    }
                },
                "cost": {
                    "totalCost": 30.0,
                    "idleCost": 5.0,
                    "domainCosts": {
                        "kubernetesCost": {
                            "totalCost": 30.0,
                            "idleCost": 5.0
                        },
                    }
                }
            },
            {
                "selectors": {
                    "kubernetes": {
                        "kind": "container",
                        "filterString": "node:\"monitoring\""
                    }
                },
                "cost": {
                    "totalCost": 20.0,
                    "idleCost": 5.0,
                    "domainCosts": {
                        "kubernetesCost": {
                            "totalCost": 20.0,
                            "idleCost": 5.0
                        }
                    }
                }
            },
            {
                "selectors": {
                    "cloud": {
                        "filterString": "service:\"s3\"+label[team]:\"infrastructure\""
                    }
                },
                "cost": {
                    "totalCost": 20.0,
                    "domainCosts": {
                        "cloudCost": {
                            "totalCost": 20.0
                        }
                    }
                }
            }
        ]
    }
}
```
