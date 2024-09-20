# Create a new collection

[Collections APIs](./#table-of-contents) / Managing collections / Create a new collection

Use the following request to create a new collection by providing a collection specification, in JSON, as the request body.

### Request

```
POST /model/collections
```

### Example

```
POST /model/collections
```

```json
{
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
}
```
