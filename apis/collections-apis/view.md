# View a collection

[Collections APIs](./#table-of-contents) / Managing collections / View a collection

Use the following request to view a collection by providing the collection ID. To see a list of all collections, in order to find a collection ID, reference the [List API](list.md).

### Request

```
GET /model/collection?id=<string>
```

### Example

```
GET /model/collection?id=8a939ba1-ff15-4600-b711-2cb109114914
```

```json
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
}
```
