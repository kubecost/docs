# Query category total costs

[Collections APIs](./#table-of-contents) / Querying by category / Query the total costs of a category

## Query total costs of a category

Use the following request to query the total costs of a category, which includes all domain costs included in any of the collections in the category. Optionally, request to also see the total costs of each collection within the category, as well as the cost of the overlap among those collections.

### Request

```
GET /model/collections/query/total?category=<string>&window=<string>(&collections=<true>)
```

### Examples

```
GET /model/collections/query/total?category=Team&window=30d
```

```json
{
    "category": "Team", 
    "window": {
        "start": "2023-01-01T00:00:00Z",
        "end": "2023-02-01T00:00:00Z"
    },
    "collections": [
        {
            "id": "8a939ba1-ff15-4600-b711-2cb109114914",
            "name": "Infrastructure"
        },
        {
            "id": "5aaaab83-f721-41da-ad90-8dca4f7c0f45",
            "name": "Core"
        },
        {
            "id": "ba8bda2f-2cce-4f9d-a9d7-655b3ca52cbd",
            "name": "Front End"
        }
    ],
    "data": {
        "cost": {
            "totalCost": 100.0,
            "idleCost": 20.0,
            "domainCosts": {
                "kubernetesCost": {
                    "totalCost": 80.0,
                    "idleCost": 20.0
                },
                "cloudCost": {
                    "totalCost": 20.0
                }
            },
        }
    }
}
```

```
GET /model/collections/query/total?category=Team&window=30d&collections=true
```

```json
{
    "category": "Team", 
    "window": {
        "start": "2023-01-01T00:00:00Z",
        "end": "2023-02-01T00:00:00Z"
    },
    "collections": [
        {
            "id": "8a939ba1-ff15-4600-b711-2cb109114914",
            "name": "Infrastructure"
        },
        {
            "id": "5aaaab83-f721-41da-ad90-8dca4f7c0f45",
            "name": "Core"
        },
        {
            "id": "ba8bda2f-2cce-4f9d-a9d7-655b3ca52cbd",
            "name": "Front End"
        }
    ],
    "data": {
        "cost": {
            "totalCost": 100.0,
            "idleCost": 20.0,
            "domainCosts": {
                "kubernetesCost": {
                    "totalCost": 80.0,
                    "idleCost": 20.0
                },
                "cloudCost": {
                    "totalCost": 20.0
                }
            },
        },
        "overlap": -25.0,
        "collections": [
            {
                "id": "8a939ba1-ff15-4600-b711-2cb109114914",
                "name": "Infrastructure",
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
            },
            {
                "id": "5aaaab83-f721-41da-ad90-8dca4f7c0f45",
                "name": "Core",
                "cost": {
                    "totalCost": 35.0,
                    "idleCost": 5.0,
                    "domainCosts": {
                        "kubernetesCost": {
                            "totalCost": 30.0,
                            "idleCost": 5.0
                        },
                        "cloudCost": {
                            "totalCost": 5.0
                        }
                    },
                },
            },
            {
                "id": "ba8bda2f-2cce-4f9d-a9d7-655b3ca52cbd",
                "name": "Front End",
                "cost": {
                    "totalCost": 30.0,
                    "idleCost": 5.0,
                    "domainCosts": {
                        "kubernetesCost": {
                            "totalCost": 30.0,
                            "idleCost": 5.0
                        }
                    },
                },
            }
        ]
    }
}
```
