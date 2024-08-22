# Query collection time series costs

[Collections APIs](./#table-of-contents) / Querying by collection / Query time series costs of a collection

## Query time series costs of a collection

Use the following request to query the time series costs of a collection, which includes all domain costs included in the collection, presented serially in increments of daily data. Optionally, request to also see the total costs of each group within the collection, as well as the cost of the overlap among those groups.

### Request

```
GET /model/collection/query/timeseries?id=<string>&window=<string>(&groups=<true>)
```

### Examples

```
GET /model/collection/query/timeseries?id=8a939ba1-ff15-4600-b711-2cb109114914&window=30d
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
        "timeseries": [
            {
                "window": {
                    "start": "2023-01-01T00:00:00Z",
                    "end": "2023-01-02T00:00:00Z"
                },
                "cost": {
                    "totalCost": 20.0,
                    "idleCost": 5.0,
                    "domainCosts": {
                        "cloudCost": {
                            "totalCost": 10.0
                        },
                        "kubernetesCost": {
                            "totalCost": 10.0,
                            "idleCost": 5.0
                        }
                    }
                }
            },
            {
                "window": {
                    "start": "2023-01-02T00:00:00Z",
                    "end": "2023-01-03T00:00:00Z"
                },
                "cost": {
                    "totalCost": 20.0,
                    "idleCost": 5.0,
                    "domainCosts": {
                        "cloudCost": {
                            "totalCost": 10.0
                        },
                        "kubernetesCost": {
                            "totalCost": 10.0,
                            "idleCost": 5.0
                        }
                    }
                }
            },
            ...
            {
                "window": {
                    "start": "2023-01-31T00:00:00Z",
                    "end": "2023-02-01T00:00:00Z"
                },
                "cost": {
                    "totalCost": 20.0,
                    "idleCost": 5.0,
                    "domainCosts": {
                        "cloudCost": {
                            "totalCost": 10.0
                        },
                        "kubernetesCost": {
                            "totalCost": 10.0,
                            "idleCost": 5.0
                        }
                    }
                }
            }
        ]
    }
}
```

```
GET /model/collection/query/timeseries?id=8a939ba1-ff15-4600-b711-2cb109114914&window=30d&groups=true
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
        "timeseries": [
            {
                "window": {
                    "start": "2023-01-01T00:00:00Z",
                    "end": "2023-01-02T00:00:00Z"
                },
                "cost": {
                    "totalCost": 30.0,
                    "idleCost": 5.0,
                    "domainCosts": {
                        "cloudCost": {
                            "totalCost": 10.0
                        },
                        "kubernetesCost": {
                            "totalCost": 20.0,
                            "idleCost": 5.0
                        }
                    }
                },
                "overlap": -5.0,
                "groups": [
                    {
                        "selectors": {
                            "kubernetes": {
                                "kind": "container",
                                "filterString": "namespace:\"monitoring\""
                            }
                        },
                        "cost": {
                            "totalCost": 10.0,
                            "idleCost": 3.0,
                            "domainCosts": {
                                "kuberneteCost": {
                                    "totalCost": 10.0,
                                    "idleCost": 3.0
                                }
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
                            "totalCost": 15.0,
                            "idleCost": 4.0,
                            "domainCosts": {
                                "kubernetesCost": {
                                    "totalCost": 15.0,
                                    "idleCost": 4.0
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
                            "totalCost": 10.0,
                            "domainCosts": {
                                "cloudCost": 10.0
                            }
                        }
                    }
                ]
            },
            {
                "window": {
                    "start": "2023-01-02T00:00:00Z",
                    "end": "2023-01-03T00:00:00Z"
                },
                "cost": {
                    "totalCost": 30.0,
                    "idleCost": 5.0,
                    "domainCosts": {
                        "cloudCost": {
                            "totalCost": 10.0
                        },
                        "kubernetesCost": {
                            "totalCost": 20.0,
                            "idleCost": 5.0
                        }
                    }
                },
                "overlap": -5.0,
                "groups": [
                    {
                        "selectors": {
                            "kubernetes": {
                                "kind": "container",
                                "filterString": "namespace:\"monitoring\""
                            }
                        },
                        "cost": {
                            "totalCost": 10.0,
                            "idleCost": 3.0,
                            "domainCosts": {
                                "kuberneteCost": {
                                    "totalCost": 10.0,
                                    "idleCost": 3.0
                                }
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
                            "totalCost": 15.0,
                            "idleCost": 4.0,
                            "domainCosts": {
                                "kubernetesCost": {
                                    "totalCost": 15.0,
                                    "idleCost": 4.0
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
                            "totalCost": 10.0,
                            "domainCosts": {
                                "cloudCost": 10.0
                            }
                        }
                    }
                ]
            },
            ...
            {
                "window": {
                    "start": "2023-01-31T00:00:00Z",
                    "end": "2023-02-01T00:00:00Z"
                },
                "cost": {
                    "totalCost": 30.0,
                    "idleCost": 5.0,
                    "domainCosts": {
                        "cloudCost": {
                            "totalCost": 10.0
                        },
                        "kubernetesCost": {
                            "totalCost": 20.0,
                            "idleCost": 5.0
                        }
                    }
                },
                "overlap": -5.0,
                "groups": [
                    {
                        "selectors": {
                            "kubernetes": {
                                "kind": "container",
                                "filterString": "namespace:\"monitoring\""
                            }
                        },
                        "cost": {
                            "totalCost": 10.0,
                            "idleCost": 3.0,
                            "domainCosts": {
                                "kuberneteCost": {
                                    "totalCost": 10.0,
                                    "idleCost": 3.0
                                }
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
                            "totalCost": 15.0,
                            "idleCost": 4.0,
                            "domainCosts": {
                                "kubernetesCost": {
                                    "totalCost": 15.0,
                                    "idleCost": 4.0
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
                            "totalCost": 10.0,
                            "domainCosts": {
                                "cloudCost": 10.0
                            }
                        }
                    }
                ]
            }
        ]
    }
}
```
