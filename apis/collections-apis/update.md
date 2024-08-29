# Update an existing collection

[Collections APIs](./#table-of-contents) / Managing collections / Update a collection

Use the following request to update an existing collection by providing the collection ID and a new collection specification, in JSON, as the request body. To see a list of all collections, in order to find a collection ID and specification, reference the [List API](list.md).

### Request

```
PUT /model/collection?id=<string>
```

### Example

```
PUT /model/collection?id=8a939ba1-ff15-4600-b711-2cb109114914
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
