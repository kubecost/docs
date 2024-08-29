# List collections

[Collections APIs](./#table-of-contents) / Managing collections / List collections

Use the following request to list all collections. Optionally, provide a category to list only those collections belonging to the given category.

### Request

```
GET /model/collections?(category=<string>)
```

### Examples

```
GET /model/collections
```

```json
{
    "collections": [
        {
            "id": "8a939ba1-ff15-4600-b711-2cb109114914",
            "name": "Infrastructure",
            "category": "Team", 
            "groups": [
                {
                    "selectors": {
                        "kubernetes": {
                            "kind": "container",
                            "filterString": "namespace:\"infrastructure\""
                        }
                    }
                },
                {
                    "selectors": {
                        "kubernetes": {
                            "kind": "container",
                            "filterString": "label[app]:\"infrastructure\""
                        }
                    }
                },
                {
                    "selectors": {
                        "cloud": {
                            "filterString": "service:\"AmazonEC2\"+label[team]:\"infrastructure\""
                        }
                    }
                }
            ]
        },
        {
            "id": "5aaaab83-f721-41da-ad90-8dca4f7c0f45",
            "name": "Core",
            "category": "Team",
            "groups": [
                {
                    "selectors": {
                        "kubernetes": {
                            "kind": "container",
                            "filterString": "namespace:\"core\""
                        }
                    }
                },
                {
                    "selectors": {
                        "kubernetes": {
                            "kind": "container",
                            "filterString": "label[app]:\"core\""
                        }
                    }
                },
                {
                    "selectors": {
                        "cloud": {
                            "filterString": "service:\"AmazonEC2\"+label[team]:\"core\""
                        }
                    }
                }
            ]
        },
        ...
        {
            "id": "36a98343-968b-419d-acae-7039bc79ea7d",
            "name": "My First Collection",
            "category": "",
            "groups": [
                {
                    "selectors": {
                        "kubernetes": {
                            "kind": "container",
                            "filterString": "namespace:\"default\""
                        }
                    }
                }
            ]
        }
    ]
}
```

```
GET /model/collections?kind=Team
```

```json
{
    "collections": [
        {
            "id": "8a939ba1-ff15-4600-b711-2cb109114914",
            "name": "Infrastructure",
            "category": "Team", 
            "groups": [
                {
                    "selectors": {
                        "kubernetes": {
                            "kind": "container",
                            "filterString": "namespace:\"infrastructure\""
                        }
                    }
                },
                {
                    "selectors": {
                        "kubernetes": {
                            "kind": "container",
                            "filterString": "label[app]:\"infrastructure\""
                        }
                    }
                },
                {
                    "selectors": {
                        "cloud": {
                            "filterString": "service:\"AmazonEC2\"+label[team]:\"infrastructure\""
                        }
                    }
                }
            ]
        },
        {
            "id": "5aaaab83-f721-41da-ad90-8dca4f7c0f45",
            "name": "Core",
            "category": "Team",
            "groups": [
                {
                    "selectors": {
                        "kubernetes": {
                            "kind": "container",
                            "filterString": "namespace:\"core\""
                        }
                    }
                },
                {
                    "selectors": {
                        "kubernetes": {
                            "kind": "container",
                            "filterString": "label[app]:\"core\""
                        }
                    }
                },
                {
                    "selectors": {
                        "cloud": {
                            "filterString": "service:\"AmazonEC2\"+label[team]:\"core\""
                        }
                    }
                }
            ]
        }
    ]
}
```
